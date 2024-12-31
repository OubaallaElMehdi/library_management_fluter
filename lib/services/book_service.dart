import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final String baseUrl = 'http://192.168.1.9:8036';

  Future<List<dynamic>> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/book/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include token
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden. Check your permissions.');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to load books: ${response.body}');
    }
  }
}
