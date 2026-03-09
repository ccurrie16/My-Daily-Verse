// Model class representing a Bible verse
class Verse {
  final String reference;
  final String text;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt; // null = not deleted, soft delete support
  final DateTime? syncedAt; // when last synced to cloud

  Verse({
    required this.reference,
    required this.text,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.deletedAt,
    this.syncedAt,
  })  : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        modifiedAt = modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    // Handle Firestore Timestamp
    try { return (value as dynamic).toDate() as DateTime; } catch (_) {}
    return null;
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      reference: (json['ref'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      modifiedAt: _parseDate(json['modifiedAt']) ?? DateTime.now(),
      deletedAt: _parseDate(json['deletedAt']),
      syncedAt: _parseDate(json['syncedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ref': reference,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'syncedAt': syncedAt?.toIso8601String(),
      };

  // Create a copy with modified fields
  Verse copyWith({
    String? reference,
    String? text,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? deletedAt,
    DateTime? syncedAt,
  }) {
    return Verse(
      reference: reference ?? this.reference,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
