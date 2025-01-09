class Book {
  final int id;
  final String label;
  final String code;
  final String title;
  final String editionDate;
  final String description;
  final int numberOfCopies;
  final bool available;
  final String imageUrl;
  final String authorName;

  Book({
    required this.id,
    required this.label,
    required this.code,
    required this.title,
    required this.editionDate,
    required this.description,
    required this.numberOfCopies,
    required this.available,
    required this.imageUrl,
    required this.authorName,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Safely extract author JSON
    final authorJson = json['author'];
    // If `author` is null or `fullName` is null, fallback to an empty string.
    final safeAuthorName =
        authorJson != null ? (authorJson['fullName'] ?? '') : '';

    return Book(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      editionDate: json['editionDate'] ?? '',
      description: json['description'] ?? '',
      numberOfCopies: json['numberOfCopies'] ?? 0,
      available: json['available'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
      authorName: safeAuthorName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'code': code,
      'title': title,
      'editionDate': editionDate,
      'description': description,
      'numberOfCopies': numberOfCopies,
      'available': available,
      'imageUrl': imageUrl,
      'authorName': authorName,
    };
  }
}
