import 'package:bible/pages/home_screen.dart';
import 'package:bible/pages/saved_verses.dart';
import 'package:bible/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:bible/services/bible_service.dart';
import 'package:bible/services/saved_verses_service.dart';
import 'theme_controller.dart';
import 'services/notification_service.dart';
import 'services/reminder_settings_service.dart';

final themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BibleService.loadVerses();
  await SavedVersesService.init();
await NotificationService.init();
await ReminderSettingsService.init();

  await themeController.load(); // load saved theme
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: themeController.mode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),

      home: HomeScreen(),
      routes: {
        '/homescreen': (context) => HomeScreen(),
        '/savedverses': (context) => SavedVerses(),
        '/settings': (context) => Settings(themeController: themeController),
      },
    );
  }
}
