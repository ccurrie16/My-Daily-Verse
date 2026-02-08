import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:bible/models/verse.dart';

// Service to load and provide Bible verses
class BibleService {
  static final _rand = Random();
  static List<Verse> _verses = [];
  // Load verses from the JSON file in assets
  static Future<void> loadVerses() async {
    final jsonString =
        await rootBundle.loadString('assets/bible/KJV.json');

    final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
    // Convert JSON data to a list of Verse objects
    _verses = data
        .map((e) => Verse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  // Get a random verse from the loaded verses
  static Verse getRandomVerse() {
    // Handle case where verses are not yet loaded
    if (_verses.isEmpty) {
      return const Verse(reference: '', text: 'Verses not loaded yet.');
    }
    // Return a random verse
    return _verses[_rand.nextInt(_verses.length)];
  }

  // Get the verse of the day based on the provided date
  static Verse getVerseOfTheDay(DateTime date) {
    // Handle case where verses are not yet loaded
    if (_verses.isEmpty) {
      return const Verse(reference: '', text: 'Verses not loaded yet.');
    }
    // Calculate a unique key for the day
    final dayKey = date.year * 10000 + date.month * 100 + date.day;
    final index = dayKey % _verses.length;
    return _verses[index];
  }
}
