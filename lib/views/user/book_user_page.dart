import 'package:flutter/material.dart';
import '../../services/book_service.dart';

class BookUserPage extends StatefulWidget {
  const BookUserPage({Key? key}) : super(key: key);

  @override
  State<BookUserPage> createState() => _BookUserPageState();
}

class _BookUserPageState extends State<BookUserPage> {
  final BookService bookService = BookService();
  late Future<Map<String, dynamic>> booksFuture;
  int currentPage = 0;
  final int maxResults = 8;

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<Map<String, dynamic>> fetchBooks() {
    return bookService.fetchPaginatedBooks(
      endpoint: '/api/client/book/find-paginated-by-criteria',
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'title',
    );
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
      booksFuture = fetchBooks();
    });
  }

  void loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        booksFuture = fetchBooks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Book Catalog'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!['list'].isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!['list'];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(book['title'] ?? 'No Title'),
                        subtitle: Text(
                            book['author']['fullName'] ?? 'Unknown Author'),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 0 ? loadPreviousPage : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: loadNextPage,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
