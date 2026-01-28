import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:bible/models/verse.dart';

class BibleService {
  static final _rand = Random();
  static List<Verse> _verses = [];

  static Future<void> loadVerses() async {
    final jsonString =
        await rootBundle.loadString('assets/bible/top_rated_verses.json');

    final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;

    _verses = data
        .map((e) => Verse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Verse getRandomVerse() {
    if (_verses.isEmpty) {
      return const Verse(reference: '', text: 'Verses not loaded yet.');
    }
    return _verses[_rand.nextInt(_verses.length)];
  }

  // Deterministic "daily verse" (same verse for everyone for that date)
  static Verse getVerseOfTheDay(DateTime date) {
    if (_verses.isEmpty) {
      return const Verse(reference: '', text: 'Verses not loaded yet.');
    }

    final dayKey = date.year * 10000 + date.month * 100 + date.day;
    final index = dayKey % _verses.length;
    return _verses[index];
  }
}
