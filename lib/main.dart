import 'package:bible/pages/home_screen.dart';
import 'package:bible/pages/saved_verses.dart';
import 'package:bible/pages/settings.dart';
import 'package:flutter/material.dart';

import 'package:bible/services/bible_service.dart';
import 'package:bible/services/saved_verses_service.dart';
import 'theme_controller.dart';
import 'services/notification_service.dart';
import 'services/reminder_settings_service.dart';
import 'components/loading_screen.dart';

// Firebase and Authentication imports - added for user authentication
import 'package:firebase_core/firebase_core.dart';
import 'package:bible/services/auth_service.dart';
import 'package:bible/pages/auth_screen.dart';
import 'firebase_options.dart'; // ✅ Added semicolon

// Initialize ThemeController
final themeController = ThemeController();
 
// ✅ Only ONE main() function
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - required for authentication
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase initialization fails, log but continue
    debugPrint('Firebase initialization error: $e');
  }
  
  await BibleService.loadVerses();
  await SavedVersesService.init();
  await NotificationService.init();
  await ReminderSettingsService.init();

  // Load the saved theme mode before running the app
  await themeController.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  
  // Track authentication state - added for user authentication
  bool _isAuthenticated = false;
  bool _hasCompletedSignup = false;

  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  // Check if user is authenticated and has completed signup
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    try {
      final hasCompletedSignup = await AuthService.hasCompletedSignup();
      final isAuthenticated = AuthService.currentUser != null;
      
      if (mounted) {
        setState(() {
          _hasCompletedSignup = hasCompletedSignup;
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If auth check fails, just show home screen (auth disabled)
      if (mounted) {
        setState(() {
          _hasCompletedSignup = true;
          _isAuthenticated = true;
          _isLoading = false;
        });
      }
    }
  }
  
  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeController.mode,

      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE0C869),
          secondary: Color(0xFFFFF9B2),
          surface: Color(0xFFFAFBF8),
          onPrimary: Colors.white,
          onSecondary: Color(0xFF2B2B2B),
          onSurface: Color(0xFF2B2B2B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFFE0C869),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFAFBF8),
          selectedItemColor: Color(0xFFE0C869),
          unselectedItemColor: Color(0xFFE0C869),
        ),
      ),
      
      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE0C869),
          secondary: Color(0xFFFFF9B2),
          surface: Color(0xFF2B2B2B),
          onPrimary: Color(0xFF1A1A1A),
          onSecondary: Colors.white,
          onSurface: Color(0xFFFAFBF8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Color(0xFFE0C869),
          elevation: 0,
        ),
        // ✅ Fixed: Changed from bottomNavigationBarThemeData to bottomNavigationBarTheme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2B2B2B),
          selectedItemColor: Color(0xFFE0C869),
          unselectedItemColor: Color(0xFFE0C869),
        ),
      ),
      
      home: _isLoading
          ? const LoadingScreen()
          : (!_hasCompletedSignup || !_isAuthenticated)
              ? const AuthScreen()
              : const HomeScreen(),
      
      routes: {
        '/homescreen': (context) => const HomeScreen(),
        '/savedverses': (context) => const SavedVerses(),
        '/settings': (context) => Settings(themeController: themeController),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}