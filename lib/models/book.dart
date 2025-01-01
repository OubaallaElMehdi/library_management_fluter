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
    return Book(
      id: json['id'],
      label: json['label'],
      code: json['code'],
      title: json['title'],
      editionDate: json['editionDate'],
      description: json['description'],
      numberOfCopies: json['numberOfCopies'],
      available: json['available'],
      imageUrl: json['imageUrl'],
      authorName: json['author']['fullName'],
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
