import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bible/models/verse.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to manage saved verses with cloud synchronization
/// Features:
/// - Automatic sync to Firestore
/// - Offline caching with SharedPreferences
/// - Conflict resolution (last-write-wins with timestamps)
/// - Soft delete support with recovery
/// - Real-time updates from cloud
class CloudSavedVersesService {
  CloudSavedVersesService._();

  static const String _localCacheKey = 'saved_verses_cache';
  static const String _pendingSyncKey = 'pending_sync_operations';
  static const String _collectionName = 'saved_verses';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Connectivity _connectivity = Connectivity();

  // ValueNotifier to track the list of saved verses
  static final ValueNotifier<List<Verse>> saved =
      ValueNotifier<List<Verse>>(<Verse>[]);

  // ValueNotifier to track sync status
  static final ValueNotifier<bool> isSynced = ValueNotifier<bool>(true);

  // ValueNotifier to track deleted verses (for recovery)
  static final ValueNotifier<List<Verse>> deletedVerses =
      ValueNotifier<List<Verse>>(<Verse>[]);

  /// Initialize the service and load verses from cache/cloud
  static Future<void> init() async {
    try {
      // Load from local cache first
      await _loadFromCache();

      // If user is authenticated, sync with cloud
      if (_auth.currentUser != null) {
        await syncWithCloud();

        // Listen for real-time updates from Firestore
        _listenToCloudUpdates();
      }
    } catch (e) {
      print('Error initializing CloudSavedVersesService: $e');
      // Fail safely - use cached data
    }
  }

  /// Load saved verses from local cache
  static Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_localCacheKey);

      if (cached == null || cached.trim().isEmpty) {
        saved.value = <Verse>[];
        deletedVerses.value = <Verse>[];
        return;
      }

      final decoded = jsonDecode(cached);
      final List<dynamic> verses = decoded['verses'] ?? [];
      final List<dynamic> deleted = decoded['deleted'] ?? [];

      saved.value = verses
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .where((v) => v.deletedAt == null)
          .toList();

      deletedVerses.value = deleted
          .map((v) => Verse.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading cache: $e');
      saved.value = <Verse>[];
      deletedVerses.value = <Verse>[];
    }
  }

  /// Save the current list to local cache
  static Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'verses': saved.value.map((v) => v.toJson()).toList(),
        'deleted': deletedVerses.value.map((v) => v.toJson()).toList(),
      };
      await prefs.setString(_localCacheKey, jsonEncode(data));
    } catch (e) {
      print('Error saving to cache: $e');
    }
  }

  /// Sync with Firestore
  static Future<void> syncWithCloud() async {
    if (_auth.currentUser == null) return;

    final user = _auth.currentUser!;
    isSynced.value = false;

    try {
      // Process any pending operations first
      await _processPendingOperations();

      // Fetch all verses from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_collectionName)
          .get();

      final cloudVerses = snapshot.docs.map((doc) {
        final data = {...doc.data(), 'id': doc.id};
        return Verse.fromJson(data);
      }).toList();

      // Merge local and cloud data with conflict resolution
      await _mergeWithCloudData(cloudVerses);

      isSynced.value = true;
    } catch (e) {
      print('Error syncing with cloud: $e');
      isSynced.value = false;
    }
  }

  /// Merge local data with cloud data using conflict resolution
  static Future<void> _mergeWithCloudData(List<Verse> cloudVerses) async {
    final merged = <Verse>[];
    final processed = <String>{};

    // Start with local verses
    for (final local in saved.value) {
      processed.add(local.reference);

      // Find matching cloud verse
      final cloudVerse = cloudVerses.firstWhere(
        (v) => v.reference == local.reference,
        orElse: () => local,
      );

      // Conflict resolution: last-write-wins with timestamp
      if (cloudVerse.reference == local.reference) {
        final winner = local.modifiedAt.isAfter(cloudVerse.modifiedAt)
            ? local
            : cloudVerse;
        merged.add(winner);
      } else {
        merged.add(local);
      }
    }

    // Add cloud verses that don't exist locally
    for (final cloud in cloudVerses) {
      if (!processed.contains(cloud.reference) && cloud.deletedAt == null) {
        merged.add(cloud);
      }
    }

    saved.value = merged;
    await _saveToCache();
  }

  /// Listen to real-time updates from Firestore
  static void _listenToCloudUpdates() {
    if (_auth.currentUser == null) return;

    final user = _auth.currentUser!;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection(_collectionName)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        final docData = change.doc.data();
        if (docData == null) continue;
        final data = {...docData, 'id': change.doc.id};
        final verse = Verse.fromJson(data);

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            // Update or add verse
            final index =
                saved.value.indexWhere((v) => v.reference == verse.reference);
            if (index >= 0) {
              final current = saved.value[index];
              // Only update if cloud is newer
              if (verse.modifiedAt.isAfter(current.modifiedAt)) {
                final updated = List<Verse>.from(saved.value);
                updated[index] = verse;
                saved.value = updated;
              }
            } else if (verse.deletedAt == null) {
              saved.value = [...saved.value, verse];
            }
            break;

          case DocumentChangeType.removed:
            // Mark as deleted
            final index =
                saved.value.indexWhere((v) => v.reference == verse.reference);
            if (index >= 0) {
              final deleted = List<Verse>.from(saved.value);
              deleted.removeAt(index);
              saved.value = deleted;
            }
            break;
        }
      }
      _saveToCache();
    });
  }

  /// Check if a verse is already saved
  static bool isSaved(Verse verse) {
    return saved.value.any((v) => v.reference == verse.reference);
  }

  /// Toggle save status (add if not saved, remove if saved)
  static Future<void> toggleSave(Verse verse) async {
    final isSavedNow = isSaved(verse);

    if (isSavedNow) {
      await remove(verse);
    } else {
      await add(verse);
    }
  }

  /// Add a verse to saved list
  static Future<void> add(Verse verse) async {
    final now = DateTime.now();
    final newVerse = verse.copyWith(
      createdAt: verse.createdAt == DateTime(0) ? now : verse.createdAt,
      modifiedAt: now,
      deletedAt: null, // Restore if previously deleted
    );

    // Add to local list (newest on top)
    saved.value = [newVerse, ...saved.value];
    await _saveToCache();

    // Upload to Firestore
    if (_auth.currentUser != null) {
      await _addToPendingSync(
        operation: 'add',
        verse: newVerse,
      );
      await _syncVersesToCloud([newVerse]);
    }
  }

  /// Remove a verse from saved list (soft delete)
  static Future<void> remove(Verse verse) async {
    final now = DateTime.now();
    final deletedVerse = verse.copyWith(
      modifiedAt: now,
      deletedAt: now,
    );

    // Remove from active list
    final updated =
        saved.value.where((v) => v.reference != verse.reference).toList();
    saved.value = updated;

    // Add to deleted verses for recovery
    deletedVerses.value = [...deletedVerses.value, deletedVerse];
    await _saveToCache();

    // Upload to Firestore
    if (_auth.currentUser != null) {
      await _addToPendingSync(
        operation: 'delete',
        verse: deletedVerse,
      );
      await _syncVersesToCloud([deletedVerse]);
    }
  }

  /// Permanently delete a verse (hard delete)
  static Future<void> hardDelete(Verse verse) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection(_collectionName)
          .doc(verse.reference)
          .delete();

      deletedVerses.value = deletedVerses.value
          .where((v) => v.reference != verse.reference)
          .toList();
      await _saveToCache();
    } catch (e) {
      print('Error hard deleting verse: $e');
    }
  }

  /// Recover a soft-deleted verse
  static Future<void> recover(Verse deletedVerse) async {
    final now = DateTime.now();
    final recovered = deletedVerse.copyWith(
      modifiedAt: now,
      deletedAt: null,
    );

    saved.value = [recovered, ...saved.value];
    deletedVerses.value = deletedVerses.value
        .where((v) => v.reference != deletedVerse.reference)
        .toList();
    await _saveToCache();

    if (_auth.currentUser != null) {
      await _syncVersesToCloud([recovered]);
    }
  }

  /// Clear all saved verses
  static Future<void> clearAll() async {
    final now = DateTime.now();
    // Mark all as deleted instead of removing
    deletedVerses.value = saved.value
        .map((v) => v.copyWith(modifiedAt: now, deletedAt: now))
        .toList();
    saved.value = <Verse>[];
    await _saveToCache();

    if (_auth.currentUser != null) {
      await _syncVersesToCloud(deletedVerses.value);
    }
  }

  /// Sync verses to Firestore
  static Future<void> _syncVersesToCloud(List<Verse> verses) async {
    if (_auth.currentUser == null) return;

    try {
      final user = _auth.currentUser!;
      final batch = _firestore.batch();

      for (final verse in verses) {
        final ref = _firestore
            .collection('users')
            .doc(user.uid)
            .collection(_collectionName)
            .doc(verse.reference);

        if (verse.deletedAt != null) {
          // Soft delete: update with deletedAt timestamp
          batch.set(
            ref,
            verse.toJson(),
            SetOptions(merge: true),
          );
        } else {
          // Add/update verse
          batch.set(
            ref,
            {
              ...verse.toJson(),
              'syncedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error syncing to cloud: $e');
    }
  }

  /// Add operation to pending sync queue
  static Future<void> _addToPendingSync({
    required String operation,
    required Verse verse,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending =
          jsonDecode(prefs.getString(_pendingSyncKey) ?? '[]') as List;

      pending.add({
        'operation': operation,
        'verse': verse.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_pendingSyncKey, jsonEncode(pending));
    } catch (e) {
      print('Error adding to pending sync: $e');
    }
  }

  /// Process pending sync operations
  static Future<void> _processPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending =
          jsonDecode(prefs.getString(_pendingSyncKey) ?? '[]') as List;

      if (pending.isEmpty) return;

      final versesToSync = <Verse>[];
      for (final op in pending) {
        final verse = Verse.fromJson(op['verse']);
        versesToSync.add(verse);
      }

      await _syncVersesToCloud(versesToSync);

      // Clear pending operations after successful sync
      await prefs.setString(_pendingSyncKey, jsonEncode([]));
    } catch (e) {
      print('Error processing pending operations: $e');
    }
  }

  /// Get deleted verses that can be recovered
  static List<Verse> getDeletedVerses() => deletedVerses.value;

  /// Temporarily pause syncing (e.g., during migrations)
  static Future<void> pauseSync() async {
    isSynced.value = false;
  }

  /// Resume syncing
  static Future<void> resumeSync() async {
    await syncWithCloud();
  }
}
