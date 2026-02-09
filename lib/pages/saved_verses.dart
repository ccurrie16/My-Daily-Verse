import 'package:flutter/material.dart';
import 'package:bible/models/verse.dart';
import 'package:bible/pages/home_screen.dart';
import 'package:bible/services/saved_verses_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedVerses extends StatelessWidget {
  const SavedVerses({super.key});
  // Page displaying list of saved verses with option to remove them
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: ValueListenableBuilder<List<Verse>>(
        valueListenable: SavedVersesService.saved,
        // Build UI based on the list of saved verses
        builder: (context, savedList, _) {
          // Show message when no verses are saved
          if (savedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder icon for no saved verses
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: AppColors.darkgold.withOpacity(0.3),
                  ),
                  // Message encouraging users to save verses when no saved verses are present
                  const SizedBox(height: 24),
                  Text(
                    "Start Building Your Collection",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getPrimaryText(context),
                    ),
                  ),
                  // Subtext encouraging users to save verses
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      "Save verses that speak to you by tapping the bookmark icon",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        color: AppColors.getSecondaryText(context),
                        height: 1.5
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // List view of saved verses with reference, text, and remove button
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: savedList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final v = savedList[index];
              // Animated container for each saved verse with remove button
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                     ? AppColors.darkgold.withOpacity(0.3) 
                     : AppColors.softgold,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            v.reference,
                            style: GoogleFonts.cormorantGaramond(
                               fontWeight: FontWeight.w700,
                                color: AppColors.darkgold,
                                fontSize: 18,
                            ),
                          ),
                        ),
                        // Remove from saved verses button
                        IconButton(
                          onPressed: () => SavedVersesService.remove(v),
                          icon: const Icon(Icons.bookmark_remove),
                          color: AppColors.darkgold,
                          tooltip: "Remove from saved",
                          iconSize: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      v.text,
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.getPrimaryText(context),
                        height: 1.5,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}