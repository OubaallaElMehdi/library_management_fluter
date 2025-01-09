import 'package:flutter/material.dart';
import 'package:library_management/services/CopyService.dart';
import 'package:library_management/services/book_service.dart';

class CreateCopyPage extends StatefulWidget {
  const CreateCopyPage({super.key});

  @override
  State<CreateCopyPage> createState() => _CreateCopyPageState();
}

class _CreateCopyPageState extends State<CreateCopyPage> {
  final CopyService copyService = CopyService();
  final BookService bookService = BookService();

  final TextEditingController serialNumberController = TextEditingController();

  List<dynamic> books = [];
  String? selectedBookId;

  @override
  void initState() {
    super.initState();
    fetchAllBooks();
  }

  Future<void> fetchAllBooks() async {
    // For simplicity, we fetch a large list from the admin side or a special endpoint
    // If you have a paginated approach, do that. We just do a quick approach here:
    // We'll re-use fetchPaginatedBooks with a big maxResults or a new "fetchAll()" if you prefer.
    final response = await bookService.fetchPaginatedBooks(
      endpoint: '/api/admin/book/find-paginated-by-criteria',
      page: 0,
      maxResults: 1000,
      sortOrder: 'ASC',
      sortField: 'title',
    );
    final List<dynamic> data = response['list'];
    setState(() {
      books = data;
      // data has full book JSON objects
    });
  }

  Future<void> createCopy() async {
    if (serialNumberController.text.isEmpty || selectedBookId == null) {
      _showSnackBar('Please fill all required fields.');
      return;
    }

    // find the selectedBook in the books array
    final selectedBook = books.firstWhere(
      (b) => b['id'].toString() == selectedBookId,
      orElse: () => null,
    );

    if (selectedBook == null) {
      _showSnackBar('Invalid book selection.');
      return;
    }

    final copyData = {
      "serialNumber": serialNumberController.text,
      "book": selectedBook, // The entire JSON of the book
    };

    try {
      await copyService.createCopy(copyData);
      Navigator.pop(context); // Return to the copy list
    } catch (e) {
      _showSnackBar('Failed to create copy: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Copy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SerialNumber
            TextField(
              controller: serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Serial Number*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Book Dropdown
            DropdownButtonFormField<String>(
              value: selectedBookId,
              decoration: const InputDecoration(
                labelText: 'Select Book*',
                border: OutlineInputBorder(),
              ),
              items: books
                  .map((book) => DropdownMenuItem(
                        value: book['id'].toString(),
                        child: Text(book['title']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBookId = value;
                });
              },
            ),
            const SizedBox(height: 32.0),

            ElevatedButton(
              onPressed: createCopy,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Create Copy'),
            ),
          ],
        ),
      ),
    );
  }
}
