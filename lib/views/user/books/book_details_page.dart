import 'package:flutter/material.dart';
import '../../../services/book_service.dart';
import '../../../services/reservation_service.dart';
import '../../../models/book.dart';

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

  @override
  void initState() {
    super.initState();
    bookFuture = bookService.findByIdClient(widget.bookId);
  }

  Future<void> makeReservation(Book book) async {
    final reservationData = {
      "code": "aaaa", // You can replace this with dynamic code
      "requestDate": DateTime.now().toIso8601String(),
      "theoreticalReturnDate":
          DateTime.now().add(Duration(days: 7)).toIso8601String(),
      "effectiveReturnDate": null,
      "client": {
        "id": 2, // Replace with actual client ID from logged-in user
        "credentialsNonExpired": true,
        "enabled": true,
        "email": "client",
        "accountNonExpired": true,
        "accountNonLocked": true,
        "username": "client",
        "passwordChanged": false
      }
    };

    try {
      await reservationService.createReservation(reservationData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating reservation: ${e.toString()}')),
      );
    }
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
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Book not found.',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
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
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Author Name
                  Text(
                    'By ${book.authorName}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Book Description
                  Text(
                    book.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  // Reserve Button
                  ElevatedButton(
                    onPressed: () {
                      makeReservation(book); // Call makeReservation
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
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
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
