import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  final String baseUrl = 'http://localhost:8090/RESERVATION-SERVICE/api/admin';

  // Method to retrieve the token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper method to set headers with the token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      throw Exception('Token not found. Please log in.');
    }
  }

  // Fetch author statistics
  Future<Map<String, dynamic>> fetchAuthorStatistics() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/author/statistics');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch author statistics');
    }
  }

  // Fetch category statistics
  Future<Map<String, dynamic>> fetchCategoryStatistics() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/category/statistics');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch category statistics');
    }
  }

  // Fetch top authors statistics
  Future<Map<String, dynamic>> fetchTopAuthors() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/author/statistics/top-authors');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch top authors statistics');
    }
  }

  // Fetch top categories statistics
  Future<Map<String, dynamic>> fetchTopCategories() async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/category/statistics/top-categories');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch top categories statistics');
    }
  }
}
