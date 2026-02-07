import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bible/models/verse.dart';
import 'package:bible/services/bible_service.dart';
import 'package:bible/services/saved_verses_service.dart';

import 'package:bible/components/daily_verse.dart';
import 'package:bible/pages/saved_verses.dart';

import 'package:google_fonts/google_fonts.dart';



/// App Colors
class AppColors {
  AppColors._();

  static const Color offwhite = Color(0xFFFAFBF8);
  static const Color white = Color(0xFFFFFFFF);

  static const Color gold = Color(0xFFFFF9B2);
  static const Color softgold = Color(0xFFFFF8BF);
  static const Color darkgold = Color(0xFFE0C869);

  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF7A7A7A);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Pages for bottom navigation bar
  final List<Widget> _pages = const [
    HomeTab(),
    SavedVerses(),
  ];
  // Bottom navigation bar index change handler
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
/ / Main build method for home screen with app bar, body, and bottom navigation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // App bar with cross icon, title, and settings button
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        // Cross icon
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/icons/cross.svg',
            colorFilter: const ColorFilter.mode(
              AppColors.darkgold,
              BlendMode.srcIn,
            ),
          ),
        ),
        // App title with custom font
        title: Text(
          'My Daily Verse',
          style: GoogleFonts.greatVibes(
            color: AppColors.darkgold,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Settings icon
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            color: AppColors.darkgold,
            onPressed: () {
              Navigator.pushNamed(
                context, '/settings'
              );
            },
          ),
        ],
      ),
      // Display selected page based on bottom navigation index
      body: _pages[_selectedIndex],
      // Bottom navigation bar with Home and Saved tabs
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.offwhite,
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        selectedItemColor: AppColors.darkgold,
        unselectedItemColor: AppColors.darkgold,
        showUnselectedLabels: true,
        elevation: 8,
        // Custom styles for selected and unselected tabs
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        // Custom icons with underline indicator for selected tab
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Container(
                  height: 3,
                  width: 24,
                  color: _selectedIndex == 0
                      ? AppColors.darkgold
                      : Colors.transparent,
                ),
                const SizedBox(height: 4),
                const Icon(Icons.home_filled),
              ],
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Container(
                  height: 3,
                  width: 24,
                  color: _selectedIndex == 1
                      ? AppColors.darkgold
                      : Colors.transparent,
                ),
                const SizedBox(height: 4),
                const Icon(Icons.bookmark),
              ],
            ),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

// Home tab with verse logic
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Verse _currentVerse;
  bool _isGenerating = false;
  // Initialize current verse with verse of the day on widget initialization
  @override
  void initState() {
    super.initState();
    _currentVerse = BibleService.getVerseOfTheDay(DateTime.now());
  }
  // Generate a new random verse and update state
  void _generateNewVerse() async {
    setState(() {
      _isGenerating = true;
    });
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      _currentVerse = BibleService.getRandomVerse();
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Daily verse card with save/unsave function
        ValueListenableBuilder<List<Verse>>(
          valueListenable: SavedVersesService.saved,
          builder: (_, saved, __) {
            final isSaved =
                SavedVersesService.isSaved(_currentVerse);
            // Return DailyVerse widget with current verse and save status
            return DailyVerse(
              verse: _currentVerse,
              isSaved: isSaved,
              onToggleSave: () {
                SavedVersesService.toggleSave(_currentVerse);
              },
            );
          },
        ),

        const SizedBox(height: 12),

        // Generate new verse button with loading state
        AnimatedScale(
          scale: _isGenerating ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // Disable button while generating new verse to prevent multiple taps
              onTap: _isGenerating ? null : _generateNewVerse,
              borderRadius: BorderRadius.circular(12),
              splashColor: AppColors.gold.withOpacity(0.3),
              highlightColor: AppColors.gold.withOpacity(0.2),
              child: Ink(
                decoration: BoxDecoration(
                  color: _isGenerating
                    ? AppColors.darkgold.withOpacity(0.7)
                    : AppColors.darkgold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkgold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  // Button content with loading indicator and text
                  child : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_isGenerating)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      if (_isGenerating) const SizedBox(width: 12),
                      Text(
                        _isGenerating ? 'Generating...' : 'Generate New Verse',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
