import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:library_management/models/reservation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  final String baseUrl =
      'http://localhost:8090/RESERVATION-SERVICE/api/client/reservation/';

  Future<void> createReservation(Map<String, dynamic> reservationData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the saved token

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add Authorization header
      },
      body: jsonEncode(reservationData), // Send the request as-is
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  static String generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'R$timestamp';
  }

  Future<List<Reservation>> getAllReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch reservations: ${response.body}');
    }

    final List<dynamic> reservationsJson = jsonDecode(response.body);
    return reservationsJson.map((json) => Reservation.fromJson(json)).toList();
  }

  Future<List<Reservation>> getReservationsByClientId(int clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/client/$clientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch reservations for client: ${response.body}');
    }

    final List<dynamic> reservationsJson = jsonDecode(response.body);
    return reservationsJson.map((json) => Reservation.fromJson(json)).toList();
  }

  Future<List<Reservation>> getReservationsByClient(int clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/client/$clientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> reservationsJson = jsonDecode(response.body);
      return reservationsJson
          .map((json) => Reservation.fromJson(json))
          .toList();
    } else if (response.statusCode == 204) {
      return []; // No reservations found
    } else {
      throw Exception('Failed to fetch reservations: ${response.body}');
    }
  }
}
