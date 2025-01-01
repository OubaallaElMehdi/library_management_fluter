import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'http://localhost:8037/api/user';

  // Fetch paginated users
  Future<Map<String, dynamic>> fetchPaginatedUsers({
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
      Uri.parse('$baseUrl/find-paginated-by-criteria'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"page": page, "maxResults": maxResults}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  // Update user
  Future<void> updateUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/id/${userData['id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete user
  Future<void> deleteUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/id/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}