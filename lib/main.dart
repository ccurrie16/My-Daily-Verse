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

// Initialize ThemeController
final themeController = ThemeController();
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - required for authentication
  await Firebase.initializeApp();
  
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
  // Add a listener to the ThemeController to rebuild the app when the theme changes
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);

    // Check authentication status and signup completion - added for user authentication
    _checkAuthStatus();
  }

  @override
  // Remove the listener when the widget is disposed to prevent memory leaks
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  // Check if user is authenticated and has completed signup - added for user authentication
  Future<void> _checkAuthStatus() async {
    // Simulate loading time for the splash screen
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Check if user has completed signup before
    final hasCompletedSignup = await AuthService.hasCompletedSignup();
    
    // Check if user is currently signed in
    final isAuthenticated = AuthService.currentUser != null;
    
    if (mounted) {
      setState(() {
        _hasCompletedSignup = hasCompletedSignup;
        _isAuthenticated = isAuthenticated;
        _isLoading = false;
      });
    }
  }
  
  // Callback function to rebuild the app when the theme changes
  void _onThemeChanged() => setState(() {});

  @override
  // Builds the MaterialApp with light and dark themes, and sets the home screen based on auth state
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Set the theme mode based on the ThemeController's current mode
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
        bottomNavigationBarThemeData: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2B2B2B),
          selectedItemColor: Color(0xFFE0C869),
          unselectedItemColor: Color(0xFFE0C869),
        ),
      ),
      
      // Show appropriate screen based on loading and authentication state - updated for authentication
      home: _isLoading
          ? const LoadingScreen()
          : (!_hasCompletedSignup || !_isAuthenticated)
              ? const AuthScreen() // Show auth screen if user hasn't signed up or isn't authenticated
              : const HomeScreen(), // Show home screen if authenticated
      
      // Define the routes for navigation to different screens in the app
      routes: {
        '/homescreen': (context) => const HomeScreen(),
        '/savedverses': (context) => const SavedVerses(),
        '/settings': (context) => Settings(themeController: themeController),
        '/auth': (context) => const AuthScreen(), // Added auth screen route
      },
    );
  }
}