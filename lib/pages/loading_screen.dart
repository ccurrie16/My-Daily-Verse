import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✨ 6. SPLASH/LOADING SCREEN - Branded loading screen with gold cross aesthetic
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color offwhite = Color(0xFFFAFBF8);
    const Color darkgold = Color(0xFFE0C869);
    const Color textSecondary = Color(0xFF7A7A7A);

    return Scaffold(
      backgroundColor: offwhite,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated gold cross icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/cross.svg',
                    width: 80,
                    height: 80,
                    colorFilter: const ColorFilter.mode(
                      darkgold,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                Text(
                  'My Daily Verse',
                  style: GoogleFonts.greatVibes(
                    fontSize: 40,
                    color: darkgold,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'Loading your verses...',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Loading indicator
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(darkgold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}