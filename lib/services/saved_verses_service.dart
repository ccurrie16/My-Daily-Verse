import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/models/verse.dart';
// Service to manage saved verses
class SavedVersesService {
  SavedVersesService._();

  static const String _key = 'saved_verses';

  // ValueNotifier to track the list of saved verses
  static final ValueNotifier<List<Verse>> saved =
      ValueNotifier<List<Verse>>(<Verse>[]);

  // Initialize saved verses from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    // If no saved verses, start with an empty list
    if (raw == null || raw.trim().isEmpty) {
      saved.value = <Verse>[];
      return;
    }
    try {
      // Decode the JSON string and convert it to a list of Verse objects
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      saved.value = decoded
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If storage ever gets corrupted, fail safely
      saved.value = <Verse>[];
    }
  }
  // Persist the current list of saved verses to SharedPreferences
  static Future<void> _persist() async {
    // Encode the list of Verse objects as a JSON string and save it
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      saved.value.map((v) => v.toJson()).toList(),
    );
    // Save the encoded string to SharedPreferences
    await prefs.setString(_key, encoded);
  }

  // Check if a verse is already saved
  static bool isSaved(Verse verse) {
    return saved.value.any((v) => v.reference == verse.reference);
  }

  // Save if not saved, otherwise remove.
  static Future<void> toggleSave(Verse verse) async {
    final List<Verse> current = List<Verse>.from(saved.value);

    final int index =
        current.indexWhere((v) => v.reference == verse.reference);

    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, verse); // newest on top
    }

    saved.value = current;
    await _persist();
  }

  // Remove a specific verse from saved verses
  static Future<void> remove(Verse verse) async {
    final List<Verse> current = List<Verse>.from(saved.value)
      ..removeWhere((v) => v.reference == verse.reference);

    saved.value = current;
    await _persist();
  }

  // Clear all saved verses
  static Future<void> clearAll() async {
    saved.value = <Verse>[];
    await _persist();
  }
}
