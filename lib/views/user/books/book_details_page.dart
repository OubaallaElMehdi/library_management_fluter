import 'package:flutter/material.dart';
import 'package:library_management/services/book_service.dart';
import 'package:library_management/services/reservation_service.dart';
import 'package:library_management/models/book.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailsPage extends StatefulWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final BookService bookService = BookService();
  final ReservationService reservationService = ReservationService();

  late Future<Book> bookFuture;

  TextEditingController codeController = TextEditingController();
  TextEditingController requestDateController = TextEditingController();
  TextEditingController theoreticalReturnDateController =
      TextEditingController();

  DateTime selectedRequestDate = DateTime.now();
  DateTime selectedReturnDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    bookFuture = bookService.findByIdClient(widget.bookId);
  }

  // Function to create reservation
  Future<void> createReservation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username'); // Retrieve username
      final String? email = prefs.getString('email'); // Retrieve email

      if (username == null || email == null) {
        throw Exception('Client username or email not found');
      }

      final reservationData = {
        "code": codeController.text,
        "requestDate": requestDateController.text,
        "theoreticalReturnDate": theoreticalReturnDateController.text,
        "effectiveReturnDate": null,
        "reservationItems": [],
        "client": {
          "username": username, // Use the dynamically fetched username
          "email": email, // Use the dynamically fetched email
          "credentialsNonExpired": true,
          "enabled": true,
          "accountNonExpired": true,
          "accountNonLocked": true,
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

  // Function to pick a date
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isReturnDate) async {
    final DateTime picked = await showDatePicker(
          context: context,
          initialDate: isReturnDate ? selectedReturnDate : selectedRequestDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    setState(() {
      if (isReturnDate) {
        selectedReturnDate = picked;
        theoreticalReturnDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedReturnDate);
      } else {
        selectedRequestDate = picked;
        requestDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedRequestDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Book>(
        future: bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Book not found.'));
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

                  // Reserve Button (opens reservation dialog)
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Fill Reservation Details'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: codeController,
                                    decoration: const InputDecoration(
                                        labelText: 'Reservation Code'),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: requestDateController,
                                    decoration: const InputDecoration(
                                        labelText: 'Request Date'),
                                    readOnly: true,
                                    onTap: () => _selectDate(
                                        context, requestDateController, false),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: theoreticalReturnDateController,
                                    decoration: const InputDecoration(
                                        labelText: 'Theoretical Return Date'),
                                    readOnly: true,
                                    onTap: () => _selectDate(context,
                                        theoreticalReturnDateController, true),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: createReservation,
                                child: const Text('Reserve Now'),
                              ),
                            ],
                          );
                        },
                      );
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
