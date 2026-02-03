import 'package:flutter/material.dart';
import 'package:bible/models/verse.dart';
import 'package:bible/pages/home_screen.dart';
import 'package:bible/services/saved_verses_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedVerses extends StatelessWidget {
  const SavedVerses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ValueListenableBuilder<List<Verse>>(
        valueListenable: SavedVersesService.saved,
        builder: (context, savedList, _) {
          if (savedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: AppColors.darkgold.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Start Building Your Collection",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height:12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      "Save verses that speak to you by tapping the bookmark icon",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: savedList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final v = savedList[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offwhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.softgold, width: 2),
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
                        color: AppColors.textPrimary,
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

