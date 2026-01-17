import 'package:bible/pages/home_screen.dart';
import 'package:bible/pages/saved_verses.dart';
import 'package:bible/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:bible/services/bible_service.dart';
import 'package:bible/services/saved_verses_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BibleService.loadBible(); 
  await SavedVersesService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        '/homescreen': (context) => HomeScreen(),
        '/savedverses': (context) => SavedVerses(),
        '/settings': (context) => Settings(),
      }
    );
  }
}