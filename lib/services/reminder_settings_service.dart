import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
// Service to manage reminder settings
class ReminderSettingsService {
  ReminderSettingsService._();
  // Keys for SharedPreferences
  static const _enabledKey = 'dailyReminderEnabled';
  static const _hourKey = 'dailyReminderHour';
  static const _minuteKey = 'dailyReminderMinute';
  // ValueNotifiers to track enabled state and time
  static final ValueNotifier<bool> enabled = ValueNotifier(false);
  static final ValueNotifier<TimeOfDay> time =
      ValueNotifier(const TimeOfDay(hour: 8, minute: 0));
  // Initialize settings from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Load enabled state and time
    enabled.value = prefs.getBool(_enabledKey) ?? false;
    // Default to 8:00 AM if not set
    final h = prefs.getInt(_hourKey) ?? 8;
    final m = prefs.getInt(_minuteKey) ?? 0;
    time.value = TimeOfDay(hour: h, minute: m);

    // If enabled, apply the schedule
    if (enabled.value) {
      await _applySchedule();
    }
  }
  // Update enabled state
  static Future<void> setEnabled(bool value) async {
    enabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    // If enabled schedule the notification, otherwise cancel it
    if (value) {
      await _applySchedule();
    } else {
      await NotificationService.cancelDailyReminder();
    }
  }
  // Update reminder time
  static Future<void> setTime(TimeOfDay newTime) async {
    time.value = newTime;
    // Save the new time to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, newTime.hour);
    await prefs.setInt(_minuteKey, newTime.minute);
    // If reminders are enabled, update the schedule with the new time
    if (enabled.value) {
      await _applySchedule();
    }
  }
  // Apply the notification schedule based on current settings
  static Future<void> _applySchedule() async {
    // Schedule the daily reminder notification with the current time and a fixed title
    await NotificationService.scheduleDailyReminder(
      time: time.value,
      title: 'Daily Verse',
      body: 'Tap to read today’s verse.',
    );
  }
}
