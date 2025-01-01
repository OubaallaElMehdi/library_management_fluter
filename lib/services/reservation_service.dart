import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  final String baseUrl = 'http://localhost:8037/api/client/reservation/';

  Future<void> createReservation(Map<String, dynamic> reservationData) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(reservationData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }
}
