class AppConstants {
  // ━━━ APP INFO ━━━
  static const String appName = 'Hesabu Zangu';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Simamia Pesa Zako Kila Siku';

  // ━━━ HIVE BOXES ━━━
  static const String transactionBox = 'transactions';
  static const String settingsBox = 'settings';
  static const String categoryBox = 'categories';

  // ━━━ SETTINGS KEYS ━━━
  static const String keyUserName = 'user_name';
  static const String keyReminderMorning = 'reminder_morning';
  static const String keyReminderEvening = 'reminder_evening';
  static const String keyIsPremium = 'is_premium';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyMorningTime = 'morning_time';
  static const String keyEveningTime = 'evening_time';

  // ━━━ MAPATO CATEGORIES ━━━
  static const List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Mshahara', 'icon': '💼'},
    {'name': 'Mauzo ya Biashara', 'icon': '🛒'},
    {'name': 'Safari (Bodaboda)', 'icon': '🏍️'},
    {'name': 'Mauzo ya Chakula', 'icon': '🍲'},
    {'name': 'Mradi / Kazi ya Ziada', 'icon': '🔧'},
    {'name': 'Mkopo Uliopokelewa', 'icon': '🤝'},
    {'name': 'Zawadi / Msaada', 'icon': '🎁'},
    {'name': 'Mapato Mengineyo', 'icon': '💰'},
  ];

  // ━━━ MATUMIZI CATEGORIES ━━━
  static const List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Umeme (LUKU)', 'icon': '⚡'},
    {'name': 'Maji', 'icon': '🚰'},
    {'name': 'Mafuta', 'icon': '⛽'},
    {'name': 'Usafiri', 'icon': '🚌'},
    {'name': 'Chakula', 'icon': '🍽️'},
    {'name': 'Airtime / Data', 'icon': '📱'},
    {'name': 'Afya / Dawa', 'icon': '🏥'},
    {'name': 'Kodi ya Nyumba', 'icon': '🏠'},
    {'name': 'Elimu / Shule', 'icon': '📚'},
    {'name': 'Mavazi', 'icon': '👗'},
    {'name': 'Matengenezo', 'icon': '🔨'},
    {'name': 'Matumizi Mengineyo', 'icon': '📦'},
  ];

  // ━━━ ADMOB IDs (Test IDs - Badilisha na za kweli) ━━━
  static const String admobBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String admobInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';

  // ━━━ PREMIUM PRICE ━━━
  static const int premiumMonthlyPrice = 2500;  // TZS
  static const int premiumYearlyPrice = 20000;  // TZS
  static const int premiumLifetimePrice = 15000; // TZS
}
