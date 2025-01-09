import 'package:flutter/material.dart';
import 'package:library_management/services/reservation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  // ADD THIS PARAM TO RECEIVE THE BOOK CODE FROM BOOKDETAILSPAGE
  final String bookCode;

  const ReservationPage({super.key, required this.bookCode});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final ReservationService reservationService = ReservationService();

  // Controllers
  final TextEditingController codeController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController theoreticalReturnDateController =
      TextEditingController();

  DateTime? pickedRequestDate;
  DateTime? pickedReturnDate;

  @override
  void initState() {
    super.initState();

    // PRE-FILL THE CODE WITH THE PASSED-IN BOOK CODE
    codeController.text = widget.bookCode;
  }

  // Convert date to "2025-01-07T18:22:25.000Z"
  String _toBackendDate(DateTime date) {
    final String formatted =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(date);
    return "${formatted}Z";
  }

  // Function to pick date
  Future<void> _pickDate({required bool isReturnDate}) async {
    final initDate = isReturnDate
        ? (pickedReturnDate ?? DateTime.now())
        : (pickedRequestDate ?? DateTime.now());

    final chosen = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (chosen != null) {
      setState(() {
        if (isReturnDate) {
          pickedReturnDate = chosen;
          final isoDate = _toBackendDate(chosen);
          theoreticalReturnDateController.text = isoDate;
        } else {
          pickedRequestDate = chosen;
          final isoDate = _toBackendDate(chosen);
          requestDateController.text = isoDate;
        }
      });
    }
  }

  Future<void> createReservation() async {
    try {
      final reservationData = {
        "code": codeController.text,
        "requestDate": requestDateController.text,
        "theoreticalReturnDate": theoreticalReturnDateController.text,
        "effectiveReturnDate": null,
        "reservationItems": [],
        "client": {
          "id": 2,
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
        SnackBar(content: Text('Failed to create reservation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Reservation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Code
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Reservation Code'),
            ),
            const SizedBox(height: 16),

            // Request Date
            TextField(
              controller: requestDateController,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Request Date (tap)'),
              onTap: () => _pickDate(isReturnDate: false),
            ),
            const SizedBox(height: 16),

            // Theoretical Return Date
            TextField(
              controller: theoreticalReturnDateController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Theoretical Return Date (tap)'),
              onTap: () => _pickDate(isReturnDate: true),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: createReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 32.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Reserve Now',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
