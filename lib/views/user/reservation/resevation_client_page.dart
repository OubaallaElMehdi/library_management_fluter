import 'package:flutter/material.dart';
import 'package:library_management/models/reservation.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/services/reservation_service.dart';
import 'package:library_management/services/auth_service.dart';

class ReservationClientPage extends StatefulWidget {
  const ReservationClientPage({super.key});

  @override
  State<ReservationClientPage> createState() => _ReservationClientPageState();
}

class _ReservationClientPageState extends State<ReservationClientPage> {
  Future<List<Reservation>>? _reservations;
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  // Fetch reservations for the current client
  void _fetchReservations() async {
    try {
      // Fetch username from preferences
      final username = await _authService.getClientUsername();

      if (username == null) {
        throw Exception('Client username not found.');
      }

      // Fetch client details using username
      final client = await _authService.getClientDetails(username);

      // Fetch reservations using client ID
      setState(() {
        _reservations =
            _reservationService.getReservationsByClientId(client.id);
      });
    } catch (e) {
      setState(() {
        _reservations = Future.error('Failed to fetch reservations: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No reservations found.'),
            );
          } else {
            final reservations = snapshot.data!;
            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  elevation: 4.0,
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.blueAccent),
                    title: Text(
                      reservation.booklabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requested on: ${reservation.requestDate}'),
                        Text(
                          'Status: ${reservation.reservationState?.label ?? "Unknown"}',
                          style: TextStyle(
                            color:
                                reservation.reservationState?.label == 'Pending'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Add any tap action if needed
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
