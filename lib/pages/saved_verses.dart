import 'package:flutter/material.dart';
import 'package:bible/pages/home_screen.dart';

class SavedVerses extends StatelessWidget {
  const SavedVerses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.white,
    body: Center(
      child: Text("Saved verses will appear here",
      style: TextStyle(
          fontSize: 24,
          color: AppColors.textPrimary),
      ),
      ),
    );
  }
}