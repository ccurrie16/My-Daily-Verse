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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.offwhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softgold, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // top-right save icon
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onToggleSave,
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                ),
                color: AppColors.darkgold,
                tooltip: isSaved ? "Unsave" : "Save",
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: Text(
                  verse.text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              verse.reference,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
