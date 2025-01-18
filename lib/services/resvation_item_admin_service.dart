import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminReservationService {
  final String reservationBaseUrl =
      'http://localhost:8090/RESERVATION-SERVICE/api/admin/reservation/';
  final String reservationItemUrl =
      'http://localhost:8090/RESERVATION-SERVICE/api/admin/reservationItem/';
  final String copyBaseUrl =
      'http://localhost:8090/BOOKS-SERVICE/api/admin/copy/';
  final String bookBaseUrl =
      'http://localhost:8090/BOOKS-SERVICE/api/admin/book/';

  /// Fetch paginated reservations
  Future<Map<String, dynamic>> fetchPaginatedReservations({
    required int page,
    required int maxResults,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${reservationBaseUrl}find-paginated-by-criteria'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "page": page,
        "maxResults": maxResults,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch reservations: ${response.body}');
    }
  }

  /// Fetch copies by book ID
  Future<List<dynamic>> fetchCopiesByBookId(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${copyBaseUrl}book/id/$bookId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch copies: ${response.body}');
    }
  }

  /// Fetch book by code
  Future<Map<String, dynamic>> fetchBookByCode(String bookCode) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${bookBaseUrl}code/$bookCode'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch book by code: ${response.body}');
    }
  }

  /// Create reservation item
  Future<void> createReservationItem(
      Map<String, dynamic> reservationItemData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse(reservationItemUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reservationItemData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reservation item: ${response.body}');
    }
  }
}
