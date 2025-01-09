import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:library_management/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final String baseUrl = 'http://localhost:8036';

  /// If you still need normal JSON-only create:
  Future<void> createBook(Map<String, dynamic> bookData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/book/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create book: ${response.body}');
      }
    } catch (e) {
      print('Error during book creation: $e');
      rethrow;
    }
  }

  /// NEW: For Web. Sends 'book' (JSON) + 'image' (bytes) as multipart/form-data.
  Future<void> createBookWithImageFromBytes(
    Map<String, dynamic> bookData,
    Uint8List imageBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    try {
      final uri = Uri.parse('$baseUrl/api/admin/book/');
      var request = http.MultipartRequest('POST', uri);

      // Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // 1) Add the book JSON as application/json
      request.files.add(
        http.MultipartFile.fromBytes(
          'book',
          utf8.encode(jsonEncode(bookData)),
          filename: 'book.json',
          contentType: MediaType('application', 'json'),
        ),
      );

      // 2) Add the image as image/png (or jpeg if that’s the format)
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'picked_image.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Send
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw Exception('Failed to create book with image: ${response.body}');
      }
    } catch (e) {
      print('Error during createBookWithImageFromBytes: $e');
      rethrow;
    }
  }

  // Other existing methods:
  Future<Map<String, dynamic>> fetchPaginatedBooks({
    required String endpoint,
    required int page,
    required int maxResults,
    required String sortOrder,
    required String sortField,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "page": page,
        "maxResults": maxResults,
        "sortOrder": sortOrder,
        "sortField": sortField,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch books: ${response.body}');
    }
  }

  Future<void> updateBook(Map<String, dynamic> bookData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/book/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(bookData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update book: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchAuthors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/author/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch authors: ${response.body}');
    }
  }

  Future<void> deleteBook(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/book/id/$bookId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete book: ${response.body}');
    }
  }

  Future<Book> findById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/book/id/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to find book with ID $id: ${response.body}');
    }
  }

  Future<Book> findByIdClient(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/client/book/id/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to find book with ID $id: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/category/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch categories: ${response.body}');
    }
  }
}
