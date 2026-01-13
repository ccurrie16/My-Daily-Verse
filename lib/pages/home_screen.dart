import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bible/pages/saved_verses.dart';
import 'package:bible/pages/settings.dart';
import 'package:bible/components/daily_verse.dart';
import 'package:bible/models/verse.dart';
import 'package:bible/services/bible_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppColors {
  AppColors._();
  // Backgrounds
static const Color offwhite = Color(0xFFFAFBF8);
static const Color white = Color(0xFFFFFFFF);

// Accents
static const Color gold = Color(0xFFFFF9b2);
static const Color softgold = Color(0xFFFFF8BF);
static const Color darkgold = Color(0xFFE0C869);

// Text
static const Color textPrimary = Color(0xFF2B2B2B);
static const Color textSecondary = Color(0xFF7A7A7A);
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    }
    );
  }
  final List _pages = [
    HomeTab(),
    SavedVerses(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/cross.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkgold,
                BlendMode.srcIn,
              ),
            ),
         ),
          
          title: const Text(
            'My Daily Verse',
            style: TextStyle(color: AppColors.darkgold,
            fontWeight: FontWeight.w600,
            ),
            ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings,
              size: 28),
              color: AppColors.darkgold,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
              ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.offwhite,
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          selectedItemColor: AppColors.darkgold,
          unselectedItemColor: AppColors.darkgold,

          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          
          showUnselectedLabels: true,
          elevation: 8,
          items: [
            //home
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Container(
                    height: 3,
                    width: 24,
                    color: _selectedIndex == 0
                        ? AppColors.darkgold
                        :Colors.transparent
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.home_filled),
                ],
              ),
              label: 'Home',
            ),
            //saved verses
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Container(
                    height: 3,
                    width: 24,
                    color: _selectedIndex == 1
                        ?AppColors.darkgold
                        :Colors.transparent,
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.bookmark),
                ],
              ),
              label: 'Saved Verses',
            ),
          ],
        ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Verse _current;

  @override
  void initState() {
    super.initState();
    _current = BibleService.getVerseOfTheDay(DateTime.now());
  }


  void _generateNewVerse() {
    setState(() {
      _current = BibleService.getRandomVerse();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DailyVerse(
          verse: _current,
          ),
          const SizedBox(height: 12),
        ElevatedButton(
          onPressed: 
            _generateNewVerse,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkgold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
             padding: EdgeInsets.symmetric(
              horizontal: 24,
               vertical: 14,
            ),
         ),
           child: Text("Generate New Verse"),
          ),

        SizedBox(height: 12),
        Text(
          "Home Screen",
          style: TextStyle(
            fontSize: 24,
            color: AppColors.textPrimary
          ),
        ),
      ],
    );
  }
}