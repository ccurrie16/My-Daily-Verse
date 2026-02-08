import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// Service to manage local notifications
class NotificationService {
  NotificationService._();
  // Singleton instance of the notification plugin
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  // Notification ID for daily reminders
  static const int dailyReminderId = 1001;
  // Initialize the notification service
  static Future<void> init() async {
    tz.initializeTimeZones();
    // Initialization settings for Android and iOS
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // Request permissions on iOS
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    // Initialize the plugin
    await _plugin.initialize(initSettings);

    // Request notification permissions for Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  // Schedule a daily reminder notification at the specified time
  static Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    // Calculate the next instance of the specified time
    final scheduled = _nextInstanceOfTime(time);
    // Notification details for Android
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Daily verse reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    // Notification details for iOS
    const iosDetails = DarwinNotificationDetails();
    // Combined notification details
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    // Schedule the notification to repeat daily at the specified time
    await _plugin.zonedSchedule(
      dailyReminderId,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // ✅ repeats daily
    );
  }
  // Cancel the daily reminder notification
  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(dailyReminderId);
  }
  // Helper method to calculate the next instance of the specified time
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // If the scheduled time is before now, schedule for the next day
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
