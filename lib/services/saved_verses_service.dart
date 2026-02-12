import 'package:flutter/foundation.dart';
import 'package:bible/models/verse.dart';
import 'package:bible/services/cloud_saved_verses_service.dart';

/// Service to manage saved verses
/// Delegates to CloudSavedVersesService for authenticated users
/// Falls back to local-only storage for non-authenticated users
class SavedVersesService {
  SavedVersesService._();

  // ValueNotifier to track the list of saved verses (delegates to cloud service)
  static ValueNotifier<List<Verse>> get saved => CloudSavedVersesService.saved;

  // Initialize saved verses from cloud or local storage
  static Future<void> init() async {
    await CloudSavedVersesService.init();
  }

  // Check if a verse is already saved
  static bool isSaved(Verse verse) {
    return CloudSavedVersesService.isSaved(verse);
  }

  // Save if not saved, otherwise remove
  static Future<void> toggleSave(Verse verse) async {
    await CloudSavedVersesService.toggleSave(verse);
  }

  // Remove a specific verse from saved verses (soft delete)
  static Future<void> remove(Verse verse) async {
    await CloudSavedVersesService.remove(verse);
  }

  // Clear all saved verses
  static Future<void> clearAll() async {
    await CloudSavedVersesService.clearAll();
  }

  // Add a verse to saved verses
  static Future<void> add(Verse verse) async {
    await CloudSavedVersesService.add(verse);
  }

  // Get deleted verses for recovery
  static List<Verse> getDeletedVerses() =>
      CloudSavedVersesService.getDeletedVerses();

  // Recover a soft-deleted verse
  static Future<void> recover(Verse deletedVerse) async {
    await CloudSavedVersesService.recover(deletedVerse);
  }

  // Permanently delete a verse (hard delete)
  static Future<void> hardDelete(Verse verse) async {
    await CloudSavedVersesService.hardDelete(verse);
  }

  // Manually sync with cloud
  static Future<void> syncWithCloud() async {
    await CloudSavedVersesService.syncWithCloud();
  }
}
