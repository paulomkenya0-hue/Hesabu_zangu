import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import '../utils/colors.dart';
import '../widgets/transaction_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HiveService _hive = HiveService();
  String _filter = 'Yote'; // 'Yote', 'Mapato', 'Matumizi'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return 'Sh. ${formatter.format(amount)}';
  }

  List<TransactionModel> _getFilteredTransactions(
      List<TransactionModel> all) {
    var filtered = all;

    // Filter by type
    if (_filter == 'Mapato') {
      filtered = filtered.where((t) => t.isIncome).toList();
    } else if (_filter == 'Matumizi') {
      filtered = filtered.where((t) => t.isExpense).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.category
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              t.note
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // Group transactions by date
  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var t in transactions) {
      final key = _formatDateKey(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);
    if (txDate == today) return 'Leo';
    if (txDate == today.subtract(const Duration(days: 1))) return 'Jana';
    return DateFormat('EEEE, dd MMM yyyy', 'sw').format(date);
  }

  Future<void> _deleteTransaction(TransactionModel t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Futa Rekodi?'),
        content: const Text('Una uhakika unataka kufuta rekodi hii?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hapana'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense),
            child: const Text('Futa',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) await _hive.deleteTransaction(t.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📋 Historia Yote',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _hive.transactionBox.listenable(),
        builder: (context, box, _) {
          final all = _hive.getAllTransactions();
          final filtered = _getFilteredTransactions(all);
          final grouped = _groupByDate(filtered);
          final keys = grouped.keys.toList();

          return Column(
            children: [
              // ━━━ SEARCH BAR ━━━
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tafuta rekodi...',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.7)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.white),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ━━━ FILTER TABS ━━━
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: ['Yote', 'Mapato', 'Matumizi'].map((f) {
                    final isSelected = _filter == f;
                    Color chipColor = AppColors.primary;
                    if (f == 'Mapato') chipColor = AppColors.income;
                    if (f == 'Matumizi') chipColor = AppColors.expense;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? chipColor
                                : chipColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            f,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : chipColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ━━━ SUMMARY STRIP ━━━
              if (filtered.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} rekodi',
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '+ ${_formatAmount(filtered.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount))}',
                        style: const TextStyle(
                            color: AppColors.income,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '- ${_formatAmount(filtered.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount))}',
                        style: const TextStyle(
                            color: AppColors.expense,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // ━━━ TRANSACTION LIST ━━━
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: keys.length,
                        itemBuilder: (context, i) {
                          final dateKey = keys[i];
                          final dayTransactions = grouped[dateKey]!;
                          final dayIncome = dayTransactions
                              .where((t) => t.isIncome)
                              .fold(0.0, (s, t) => s + t.amount);
                          final dayExpense = dayTransactions
                              .where((t) => t.isExpense)
                              .fold(0.0, (s, t) => s + t.amount);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date header
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      dateKey,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (dayIncome > 0)
                                      Text(
                                        '+${_formatAmount(dayIncome)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.income,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (dayExpense > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '-${_formatAmount(dayExpense)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.expense,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Cards
                              ...dayTransactions.map((t) =>
                                  TransactionCard(
                                    transaction: t,
                                    onDelete: () => _deleteTransaction(t),
                                  )),

                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Hakuna matokeo ya "$_searchQuery"'
                : 'Hakuna rekodi bado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
