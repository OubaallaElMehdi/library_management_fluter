import 'package:flutter/material.dart';
import 'package:library_management/services/resvationadmin_service.dart';

class ReservationDetailPage extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  final AdminReservationService reservationService = AdminReservationService();

  // We'll fetch the book ID by code
  Map<String, dynamic>? book;
  late Future<List<dynamic>> copiesFuture;

  String? selectedCopyId;
  DateTime? returnDate;

  @override
  void initState() {
    super.initState();
    copiesFuture = _loadCopies();
  }

  /// 1) Find the Book ID by code
  /// 2) Fetch copies by book ID
  Future<List<dynamic>> _loadCopies() async {
    final bookCode = widget.reservation['code'] as String?;
    if (bookCode == null) {
      throw Exception(
          "No 'code' in reservation => can't fetch book or copies.");
    }
    final fetchedBook = await reservationService.fetchBookByCode(bookCode);
    book = fetchedBook;

    final bookId = book?['id'];
    if (bookId == null) {
      throw Exception("Book has no 'id'. Can't fetch copies.");
    }

    final copies = await reservationService.fetchCopiesByBookId(bookId);
    return copies;
  }

  Future<void> createReservationItem() async {
    if (selectedCopyId == null || returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a copy and return date.')),
      );
      return;
    }

    // We only pass { "id" } for copy & reservation
    // plus "returnDate" with .000Z if server needs that
    final isoDate = '${returnDate!.toIso8601String()}Z';
    // or just .toIso8601String() if the server is flexible

    final reservationId = widget.reservation['id'];

    final reservationItemData = {
      "returnDate": isoDate,
      "copy": {"id": int.parse(selectedCopyId!)},
      "reservation": {"id": reservationId}
    };

    try {
      await reservationService.createReservationItem(reservationItemData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation item created successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create reservation item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationId = widget.reservation['id'];
    final reservationCode = widget.reservation['code'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Reservation Detail')),
      body: FutureBuilder<List<dynamic>>(
        future: copiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final copies = snapshot.data ?? [];
          if (copies.isEmpty) {
            return const Center(child: Text('No copies found for this book.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Reservation ID: $reservationId'),
                const SizedBox(height: 8),
                Text('Reservation Code: $reservationCode'),
                const SizedBox(height: 16),

                // Copies dropdown (only showing copy "id" => the server only needs that)
                DropdownButtonFormField<String>(
                  value: selectedCopyId,
                  decoration: const InputDecoration(labelText: 'Select Copy'),
                  items: copies.map((c) {
                    final cid = c['id'].toString();
                    final serialNum = c['serialNumber'] ?? 'NoSerial';
                    return DropdownMenuItem<String>(
                      value: cid,
                      child: Text('$serialNum (ID=$cid)'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCopyId = value),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() => returnDate = pickedDate);
                    }
                  },
                  child: Text(
                    returnDate == null
                        ? 'Select Return Date'
                        : 'Return Date: ${returnDate!.toIso8601String()}Z',
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: createReservationItem,
                  child: const Text('Validate Reservation'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
