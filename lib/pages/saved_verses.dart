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
              child: Text(
                "No saved verses yet.\nTap the bookmark to save one.",
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: savedList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final v = savedList[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offwhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.softgold, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.reference,
                      style: GoogleFonts.cormorantGaramond(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkgold,
                        fontSize: 18,
                      ),
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => SavedVersesService.remove(v),
                        child: Text(
                          "Remove",
                          style: GoogleFonts.libreBaskerville(
                            color: AppColors.darkgold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
