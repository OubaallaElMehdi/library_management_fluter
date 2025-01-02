import 'package:flutter/material.dart';
import 'package:library_management/views/admin/books/create_book_page.dart';
import 'package:library_management/views/admin/books/update_book_page.dart';
import 'package:library_management/widgets/custom_drawer.dart';
import '../../../services/book_service.dart';
import '../../../models/book.dart';

class BookManagementPage extends StatefulWidget {
  const BookManagementPage({super.key});

  @override
  State<BookManagementPage> createState() => _BookManagementPageState();
}

class _BookManagementPageState extends State<BookManagementPage> {
  final BookService bookService = BookService();
  late Future<List<Book>> booksFuture;
  int currentPage = 0;
  final int maxResults = 2;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks();
  }

  Future<List<Book>> fetchBooks({String? query}) async {
    final response = await bookService.fetchPaginatedBooks(
      endpoint: '/api/admin/book/find-paginated-by-criteria',
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'title',
    );
    final List<dynamic> data = response['list'];
    final books = data.map((json) => Book.fromJson(json)).toList();

    if (query != null && query.isNotEmpty) {
      return books
          .where(
              (book) => book.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return books;
  }

  Future<void> deleteBook(int bookId) async {
    await bookService.deleteBook(bookId);
    setState(() {
      booksFuture = fetchBooks(query: searchController.text);
    });
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
      booksFuture = fetchBooks(query: searchController.text);
    });
  }

  void loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        booksFuture = fetchBooks(query: searchController.text);
      });
    }
  }

  void navigateToCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateBookPage(),
      ),
    ).then((_) {
      setState(() {
        booksFuture = fetchBooks(query: searchController.text);
      });
    });
  }

  void navigateToUpdatePage(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateBookPage(
          book: book.toJson(),
        ),
      ),
    ).then((_) {
      setState(() {
        booksFuture = fetchBooks(query: searchController.text);
      });
    });
  }

  void searchBooks() {
    setState(() {
      print(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Manage Books",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.blue,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/logo.png',
              height: 20, // Adjust the size as needed
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(role: 'Admin'), // Add the custom drawer here
      body: Column(
        children: [
          // Search Bar
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
                const SizedBox(width: 8.0),
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Book Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: book.imageUrl.isNotEmpty
                                  ? Image.network(
                                      book.imageUrl,
                                      width: 80,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.book,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(width: 16.0),
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
                            // Action Buttons
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => navigateToUpdatePage(book),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteBook(book.id),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToCreatePage,
        backgroundColor: const Color.fromARGB(255, 4, 130, 233),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
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
    );
  }
}
