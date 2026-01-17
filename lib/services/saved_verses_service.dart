import 'dart:convert';

import 'package:flutter/foundation.dart'; // ✅ ValueNotifier lives here
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible/models/verse.dart';

class SavedVersesService {
  SavedVersesService._();

  static const String _key = 'saved_verses';

  /// Any widget can listen to this to auto-refresh UI.
  static final ValueNotifier<List<Verse>> saved =
      ValueNotifier<List<Verse>>(<Verse>[]);

  /// Call once in main.dart BEFORE runApp().
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.trim().isEmpty) {
      saved.value = <Verse>[];
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      saved.value = decoded
          .map((e) => Verse.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If storage ever gets corrupted, fail safely.
      saved.value = <Verse>[];
    }
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      saved.value.map((v) => v.toJson()).toList(),
    );
    await prefs.setString(_key, encoded);
  }

  /// Uses reference as the unique ID (safe for KJV).
  static bool isSaved(Verse verse) {
    return saved.value.any((v) => v.reference == verse.reference);
  }

  /// Save if not saved, otherwise remove.
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

  /// Optional helper if you want a "Remove" button.
  static Future<void> remove(Verse verse) async {
    final List<Verse> current = List<Verse>.from(saved.value)
      ..removeWhere((v) => v.reference == verse.reference);

    saved.value = current;
    await _persist();
  }

  /// Optional helper if you want "Clear all saved verses".
  static Future<void> clearAll() async {
    saved.value = <Verse>[];
    await _persist();
  }
}
