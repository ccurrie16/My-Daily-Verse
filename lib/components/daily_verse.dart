import 'package:flutter/material.dart';
import 'package:bible/pages/home_screen.dart';
import 'package:bible/models/verse.dart';
import 'package:google_fonts/google_fonts.dart';


class DailyVerse extends StatelessWidget {
  final Verse verse;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const DailyVerse({
    super.key,
    required this.verse,
    required this.isSaved,
    required this.onToggleSave,
  });

  // Widget for daily verse card with save/unsave function
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkgold.withOpacity(0.3)
                : AppColors.softgold,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: AppColors.darkgold.withOpacity(isDark ? 0.1 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Column layout for verse text, reference, and save button
        child: Column(
          children: [
            Align(
              // Save/Unsave button at the top right corner
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onToggleSave,
                // AnimatedSwitcher for smooth icon transition
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    key: ValueKey<bool>(isSaved),
                  ),
                ),
                color: AppColors.darkgold,
                iconSize: 28,
                tooltip: isSaved ? "Unsave" : "Save",
              ),
            ),

            const SizedBox(height: 8),
          // Verse text in the center of Daily Verse card
            Expanded(
              child: Center(
                child: Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: AppColors.getPrimaryText(context),
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Verse reference at the bottom of Daily Verse card
            Text(
              verse.reference,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppColors.getSecondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}