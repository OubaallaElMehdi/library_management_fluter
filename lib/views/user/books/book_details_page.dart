import 'package:flutter/material.dart';
import 'package:library_management/services/book_service.dart';
import 'package:library_management/models/book.dart';
import 'package:library_management/views/user/reservation/reservation_page.dart';

class BookDetailsPage extends StatefulWidget {
  final int bookId;

  const BookDetailsPage({super.key, required this.bookId});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final BookService bookService = BookService();
  late Future<Book> bookFuture;

  @override
  void initState() {
    super.initState();
    // Load the book from the “client” endpoint by ID
    bookFuture = bookService.findByIdClient(widget.bookId);
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Book not found.'));
          }

          final book = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Cover Image
                ClipRRect(
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
                const SizedBox(height: 16.0),

                // Title
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Author
                Text(
                  'By ${book.authorName}',
                  style: const TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
                const SizedBox(height: 16.0),

                // Description
                Text(
                  book.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0, height: 1.5),
                ),
                const SizedBox(height: 32.0),

                // Reserve Now Button
                ElevatedButton(
                  onPressed: () {
                    // PASS THE BOOK CODE TO ReservationPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationPage(
                          bookCode: book.code, // <-- ADDED THIS PARAM
                        ),
                      ),
                    );
                  },
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
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
