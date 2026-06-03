import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/hive_service.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';
import '../utils/colors.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final HiveService _hive = HiveService();
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return 'Sh. ${formatter.format(amount)}';
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('📊 Ripoti',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Muhtasari'),
            Tab(text: 'Kwa Aina'),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _hive.transactionBox.listenable(),
        builder: (context, box, _) {
          final month = _selectedMonth.month;
          final year = _selectedMonth.year;
          final income = _hive.getMonthIncome(month, year);
          final expense = _hive.getMonthExpense(month, year);
          final balance = income - expense;
          final categoryData = _hive.getExpenseByCategory(month, year);

          return TabBarView(
            controller: _tabController,
            children: [
              // ━━━ TAB 1: SUMMARY ━━━
              _buildSummaryTab(income, expense, balance),

              // ━━━ TAB 2: BY CATEGORY ━━━
              _buildCategoryTab(categoryData, expense),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    final isCurrentMonth = _selectedMonth.month == DateTime.now().month &&
        _selectedMonth.year == DateTime.now().year;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: isCurrentMonth
                    ? Colors.grey[300]
                    : AppColors.primary),
            onPressed:
                isCurrentMonth ? null : () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(
      double income, double expense, double balance) {
    // Weekly data for chart (last 4 weeks)
    final barGroups = _buildWeeklyBars(income, expense);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMonthSelector(),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ━━━ TOP 3 CARDS ━━━
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Mapato',
                        income,
                        '📈',
                        AppColors.income,
                        AppColors.incomeLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'Matumizi',
                        expense,
                        '📉',
                        AppColors.expense,
                        AppColors.expenseLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _buildBalanceCard(balance),

                const SizedBox(height: 24),

                // ━━━ DOWNLOAD BUTTONS ━━━
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pakua Ripoti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDownloadButton(
                        icon: '📄',
                        label: 'PDF',
                        sublabel: 'Fungua au Chapisha',
                        color: const Color(0xFFB71C1C),
                        bgColor: const Color(0xFFFFEBEE),
                        onTap: () async {
                          _showLoadingSnackbar(context, 'Inaunda PDF...');
                          final path =
                              await PdfService.generateMonthlyReport(
                            context,
                            _selectedMonth.month,
                            _selectedMonth.year,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(path != null
                                    ? '✅ PDF imefunguliwa!'
                                    : '❌ Hitilafu — jaribu tena'),
                                backgroundColor: path != null
                                    ? AppColors.income
                                    : AppColors.expense,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDownloadButton(
                        icon: '📊',
                        label: 'Excel',
                        sublabel: 'Fungua Spreadsheet',
                        color: const Color(0xFF1B5E20),
                        bgColor: const Color(0xFFE8F5E9),
                        onTap: () async {
                          _showLoadingSnackbar(
                              context, 'Inaunda Excel...');
                          final path =
                              await ExcelService.generateMonthlyExcel(
                            context,
                            _selectedMonth.month,
                            _selectedMonth.year,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(path != null
                                    ? '✅ Excel imefunguliwa!'
                                    : '❌ Hitilafu — jaribu tena'),
                                backgroundColor: path != null
                                    ? AppColors.income
                                    : AppColors.expense,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                if (income > 0 || expense > 0) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mapato vs Matumizi (Wiki)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: barGroups.isEmpty
                        ? const Center(
                            child: Text('Hakuna data ya kutosha'))
                        : BarChart(
                            BarChartData(
                              barGroups: barGroups,
                              gridData:
                                  const FlGridData(show: false),
                              borderData:
                                  FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles:
                                        SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) => Text(
                                      'W${v.toInt() + 1}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend('Mapato', AppColors.income),
                      const SizedBox(width: 20),
                      _buildLegend('Matumizi', AppColors.expense),
                    ],
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
      Map<String, double> categoryData, double totalExpense) {
    final sorted = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMonthSelector(),
          const Divider(height: 1),

          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.all(60),
              child: Column(
                children: [
                  Text('📊', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'Hakuna matumizi mwezi huu',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textMedium),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pie chart
                  if (sorted.isNotEmpty)
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: PieChart(
                        PieChartData(
                          sections: sorted.asMap().entries.map((e) {
                            final pct = totalExpense > 0
                                ? (e.value.value / totalExpense * 100)
                                : 0.0;
                            return PieChartSectionData(
                              value: e.value.value,
                              title: '${pct.toStringAsFixed(0)}%',
                              color: AppColors.categoryColors[
                                  e.key % AppColors.categoryColors.length],
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Category list
                  ...sorted.asMap().entries.map((e) {
                    final pct = totalExpense > 0
                        ? (e.value.value / totalExpense * 100)
                        : 0.0;
                    final color = AppColors.categoryColors[
                        e.key % AppColors.categoryColors.length];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct / 100,
                                    backgroundColor:
                                        color.withOpacity(0.15),
                                    color: color,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatAmount(e.value.value),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.expense,
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, String icon,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    final isPositive = balance >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
              : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPositive ? 'Faida ya Mwezi ✅' : 'Hasara ya Mwezi ⚠️',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _formatAmount(balance.abs()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textMedium)),
      ],
    );
  }

  Widget _buildDownloadButton({
    required String icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(message,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<BarChartGroupData> _buildWeeklyBars(
      double totalIncome, double totalExpense) {
    // Simplified - divide evenly into 4 weeks for visualization
    if (totalIncome == 0 && totalExpense == 0) return [];
    return List.generate(4, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totalIncome / 4,
            color: AppColors.income,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: totalExpense / 4,
            color: AppColors.expense,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
