class Verse {
  final String text;
  final String reference;

  const Verse({
    required this.text,
    required this.reference,
  });
  Map<String, dynamic> toJson() => {
        'text': text,
        'reference': reference,
      };

  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        text: (json['text'] ?? '').toString(),
        reference: (json['reference'] ?? '').toString(),
      );
}