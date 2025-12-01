import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); // ✅ required for scheduling
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);
  }

  /// Daily repeating reminder (e.g. "Check your goals at 9 AM")
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
    required int id,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.local(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day + 1,
        hour,
        minute,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          channelDescription: 'Repeating daily reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // ✅ repeat daily
    );
  }

  /// One-time notification for a specific deadline
  static Future<void> scheduleDeadlineReminder({
    required DateTime deadline,
    required String title,
    required String body,
    required int id,
  }) async {
    final tzDate = tz.TZDateTime.from(deadline, tz.local);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Goal Deadlines',
          channelDescription: 'Reminders for goal deadlines',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // ignore: deprecated_member_use
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a notification (e.g. if goal is completed or deleted)
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
