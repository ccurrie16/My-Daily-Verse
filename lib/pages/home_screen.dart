import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bible/models/verse.dart';
import 'package:bible/services/bible_service.dart';
import 'package:bible/services/saved_verses_service.dart';

import 'package:bible/components/daily_verse.dart';
import 'package:bible/pages/saved_verses.dart';

import 'package:google_fonts/google_fonts.dart';



/// 🎨 App-wide colors
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

  final List<Widget> _pages = const [
    HomeTab(),
    SavedVerses(),
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,

        /// ✝️ Cross icon (top-left)
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

        title: Text(
          'My Daily Verse',
          style: GoogleFonts.greatVibes(
            color: AppColors.darkgold,
            fontWeight: FontWeight.w600,
          ),
        ),

        /// ⚙️ Settings icon (top-right)
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

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.offwhite,
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        selectedItemColor: AppColors.darkgold,
        unselectedItemColor: AppColors.darkgold,
        showUnselectedLabels: true,
        elevation: 8,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),

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

/// 🏠 Home tab with verse logic
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Verse _currentVerse;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _currentVerse = BibleService.getVerseOfTheDay(DateTime.now());
  }

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
        /// 🔖 Daily verse card with save support
        ValueListenableBuilder<List<Verse>>(
          valueListenable: SavedVersesService.saved,
          builder: (_, saved, __) {
            final isSaved =
                SavedVersesService.isSaved(_currentVerse);

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

        /// 🔄 Generate new verse button
        AnimatedScale(
          scale: _isGenerating ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isGenerating ? null : _generateNewVerse,
              borderRadius: BorderRadius: BorderRadius.circular(12),
              splashColor: AppColors.gold.withOpacity(0.3),
              highlightColor: AppColors.gold.withOpacity(0.2),
              child: Ink(
                decoration: BoxDecoration(
                  color: _isGenerating
                    ? AppColors.darkgold.withOpacity(0.7)
                    : AppColors.darkgold,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    boxShadow(
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
