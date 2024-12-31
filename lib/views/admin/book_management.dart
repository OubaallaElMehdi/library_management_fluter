import 'package:flutter/material.dart';
import 'package:library_management/views/admin/create_book_page.dart';
import 'package:library_management/views/admin/update_book_page.dart';
import '../../services/book_service.dart';

class BookManagementPage extends StatefulWidget {
  const BookManagementPage({Key? key}) : super(key: key);

  @override
  State<BookManagementPage> createState() => _BookManagementPageState();
}

class _BookManagementPageState extends State<BookManagementPage> {
  final BookService bookService = BookService();
  late Future<List<dynamic>> booksFuture;

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<List<dynamic>> fetchBooks() async {
    final response = await bookService.fetchPaginatedBooks(
      endpoint: '/api/admin/book/find-paginated-by-criteria',
      page: 0,
      maxResults: 10,
      sortOrder: 'ASC',
      sortField: 'title',
    );
    return response['list'];
  }

  Future<void> deleteBook(int bookId) async {
    await bookService.deleteBook(bookId);
    setState(() {
      booksFuture = fetchBooks();
    });
  }

  void navigateToCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBookPage(),
      ),
    ).then((_) {
      setState(() {
        booksFuture = fetchBooks();
      });
    });
  }

  void navigateToUpdatePage(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBookPage(book: book),
      ),
    ).then((_) {
      setState(() {
        booksFuture = fetchBooks();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Managing'),
      ),
      body: FutureBuilder<List<dynamic>>(
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: book['imageUrl'] != null
                          ? Image.network(
                              book['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.book, size: 60),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(book['title'] ?? 'No Title'),
                        subtitle: Text(
                            book['author']['fullName'] ?? 'Unknown Author'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => navigateToUpdatePage(book),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteBook(book['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCreatePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
