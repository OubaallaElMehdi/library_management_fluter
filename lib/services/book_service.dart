import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final String baseUrl = 'http://192.168.1.9:8036';

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
        'Authorization': 'Bearer $token', // Include the token
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
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to load books: ${response.body}');
    }
  }
}
