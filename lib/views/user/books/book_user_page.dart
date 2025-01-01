import 'package:flutter/material.dart';
import 'package:library_management/views/user/books/book_details_page.dart';
import '../../../services/book_service.dart';
import '../../../models/book.dart';

class BookUserPage extends StatefulWidget {
  const BookUserPage({super.key});

  @override
  State<BookUserPage> createState() => _BookUserPageState();
}

class _BookUserPageState extends State<BookUserPage> {
  final BookService bookService = BookService();
  late Future<List<Book>> booksFuture;
  int currentPage = 0;
  final int maxResults = 2;
  final TextEditingController searchController = TextEditingController();
  final Map<int, bool> favoriteStates = {};

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<List<Book>> fetchBooks() async {
    final response = await bookService.fetchPaginatedBooks(
      endpoint: '/api/client/book/find-paginated-by-criteria',
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'title',
    );
    final List<dynamic> data = response['list'];
    return data.map((json) => Book.fromJson(json)).toList();
  }

  void searchBooks() {
    final query = searchController.text;
    setState(() {
      //booksFuture = fetchBooks(query: query);
      print(query);
    });
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
        title: const Text('Catalogue'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar with Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: searchBooks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 130, 233),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Search'),
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
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No books available.',
                      style:
                          TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                final books = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isFavorited =
                        favoriteStates[book.id] ?? false; // Get favorite state

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: Colors.blue[50],
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book Cover Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                book.imageUrl.isNotEmpty
                                    ? book.imageUrl
                                    : 'https://via.placeholder.com/100',
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            // Book Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'By ${book.authorName}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    book.available
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: book.available
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Heart Icon
                                IconButton(
                                  icon: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                  color: isFavorited ? Colors.red : Colors.grey,
                                  onPressed: () {
                                    setState(() {
                                      favoriteStates[book.id] = !isFavorited;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                // Show More Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookDetailsPage(bookId: book.id),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 4, 130, 233),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Show More',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Pagination Controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              border: const Border(
                top: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.blue,
                  onPressed: currentPage > 0 ? loadPreviousPage : null,
                ),
                Text(
                  'Page ${currentPage + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
    );
  }
}
