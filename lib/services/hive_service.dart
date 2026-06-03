import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class HiveService {
  // ━━━ SINGLETON ━━━
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  // ━━━ BOXES ━━━
  late Box<TransactionModel> _transactionBox;
  late Box _settingsBox;

  // ━━━ INITIALIZE ━━━
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(AppConstants.transactionBox);
    await Hive.openBox(AppConstants.settingsBox);
  }

  Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>(AppConstants.transactionBox);

  Box get settingsBox => Hive.box(AppConstants.settingsBox);

  // ━━━━━━━━━━━━━━━━━━━━━━━━
  // TRANSACTION OPERATIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━

  // Ongeza transaction mpya
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  // Futa transaction
  Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  // Pata transactions zote
  List<TransactionModel> getAllTransactions() {
    final list = transactionBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // Mpya kwanza
    return list;
  }

  // Pata transactions za leo
  List<TransactionModel> getTodayTransactions() {
    final now = DateTime.now();
    return transactionBox.values.where((t) {
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Pata transactions za mwezi huu
  List<TransactionModel> getMonthTransactions(int month, int year) {
    return transactionBox.values.where((t) {
      return t.date.month == month && t.date.year == year;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ━━━━━━━━━━━━━━━━
  // CALCULATIONS
  // ━━━━━━━━━━━━━━━━

  // Jumla ya mapato ya leo
  double getTodayIncome() {
    return getTodayTransactions()
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Jumla ya matumizi ya leo
  double getTodayExpense() {
    return getTodayTransactions()
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Salio la leo
  double getTodayBalance() => getTodayIncome() - getTodayExpense();

  // Jumla ya mapato - mwezi
  double getMonthIncome(int month, int year) {
    return getMonthTransactions(month, year)
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Jumla ya matumizi - mwezi
  double getMonthExpense(int month, int year) {
    return getMonthTransactions(month, year)
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Salio la mwezi
  double getMonthBalance(int month, int year) =>
      getMonthIncome(month, year) - getMonthExpense(month, year);

  // Jumla ya mapato yote
  double getTotalIncome() {
    return transactionBox.values
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Jumla ya matumizi yote
  double getTotalExpense() {
    return transactionBox.values
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Salio lote
  double getTotalBalance() => getTotalIncome() - getTotalExpense();

  // Matumizi kwa category - mwezi
  Map<String, double> getExpenseByCategory(int month, int year) {
    final Map<String, double> result = {};
    final expenses = getMonthTransactions(month, year)
        .where((t) => t.isExpense);
    for (var t in expenses) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // ━━━━━━━━━━━━━━━━
  // SETTINGS
  // ━━━━━━━━━━━━━━━━

  String getUserName() =>
      settingsBox.get(AppConstants.keyUserName, defaultValue: 'Rafiki');

  Future<void> setUserName(String name) async =>
      await settingsBox.put(AppConstants.keyUserName, name);

  bool isOnboardingDone() =>
      settingsBox.get(AppConstants.keyOnboardingDone, defaultValue: false);

  Future<void> setOnboardingDone() async =>
      await settingsBox.put(AppConstants.keyOnboardingDone, true);

  bool isPremium() =>
      settingsBox.get(AppConstants.keyIsPremium, defaultValue: false);

  Future<void> setPremium(bool value) async =>
      await settingsBox.put(AppConstants.keyIsPremium, value);

  bool isMorningReminderOn() =>
      settingsBox.get(AppConstants.keyReminderMorning, defaultValue: true);

  bool isEveningReminderOn() =>
      settingsBox.get(AppConstants.keyReminderEvening, defaultValue: true);

  Future<void> setMorningReminder(bool value) async =>
      await settingsBox.put(AppConstants.keyReminderMorning, value);

  Future<void> setEveningReminder(bool value) async =>
      await settingsBox.put(AppConstants.keyReminderEvening, value);
}
