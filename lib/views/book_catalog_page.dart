import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/book_service.dart';

class BookCatalogPage extends StatefulWidget {
  const BookCatalogPage({Key? key}) : super(key: key);

  @override
  State<BookCatalogPage> createState() => _BookCatalogPageState();
}

class _BookCatalogPageState extends State<BookCatalogPage> {
  final BookService bookService = BookService();
  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = bookService.fetchBooks();
  }

  void handleTokenError() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the invalid token
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Catalog')),
      body: FutureBuilder<List<dynamic>>(
        future: booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            if (snapshot.error.toString().contains('Unauthorized') ||
                snapshot.error.toString().contains('Forbidden')) {
              handleTokenError(); // Redirect to login if token is invalid
              return const Center(child: Text('Redirecting to login...'));
            }
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(book['title'] ?? 'No Title'),
                  subtitle:
                      Text(book['author']['fullName'] ?? 'Unknown Author'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${book['title']}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
