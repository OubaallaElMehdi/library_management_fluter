import 'package:flutter/material.dart';
import 'package:library_management/models/reservation.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/services/reservation_service.dart';
import 'package:library_management/services/auth_service.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final String bookLabel;

  const ReservationPage({super.key, required this.bookLabel});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final ReservationService reservationService = ReservationService();
  final AuthService authService = AuthService();

  final TextEditingController bookLabelController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController theoreticalReturnDateController =
      TextEditingController();

  DateTime? pickedRequestDate;
  DateTime? pickedReturnDate;
  Client? client;
  String reservationCode = '';

  @override
  void initState() {
    super.initState();
    bookLabelController.text = widget.bookLabel;
    reservationCode = Reservation.generateCode();
    _loadClientDetails();
  }

  Future<void> _loadClientDetails() async {
    try {
      final username = await authService.getClientUsername();
      if (username != null) {
        final fetchedClient = await authService.getClientDetails(username);
        setState(() {
          client = fetchedClient;
        });
      } else {
        throw Exception('Failed to retrieve username');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading client details: $e')),
      );
    }
  }

  String _toBackendDate(DateTime date) {
    final String formatted =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(date);
    return "${formatted}Z";
  }

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
          theoreticalReturnDateController.text = _toBackendDate(chosen);
        } else {
          pickedRequestDate = chosen;
          requestDateController.text = _toBackendDate(chosen);
        }
      });
    }
  }

  Future<void> createReservation() async {
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client details not loaded')),
      );
      return;
    }

    try {
      // Prepare the client data for the request
      final clientData = {
        'id': client!.id,
        'email': client!.email,
        'username': client!.username,
      };

      // Create the reservation object
      final reservation = Reservation(
        booklabel: bookLabelController.text,
        requestDate: requestDateController.text,
        theoreticalReturnDate: theoreticalReturnDateController.text,
        effectiveReturnDate: null,
        reservationItems: [], // Add items if necessary
        client: clientData, // Send only the required fields
        code: reservationCode,
      );

      await reservationService.createReservation(reservation.toJson());

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
            TextField(
              controller: TextEditingController(text: reservationCode),
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Reservation Code'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bookLabelController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Book Label'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: requestDateController,
              readOnly: true,
              decoration:
                  const InputDecoration(labelText: 'Request Date (tap)'),
              onTap: () => _pickDate(isReturnDate: false),
            ),
            const SizedBox(height: 16),
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
