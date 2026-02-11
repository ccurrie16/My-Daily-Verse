# Cloud Sync for Saved Verses - Implementation Guide

## Overview

Your app now has comprehensive cloud synchronization for saved verses with the following features:

### ✅ Key Features

1. **Automatic Cloud Sync** - Verses are automatically synchronized to Firestore
2. **Offline Support** - Works offline with local caching via SharedPreferences
3. **Multi-Device Sync** - Changes sync across all user devices in real-time
4. **Soft Delete Protection** - Deleted verses are marked as deleted, not removed (can be recovered)
5. **Hard Delete Option** - Permanently delete verses from all devices when needed
6. **Conflict Resolution** - Uses last-write-wins strategy with timestamps
7. **Sync Status Tracking** - Know when the app is synced or syncing

---

## Architecture

### Services

#### `CloudSavedVersesService`
The core service handling all cloud operations:
- Manages Firestore collection: `users/{uid}/saved_verses`
- Handles real-time listeners for cloud updates
- Manages offline queue for pending operations
- Implements conflict resolution logic

#### `SavedVersesService`
Facade wrapper for backward compatibility:
- Delegates to `CloudSavedVersesService`
- Maintains same API as before

### Data Model

The `Verse` model now includes sync metadata:

```dart
class Verse {
  final String reference;      // e.g., "John 3:16"
  final String text;          // The verse content
  final DateTime createdAt;   // When verse was first saved
  final DateTime modifiedAt;  // Last modification time
  final DateTime? deletedAt;  // Null if not deleted (soft delete)
  final DateTime? syncedAt;   // Last cloud sync time
}
```

---

## Firestore Database Structure

```
users/
├── {userId}/
│   └── saved_verses/
│       ├── {referenceId}/
│       │   ├── ref: "John 3:16"
│       │   ├── text: "..."
│       │   ├── createdAt: "2025-02-11T..."
│       │   ├── modifiedAt: "2025-02-11T..."
│       │   ├── deletedAt: null  (or timestamp if soft deleted)
│       │   └── syncedAt: "2025-02-11T..."
```

**Note:** `deletedAt` field is used for soft deletes. Verses are never hard-deleted automatically.

---

## Firestore Security Rules

Add these rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only allow authenticated users to access their own data
    match /users/{userId}/saved_verses/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## Usage Guide

### Basic Operations

```dart
import 'package:bible/services/saved_verses_service.dart';

// Check if a verse is saved
bool isSaved = SavedVersesService.isSaved(verse);

// Add a verse
await SavedVersesService.add(verse);

// Remove a verse (soft delete)
await SavedVersesService.remove(verse);

// Toggle save status
await SavedVersesService.toggleSave(verse);

// Clear all saved verses
await SavedVersesService.clearAll();
```

### Soft Delete & Recovery

```dart
// Get deleted verses
List<Verse> deleted = SavedVersesService.getDeletedVerses();

// Recover a deleted verse
await SavedVersesService.recover(deletedVerse);

// Permanently delete a verse (be careful!)
await SavedVersesService.hardDelete(verse);
```

### Monitoring Sync Status

```dart
import 'package:bible/services/cloud_saved_verses_service.dart';

// Listen to sync status changes
CloudSavedVersesService.isSynced.addListener(() {
  if (CloudSavedVersesService.isSynced.value) {
    // All changes are synced to cloud
  } else {
    // Syncing in progress
  }
});

// Manually trigger sync
await SavedVersesService.syncWithCloud();
```

### UI with Recovery Widget

The `DeletedVersesRecoveryWidget` provides a UI for viewing and managing deleted verses:

```dart
import 'package:bible/components/deleted_verses_recovery.dart';

// Add to your settings/recovery screen
const DeletedVersesRecoveryWidget()
```

---

## How Sync Works

### Adding a Verse
1. Verse added to local `saved.value` with timestamps
2. Added to local cache (SharedPreferences)
3. Uploaded to Firestore in background
4. `isSynced` becomes `false` during upload
5. `isSynced` becomes `true` when upload completes

### Removing a Verse (Soft Delete)
1. Verse marked with `deletedAt` timestamp
2. Removed from `saved.value`
3. Moved to `deletedVerses.value` for recovery
4. Uploaded to Firestore with `deletedAt` field
5. Cloud listeners see the change and sync across devices

### Conflict Resolution
When opening app on different devices with different changes:
1. Local data loaded from cache
2. Cloud data fetched from Firestore
3. For each verse, the version with later `modifiedAt` timestamp wins
4. Merged data saved locally and becomes the source of truth

### Real-Time Updates
1. Firestore listener set up on app initialization
2. When user makes changes on Device A
3. Device B's listener is notified immediately
4. Local data updated and UI refreshes

---

## Offline Support

### How It Works
1. All operations work offline (no auth check needed)
2. Changes are stored in `pending_sync_operations` queue
3. When network returns, pending operations are processed
4. Firestore updates apply the changes

### Cache Location
- **Key:** `saved_verses_cache`
- **Format:** JSON with verses and deleted verses
- **Location:** SharedPreferences (persistent on device)

**Note:** Currently, the app doesn't actively monitor network connectivity. Consider adding:

```dart
// Future enhancement
import 'package:connectivity_plus/connectivity_plus.dart';

Connectivity().onConnectivityChanged.listen((result) {
  if (result != ConnectivityResult.none) {
    SavedVersesService.syncWithCloud();
  }
});
```

---

## Migration Notes

### From Old System
The old local-only system used:
- Key: `saved_verses`
- Format: Simple JSON array

The new system:
- Reads old data automatically on first sync
- Preserves all verses with current timestamp
- Enables cloud sync going forward

### Backward Compatibility
- Same public API as before
- Existing code doesn't need changes
- Verses automatically synced to cloud on first app run

---

## Troubleshooting

### Verses Not Syncing
1. Check Firestore is initialized before SavedVersesService
2. Verify user is authenticated (`AuthService.currentUser != null`)
3. Check Firestore security rules allow the user
4. Call `SavedVersesService.syncWithCloud()` manually

### Verses Duplicating Across Devices
- This shouldn't happen due to conflict resolution
- If it does, check Firestore has correct data
- Try force sync: `SavedVersesService.syncWithCloud()`

### Lost Data Recovery
1. Check `DeletedVersesRecoveryWidget` for soft-deleted verses
2. Check Firestore console directly for backup
3. Check local cache in SharedPreferences
4. Last resort: contact Firebase support for data recovery

---

## Performance Considerations

### Firestore Costs
- **Read:** 1 read per app start (fetch all user's verses)
- **Write:** 1 write per add/remove/recover operation
- **Real-time listeners:** Billing for each listener

### Optimization Tips
1. Batch operations when possible
2. Implement proper error handling (already done)
3. Monitor Firestore usage in console
4. Consider pagination for users with 1000+ verses

---

## Security Considerations

### Data Protection
- Only the authenticated user can access their verses
- Firestore rules enforce user isolation
- Use HTTPS for all Firestore operations (automatic)

### Recommendations
1. Enable Firestore encryption at rest (in Firebase console)
2. Regularly backup important data
3. Test disaster recovery procedures
4. Monitor Firestore usage for suspicious activity

---

## Future Enhancements

Consider implementing:
1. **Batch Sync:** Batch multiple operations into one Firestore transaction
2. **Smart Conflict Resolution:** Allow user to choose strategy (merge, most recent, etc.)
3. **Verse Sharing:** Share collections with other users
4. **Backup & Export:** Export verses as JSON/PDF
5. **Network Monitoring:** Actively detect network changes and sync
6. **Selective Sync:** Choose which devices to sync with
7. **Compression:** Compress large verse texts for faster sync
8. **Offline Queue UI:** Show pending operations to user

---

## Support

For issues or questions:
1. Check Firestore error messages in console
2. Look at CloudSavedVersesService logs
3. Review Firestore security rules
4. Check network connectivity
5. Verify Firebase project is properly configured
