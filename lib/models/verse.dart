  // Model class representing a Bible verse
class Verse {
  final String reference;
  final String text;

  const Verse({
    required this.reference,
    required this.text,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      reference: (json['ref'] ?? '') as String,
      text: (json['text'] ?? '') as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'ref': reference,
        'text': text,
      };
}
