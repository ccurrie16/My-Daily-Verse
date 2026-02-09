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

// Initialize ThemeController
final themeController = ThemeController();
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  // Add a listener to the ThemeController to rebuild the app when the theme changes
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);

    // Simulate loading time for the splash screen
    Future.delayed(const Duration(milliseconds: 2000), () {
      // After loading is complete update the state to show the HomeScreen
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  // Remove the listener when the widget is disposed to prevent memory leaks
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }
  // Callback function to rebuild the app when the theme changes
  void _onThemeChanged() => setState(() {});

  @override
  // Builds the MaterialApp with light and dark themes, and sets the home screen based on the loading state
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
        bottomNavigationBarTheme: const BottomNavigationBarTheme(
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
        bottomNavigationBarTheme: const BottomNavigationBarTheme(
          backgroundColor: Color(0xFF2B2B2B),
          selectedItemColor: Color(0xFFE0C869),
          unselectedItemColor: Color(0xFFE0C869),
        ),
      ),
      // Show the LoadingScreen while the app is loading, then show the HomeScreen once loading is complete
      home: _isLoading ? const LoadingScreen() : const HomeScreen(),
      
      // Define the routes for navigation to different screens in the app
      routes: {
        '/homescreen': (context) => const HomeScreen(),
        '/savedverses': (context) => const SavedVerses(),
        '/settings': (context) => Settings(themeController: themeController),
      },
    );
  }
}
