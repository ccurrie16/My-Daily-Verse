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

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      reference: (json['ref'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
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
