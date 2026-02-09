import 'package:flutter/material.dart';
import 'package:bible/theme_controller.dart';
import 'package:bible/services/reminder_settings_service.dart';
import 'package:bible/pages/home_screen.dart';

// Settings page allowing theme selection and daily reminder configuration
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

  // State to track if theme dropdown is expanded
  bool _themeExpanded = false;

  // Toggle the theme dropdown expansion
  void _toggleThemeExpanded() {
    setState(() => _themeExpanded = !_themeExpanded);
  }
  
  // Select a theme and collapse the dropdown
  void _selectTheme(ThemeMode mode) {
    widget.themeController.setMode(mode);
    setState(() => _themeExpanded = false);
  }

  // Get label for the current theme mode
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
  
  // Get formatted time label
  String _timeLabel(TimeOfDay t) {
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:${_twoDigits(t.minute)} $ampm';
  }

  // Show custom themed time picker dialog
  Future<void> _showCustomTimePicker(TimeOfDay currentTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkgold,
              onPrimary: Colors.white,
              surface: AppColors.offwhite,
              onSurface: AppColors.textPrimary,
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
    // Save the picked time if not null
    if (picked != null) {
      await ReminderSettingsService.setTime(picked);
    }
  }

  @override
  // Build the settings page UI
  Widget build(BuildContext context) {
    // Determine if dark mode is enabled
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Set background color based on theme
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
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
      // Body with list of settings options
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: 10),

          // Theme setting card
          _Card(
            isDark: isDark,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Theme label
                            Text(
                              'Theme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.getPrimaryText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // Current theme mode label
                              _modeLabel(widget.themeController.mode),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.getSecondaryText(context),
                              ),
                            ),
                          ],
                        ),

                        // Dropdown arrow icon with rotation animation
                        AnimatedRotation(
                          turns: _themeExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.getSecondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dropdown area with theme options
                _SlideDown(
                  expanded: _themeExpanded,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Divider line
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      ),
                      const SizedBox(height: 8),
                        
                      _ThemeRow(
                        // System theme option
                        label: 'System',
                        selected: widget.themeController.mode == ThemeMode.system,
                        onTap: () => _selectTheme(ThemeMode.system),
                        isDark: isDark,
                      ),
                      _ThemeRow(
                        // Light theme option
                        label: 'Light',
                        selected: widget.themeController.mode == ThemeMode.light,
                        onTap: () => _selectTheme(ThemeMode.light),
                        isDark: isDark,
                      ),
                      _ThemeRow(
                        // Dark theme option
                        label: 'Dark',
                        selected: widget.themeController.mode == ThemeMode.dark,
                        onTap: () => _selectTheme(ThemeMode.dark),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Section label for reminders
          Text(
            'Reminders',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: 10),

          // Daily reminder setting card
          _Card(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getPrimaryText(context),
                  ),
                ),
                // Subtext explaining the reminder feature
                const SizedBox(height: 6),
                Text(
                  'Get a notification each day to read your verse.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getSecondaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                // Toggle switch to enable or disable daily reminders
                ValueListenableBuilder<bool>(
                  valueListenable: ReminderSettingsService.enabled,
                  builder: (_, enabled, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Label for the reminder toggle
                        Text(
                          'Enable reminder',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getPrimaryText(context),
                          ),
                        ),
                        // Switch to enable/disable reminders
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
                // Time picker option, only enabled if reminders are enabled
                ValueListenableBuilder<bool>(
                  valueListenable: ReminderSettingsService.enabled,
                  builder: (_, enabled, __) {
                    return ValueListenableBuilder<TimeOfDay>(
                      valueListenable: ReminderSettingsService.time,
                      builder: (_, t, __) {
                        return InkWell(
                          // Disable CustomTimePicker if reminders are not enabled
                          onTap: enabled ? () => _showCustomTimePicker(t) : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            // Dim the time picker option if reminders are disabled and adjust border color accordingly
                            decoration: BoxDecoration(
                              color: enabled
                                  ? AppColors.getSurface(context)
                                  : AppColors.getSurface(context).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: enabled
                                    ? (isDark
                                        ? AppColors.darkgold.withOpacity(0.3)
                                        : AppColors.softgold.withOpacity(0.5))
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            // Row layout for time label and clock icon
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: enabled
                                        ? AppColors.getPrimaryText(context)
                                        : AppColors.getSecondaryText(context),
                                  ),
                                ),
                                // Display the selected time with a clock icon, dimmed if disabled
                                Row(
                                  children: [
                                    Text(
                                      _timeLabel(t),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: enabled
                                            ? AppColors.darkgold
                                            : AppColors.getSecondaryText(context),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      // Clock icon next to the time label, also dimmed if disabled
                                      Icons.access_time,
                                      size: 18,
                                      color: enabled
                                          ? AppColors.darkgold
                                          : AppColors.getSecondaryText(context),
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

// Reusable card widget with dynamic styling based on theme
class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  // Build the card with appropriate colors, borders, and shadows based on the theme
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Custom widget to animate the expansion and collapse of the theme options dropdown
class _SlideDown extends StatelessWidget {
  final bool expanded;
  final Widget child;

  const _SlideDown({
    required this.expanded,
    required this.child,
  });

  @override
  // Build the animated dropdown using AnimatedAlign to smoothly transition the height
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

// Widget for each theme option row in the dropdown with selection indicator and tap handling
class _ThemeRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeRow({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  // Build the theme option row with a radio button icon indicating selection and appropriate colors based on the theme
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
              color: selected 
                  ? AppColors.darkgold 
                  : AppColors.getSecondaryText(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected 
                    ? AppColors.darkgold 
                    : AppColors.getPrimaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}