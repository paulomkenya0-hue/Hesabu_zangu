import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _morningId = 1001;
  static const int _eveningId = 1002;
  static const int _weeklyId = 1003;

  // ━━━ INITIALIZE ━━━
  Future<void> init() async {
    tz_data.initializeTimeZones();

    // Tanzania timezone
    tz.setLocalLocation(tz.getLocation('Africa/Dar_es_Salaam'));

    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap - navigate to app
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ━━━ NOTIFICATION DETAILS ━━━
  NotificationDetails _buildDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    Color color = const Color(0xFF1B5E20),
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        color: color,
        enableLights: true,
        ledColor: color,
        ledOnMs: 1000,
        ledOffMs: 500,
        styleInformation: const BigTextStyleInformation(''),
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━
  // SCHEDULE MORNING REMINDER
  // Kila siku saa 3 asubuhi (9:00 AM)
  // ━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> scheduleMorningReminder() async {
    await _plugin.zonedSchedule(
      _morningId,
      '🌅 Habari za Asubuhi!',
      'Anza siku yako vizuri — rekodi mapato na matumizi yako ya leo. 💰',
      _nextInstanceOfTime(9, 0),
      _buildDetails(
        channelId: 'morning_reminder',
        channelName: 'Ukumbusho wa Asubuhi',
        channelDesc: 'Notification ya asubuhi kukukumbusha kurekodi',
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'morning_reminder',
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━
  // SCHEDULE EVENING REMINDER
  // Kila siku saa 2 usiku (8:00 PM)
  // ━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> scheduleEveningReminder() async {
    await _plugin.zonedSchedule(
      _eveningId,
      '🌙 Habari za Jioni!',
      'Siku inakwisha — je umeweka rekodi zako zote? Angalia hesabu zako sasa. 📊',
      _nextInstanceOfTime(20, 0),
      _buildDetails(
        channelId: 'evening_reminder',
        channelName: 'Ukumbusho wa Jioni',
        channelDesc: 'Notification ya jioni kukukumbusha kumaliza rekodi',
        color: const Color(0xFF1565C0),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'evening_reminder',
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━
  // WEEKLY SUMMARY (Jumapili saa 5 jioni - 11:00 AM)
  // ━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> scheduleWeeklySummary(
      double weekIncome, double weekExpense) async {
    final balance = weekIncome - weekExpense;
    final f = (double v) {
      return 'Sh. ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    };

    await _plugin.zonedSchedule(
      _weeklyId,
      '📊 Muhtasari wa Wiki!',
      'Mapato: ${f(weekIncome)} | Matumizi: ${f(weekExpense)} | ${balance >= 0 ? "Faida" : "Hasara"}: ${f(balance.abs())}',
      _nextInstanceOfWeekday(DateTime.sunday, 11, 0),
      _buildDetails(
        channelId: 'weekly_summary',
        channelName: 'Muhtasari wa Wiki',
        channelDesc: 'Muhtasari wa wiki kila Jumapili',
        color: const Color(0xFF6A1B9A),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_summary',
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━
  // INSTANT NOTIFICATION (kwa test)
  // ━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      9999,
      title,
      body,
      _buildDetails(
        channelId: 'instant',
        channelName: 'Instant',
        channelDesc: 'Instant notifications',
      ),
    );
  }

  // ━━━ CANCEL SPECIFIC ━━━
  Future<void> cancelMorningReminder() async =>
      await _plugin.cancel(_morningId);

  Future<void> cancelEveningReminder() async =>
      await _plugin.cancel(_eveningId);

  Future<void> cancelWeeklySummary() async =>
      await _plugin.cancel(_weeklyId);

  // ━━━ CANCEL ALL ━━━
  Future<void> cancelAll() async => await _plugin.cancelAll();

  // ━━━ SCHEDULE ALL ACTIVE ━━━
  Future<void> scheduleAllReminders({
    required bool morning,
    required bool evening,
  }) async {
    await cancelAll();
    if (morning) await scheduleMorningReminder();
    if (evening) await scheduleEveningReminder();
    await scheduleWeeklySummary(0, 0);
  }

  // ━━━ HELPERS ━━━
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(
      int weekday, int hour, int minute) {
    tz.TZDateTime scheduled =
        _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
