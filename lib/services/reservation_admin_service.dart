import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_management/models/reservation.dart';

class ReservationAdminService {
  final String baseUrl = 'http://localhost:8090/RESERVATION-SERVICE';

  Future<Map<String, dynamic>> fetchPaginatedReservations({
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
      Uri.parse('$baseUrl/api/admin/reservation/find-paginated-by-criteria'),
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
      throw Exception('Failed to fetch reservations: ${response.body}');
    }
  }

  Future<void> updateReservation(Map<String, dynamic> reservationData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse(
          'http://localhost:8090/RESERVATION-SERVICE/api/admin/reservation/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reservationData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reservation: ${response.body}');
    }
  }
}
