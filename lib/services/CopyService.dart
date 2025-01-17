import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CopyService {
  final String baseUrl = 'http://localhost:8090/BOOKS-SERVICE';

  Future<Map<String, dynamic>> fetchPaginatedCopies({
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

    // Your endpoint: /api/admin/copy/find-paginated-by-criteria
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/copy/find-paginated-by-criteria'),
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
      // returns { list: [...], dataSize: X }
    } else {
      throw Exception('Failed to fetch copies: ${response.body}');
    }
  }

  Future<void> createCopy(Map<String, dynamic> copyData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/copy/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(copyData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create copy: ${response.body}');
    }
  }
}
