import 'package:flutter/material.dart';
import 'package:library_management/services/reservation_service.dart';
import '../../../services/book_service.dart';
import '../../../models/book.dart';

class BookDetailsPage extends StatefulWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final BookService bookService = BookService();
  late Future<Book> bookFuture;

  // Controllers for reservation details
  final TextEditingController codeController = TextEditingController();
  final TextEditingController requestDateController = TextEditingController();
  final TextEditingController theoreticalReturnDateController =
      TextEditingController();

  DateTime? selectedRequestDate;
  DateTime? selectedReturnDate;

  @override
  void initState() {
    super.initState();
    bookFuture = bookService.findByIdClient(widget.bookId);
  }

  // Method to show the reservation dialog
  void _showReservationDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Reservation'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Reservation Code
                TextField(
                  controller: codeController,
                  decoration:
                      const InputDecoration(labelText: 'Reservation Code'),
                ),
                const SizedBox(height: 16),
                // Request Date Picker
                TextField(
                  controller: requestDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Request Date',
                    hintText: selectedRequestDate == null
                        ? 'Select Request Date'
                        : selectedRequestDate.toString(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null &&
                            pickedDate != selectedRequestDate) {
                          setState(() {
                            selectedRequestDate = pickedDate;
                            requestDateController.text = selectedRequestDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Theoretical Return Date Picker
                TextField(
                  controller: theoreticalReturnDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Theoretical Return Date',
                    hintText: selectedReturnDate == null
                        ? 'Select Return Date'
                        : selectedReturnDate.toString(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null &&
                            pickedDate != selectedReturnDate) {
                          setState(() {
                            selectedReturnDate = pickedDate;
                            theoreticalReturnDateController.text =
                                selectedReturnDate!
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0];
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Reserve Button inside Dialog
                ElevatedButton(
                  onPressed: () {
                    if (codeController.text.isNotEmpty &&
                        selectedRequestDate != null &&
                        selectedReturnDate != null) {
                      final reservationData = {
                        "code": codeController.text,
                        "requestDate": selectedRequestDate!.toIso8601String(),
                        "theoreticalReturnDate":
                            selectedReturnDate!.toIso8601String(),
                        "effectiveReturnDate": null,
                        "client": {
                          "id": 2, // Example client ID, should be dynamic
                          "credentialsNonExpired": true,
                          "enabled": true,
                          "email": "client",
                          "accountNonExpired": true,
                          "accountNonLocked": true,
                          "username": "client",
                          "passwordChanged": false
                        }
                      };

                      ReservationService()
                          .createReservation(reservationData)
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Reservation successfully created')));
                        Navigator.pop(context); // Close the dialog
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to create reservation: $e')));
                      });
                    }
                  },
                  child: const Text('Reserve Now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Book>(
        future: bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Book not found.',
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            );
          }

          final book = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Book Cover Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        book.imageUrl.isNotEmpty
                            ? book.imageUrl
                            : 'https://via.placeholder.com/150',
                        width: 150,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Book Title
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  // Author Name
                  Text(
                    'By ${book.authorName}',
                    style: const TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 16.0),
                  // Book Description
                  Text(
                    book.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                  const SizedBox(height: 32.0),
                  // Reserve Button
                  ElevatedButton(
                    onPressed: () {
                      _showReservationDialog(book); // Show reservation dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 130, 233),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Reserve Now',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
