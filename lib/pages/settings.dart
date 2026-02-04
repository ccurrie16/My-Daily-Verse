import 'package:flutter/material.dart';
import '../theme_controller.dart';
import '../services/reminder_settings_service.dart';

/// 🎨 App-wide colors (same as your HomeScreen)
class AppColors {
  AppColors._();

  static const Color offwhite = Color(0xFFFAFBF8);
  static const Color white = Color(0xFFFFFFFF);

  static const Color gold = Color(0xFFFFF9B2);
  static const Color softgold = Color(0xFFFFF8BF);
  static const Color darkgold = Color(0xFFE0C869);

  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF7A7A7A);
}

class Settings extends StatefulWidget {
  final ThemeController themeController;

  const Settings({
    super.key,
    required this.themeController,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _themeExpanded = false;

  void _toggleThemeExpanded() {
    setState(() => _themeExpanded = !_themeExpanded);
  }

  void _selectTheme(ThemeMode mode) {
    widget.themeController.setMode(mode);
    setState(() => _themeExpanded = false); // collapse after choosing
  }

  String _modeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _timeLabel(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:${_twoDigits(t.minute)} $ampm';
  }

  // ✨ 5. CUSTOM STYLED TIME PICKER - Matches gold/cream aesthetic
  Future<void> _showCustomTimePicker(TimeOfDay currentTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkgold, // Header background
              onPrimary: Colors.white, // Header text
              surface: AppColors.offwhite, // Dialog background
              onSurface: AppColors.textPrimary, // Body text
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.offwhite,
              hourMinuteTextColor: AppColors.textPrimary,
              hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.softgold
                      : AppColors.white),
              dayPeriodTextColor: AppColors.textPrimary,
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.softgold
                      : AppColors.white),
              dialHandColor: AppColors.darkgold,
              dialBackgroundColor: AppColors.white,
              dialTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? Colors.white
                      : AppColors.textPrimary),
              entryModeIconColor: AppColors.darkgold,
              helpTextStyle: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkgold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await ReminderSettingsService.setTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offwhite,
      appBar: AppBar(
        backgroundColor: AppColors.offwhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkgold),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.darkgold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          /// ✅ Theme setting card
          _Card(
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _toggleThemeExpanded,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Theme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _modeLabel(widget.themeController.mode),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        // Chevron
                        AnimatedRotation(
                          turns: _themeExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// ✅ Sliding bar dropdown (simple + smooth)
                _SlideDown(
                  expanded: _themeExpanded,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // subtle divider bar
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.06),
                      ),
                      const SizedBox(height: 8),

                      _ThemeRow(
                        label: 'System',
                        selected: widget.themeController.mode == ThemeMode.system,
                        onTap: () => _selectTheme(ThemeMode.system),
                      ),
                      _ThemeRow(
                        label: 'Light',
                        selected: widget.themeController.mode == ThemeMode.light,
                        onTap: () => _selectTheme(ThemeMode.light),
                      ),
                      _ThemeRow(
                        label: 'Dark',
                        selected: widget.themeController.mode == ThemeMode.dark,
                        onTap: () => _selectTheme(ThemeMode.dark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Reminders',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          /// ✅ Daily Reminder card (toggle + time picker)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Get a notification each day to read your verse.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                ValueListenableBuilder<bool>(
                  valueListenable: ReminderSettingsService.enabled,
                  builder: (_, enabled, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enable reminder',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Switch(
                          value: enabled,
                          activeColor: AppColors.darkgold,
                          onChanged: (v) => ReminderSettingsService.setEnabled(v),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 4),

                ValueListenableBuilder<bool>(
                  valueListenable: ReminderSettingsService.enabled,
                  builder: (_, enabled, __) {
                    return ValueListenableBuilder<TimeOfDay>(
                      valueListenable: ReminderSettingsService.time,
                      builder: (_, t, __) {
                        return InkWell(
                          onTap: enabled ? () => _showCustomTimePicker(t) : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: enabled
                                  ? AppColors.offwhite
                                  : AppColors.offwhite.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: enabled
                                    ? AppColors.softgold.withOpacity(0.5)
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: enabled
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _timeLabel(t),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: enabled
                                            ? AppColors.darkgold
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: enabled
                                          ? AppColors.darkgold
                                          : AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🧱 Simple reusable card matching your style
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ⬇️ Sliding expand/collapse area (the "bar slides down")
class _SlideDown extends StatelessWidget {
  final bool expanded;
  final Widget child;

  const _SlideDown({
    required this.expanded,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }
}

/// ☑️ One option row inside the dropdown area
class _ThemeRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.darkgold : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.darkgold : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
