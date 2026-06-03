import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount; // Kiasi cha pesa

  @HiveField(2)
  late String type; // 'income' au 'expense'

  @HiveField(3)
  late String category; // Aina ya mapato/matumizi

  @HiveField(4)
  late String categoryIcon; // Emoji icon

  @HiveField(5)
  late String note; // Maelezo ya ziada

  @HiveField(6)
  late DateTime date; // Tarehe

  @HiveField(7)
  late String createdAt; // Timestamp

  // ━━━ CONSTRUCTOR ━━━
  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIcon,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  // ━━━ HELPERS ━━━
  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  // Format amount kwa TZS
  String get formattedAmount {
    final num = amount.toStringAsFixed(0);
    return 'Sh. ${_formatNumber(num)}';
  }

  String _formatNumber(String num) {
    final result = StringBuffer();
    int count = 0;
    for (int i = num.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write(',');
      result.write(num[i]);
      count++;
    }
    return result.toString().split('').reversed.join('');
  }
}
