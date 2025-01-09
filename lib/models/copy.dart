class Copy {
  final int id;
  final String serialNumber;
  final Map<String, dynamic> book;
  // or you could use a Book object directly if you prefer

  Copy({
    required this.id,
    required this.serialNumber,
    required this.book,
  });

  factory Copy.fromJson(Map<String, dynamic> json) {
    return Copy(
      id: json['id'] ?? 0,
      serialNumber: json['serialNumber'] ?? '',
      book: json['book'] ?? {},
    );
  }
}
