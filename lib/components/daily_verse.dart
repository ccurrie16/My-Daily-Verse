import 'package:flutter/material.dart';
import 'package:bible/pages/home_screen.dart';
import 'package:bible/models/verse.dart';


class DailyVerse extends StatelessWidget {
  final Verse verse;

  const DailyVerse({
    super.key,
    required this.verse,
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        height: 400,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.offwhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.softgold,
            width: 3,),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset (0, 4),
          )
        ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            
            Text(
              verse.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            SizedBox(height: 12),
            Text(
              verse.reference,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ))
          ],
        ),
      ),
    );
  }
}