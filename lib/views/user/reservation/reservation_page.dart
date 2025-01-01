import 'package:flutter/material.dart';
import 'package:library_management/services/reservation_service.dart';

class ReservationPage extends StatefulWidget {
  final int bookId;

  const ReservationPage({super.key, required this.bookId});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final ReservationService reservationService = ReservationService();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController theoreticalReturnDateController =
      TextEditingController();

  Future<void> createReservation() async {
    try {
      final reservationData = {
        "code": codeController.text,
        "requestDate": requestDateController.text,
        "theoreticalReturnDate": theoreticalReturnDateController.text,
        "effectiveReturnDate": null, // Will be updated later
        "client": {
          "id": 2, // Assuming client ID is 2 (to be dynamically fetched)
          "credentialsNonExpired": true,
          "enabled": true,
          "email": "client",
          "accountNonExpired": true,
          "accountNonLocked": true,
          "username": "client",
          "passwordChanged": false
        }
      };

      await reservationService.createReservation(reservationData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successfully created')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to create reservation: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve Book'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Code for Reservation
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Reservation Code'),
            ),
            const SizedBox(height: 16),
            // Request Date
            TextField(
              controller: requestDateController,
              decoration: const InputDecoration(labelText: 'Request Date'),
            ),
            const SizedBox(height: 16),
            // Theoretical Return Date
            TextField(
              controller: theoreticalReturnDateController,
              decoration:
                  const InputDecoration(labelText: 'Theoretical Return Date'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: createReservation,
              child: const Text('Reserve Now'),
            ),
          ],
        ),
      ),
    );
  }
}
