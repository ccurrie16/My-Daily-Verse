import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bible/models/verse.dart';

// Service to manage saved verses with local + Firestore cloud sync
class SavedVersesService {
  SavedVersesService._();

  static const String _key = 'saved_verses';

  // Firestore collection path: users/{uid}/
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ValueNotifier to track the list of saved verses
  static final ValueNotifier<List<Verse>> saved =
      ValueNotifier<List<Verse>>(<Verse>[]);

  // Initialize saved verses from SharedPreferences (local cache)
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
      saved.value = <Verse>[];
    }
  }

  // Sync local verses with Firestore for the current user.
  // Merges cloud + local (union, deduped by reference), then persists both.
  static Future<void> syncWithCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await _userDoc(user.uid).get();
      final List<Verse> cloudVerses = _versesFromDoc(doc);
      final List<Verse> localVerses = List<Verse>.from(saved.value);

      // Merge: keep local order, append any cloud-only verses at the end
      final Set<String> localRefs =
          localVerses.map((v) => v.reference).toSet();
      final List<Verse> merged = [
        ...localVerses,
        ...cloudVerses.where((v) => !localRefs.contains(v.reference)),
      ];

      saved.value = merged;
      await _persistLocal();
      await _persistCloud(user.uid, merged);
    } catch (e) {
      // If cloud sync fails, keep working with local data
      debugPrint('Cloud sync error: $e');
    }
  }

  // Persist the current list to SharedPreferences
  static Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      saved.value.map((v) => v.toJson()).toList(),
    );
    await prefs.setString(_key, encoded);
  }

  // Persist the list to Firestore for the given user
  static Future<void> _persistCloud(String uid, List<Verse> verses) async {
    try {
      await _userDoc(uid).set({
        'savedVerses': verses.map((v) => v.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore write error: $e');
    }
  }

  // Save to both local and cloud
  static Future<void> _persist() async {
    await _persistLocal();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _persistCloud(user.uid, saved.value);
    }
  }

  // Get a reference to the user's Firestore document
  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return _db.collection('users').doc(uid);
  }

  // Parse saved verses from a Firestore document snapshot
  static List<Verse> _versesFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null || data['savedVerses'] == null) return [];
    final List<dynamic> raw = data['savedVerses'] as List<dynamic>;
    return raw
        .map((e) => Verse.fromJson(e as Map<String, dynamic>))
        .toList();
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
