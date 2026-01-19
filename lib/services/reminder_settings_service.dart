import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class ReminderSettingsService {
  ReminderSettingsService._();

  static const _enabledKey = 'dailyReminderEnabled';
  static const _hourKey = 'dailyReminderHour';
  static const _minuteKey = 'dailyReminderMinute';

  static final ValueNotifier<bool> enabled = ValueNotifier(false);
  static final ValueNotifier<TimeOfDay> time =
      ValueNotifier(const TimeOfDay(hour: 8, minute: 0));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    enabled.value = prefs.getBool(_enabledKey) ?? false;

    final h = prefs.getInt(_hourKey) ?? 8;
    final m = prefs.getInt(_minuteKey) ?? 0;
    time.value = TimeOfDay(hour: h, minute: m);

    // If enabled, re-schedule on app start (important)
    if (enabled.value) {
      await _applySchedule();
    }
  }

  static Future<void> setEnabled(bool value) async {
    enabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);

    if (value) {
      await _applySchedule();
    } else {
      await NotificationService.cancelDailyReminder();
    }
  }

  static Future<void> setTime(TimeOfDay newTime) async {
    time.value = newTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, newTime.hour);
    await prefs.setInt(_minuteKey, newTime.minute);

    if (enabled.value) {
      await _applySchedule();
    }
  }

  static Future<void> _applySchedule() async {
    // Keep the message short (notification preview)
    await NotificationService.scheduleDailyReminder(
      time: time.value,
      title: 'Daily Verse',
      body: 'Tap to read today’s verse.',
    );
  }
}
