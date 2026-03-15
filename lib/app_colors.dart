import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color offwhite = Color(0xFFFAFBF8);
  static const Color white = Color(0xFFFFFFFF);

  static const Color gold = Color(0xFFFFF9B2);
  static const Color softgold = Color(0xFFFFF8BF);
  static const Color darkgold = Color(0xFFE0C869);

  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF7A7A7A);

  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2B2B2B);
  static const Color darkTextPrimary = Color(0xFFFAFBF8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : white;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : offwhite;
  }

  static Color getPrimaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color getSecondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }
}
