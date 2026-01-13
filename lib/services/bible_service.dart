import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:bible/models/verse.dart';

class BibleService {
  static Map<String, dynamic>? _bible;
  static final Random _rand = Random();

  static final List<Verse> _allVerses = [];

  static Future<void> loadBible() async {
    final jsonString = await rootBundle.loadString('assets/bible/KJV.json');
    _bible = json.decode(jsonString) as Map<String, dynamic>;

    _allVerses.clear();

    final List<dynamic> books = _bible!['books'] as List<dynamic>;
    for (final b in books) {
      final book = b as Map<String, dynamic>;
      final String bookName = book['name'] as String;

      final List<dynamic> chapters = book['chapters'] as List<dynamic>;
      for (final c in chapters) {
        final chapterObj = c as Map<String, dynamic>;
        final int chapterNum = chapterObj['chapter'] as int;

        final List<dynamic> verses = chapterObj['verses'] as List<dynamic>;
        for (final v in verses) {
          final verseObj = v as Map<String, dynamic>;
          final int verseNum = verseObj['verse'] as int;
          final String text = (verseObj['text'] as String).trim();

          _allVerses.add(
            Verse(
              text: text,
              reference: '$bookName $chapterNum:$verseNum',
            ),
          );
        }
      }
    }
  }

  static Verse getRandomVerse() {
    if (_allVerses.isEmpty) throw Exception("Bible not loaded");
    return _allVerses[_rand.nextInt(_allVerses.length)];
  }

  static Verse getVerseOfTheDay(DateTime date) {
    if (_allVerses.isEmpty) throw Exception("Bible not loaded");

    final int seed = (date.year * 10000) + (date.month * 100) + date.day;
    final int index = seed % _allVerses.length;

    return _allVerses[index];
  }
}