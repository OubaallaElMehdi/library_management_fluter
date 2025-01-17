import 'package:flutter/material.dart';
import 'package:library_management/models/book.dart';
import 'package:library_management/services/guest_book_service.dart';

class GuestBooksPage extends StatefulWidget {
  const GuestBooksPage({super.key});

  @override
  State<GuestBooksPage> createState() => _GuestBooksPageState();
}

class _GuestBooksPageState extends State<GuestBooksPage> {
  final GuestBookService guestBookService = GuestBookService();
  late Future<List<Book>> booksFuture;
  int currentPage = 0;
  final int maxResults = 5;

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<List<Book>> fetchBooks() async {
    try {
      print("Fetching books for page $currentPage");
      final response = await guestBookService.fetchPaginatedBooks(
        endpoint: '/api/client/book/find-paginated-by-criteria',
        page: currentPage,
        maxResults: maxResults,
        sortOrder: 'ASC',
        sortField: 'title',
      );

      final List<dynamic> data = response['list'];
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (error) {
      print("Error fetching books: $error");
      rethrow;
    }
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
      backgroundColor: Colors.grey[200], // Light background
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Books Catalog',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/login'); // Navigate to login
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/register'); // Navigate to register
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Book List
            Expanded(
              child: FutureBuilder<List<Book>>(
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
                    return const Center(
                      child: Text(
                        'No books available.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  final books = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              book.imageUrl.isNotEmpty
                                  ? book.imageUrl
                                  : 'https://via.placeholder.com/100',
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('By ${book.authorName}'),
                              Text(
                                book.available ? 'Available' : 'Unavailable',
                                style: TextStyle(
                                  color: book.available
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/login'); // Navigate to login
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Pagination Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: currentPage > 0 ? Colors.blue : Colors.grey,
                    onPressed: currentPage > 0 ? loadPreviousPage : null,
                  ),
                  Text(
                    'Page ${currentPage + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.blue,
                    onPressed: loadNextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
