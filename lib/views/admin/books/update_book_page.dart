import 'package:flutter/material.dart';
import '../../../services/book_service.dart';

class UpdateBookPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const UpdateBookPage({super.key, required this.book});

  @override
  State<UpdateBookPage> createState() => _UpdateBookPageState();
}

class _UpdateBookPageState extends State<UpdateBookPage> {
  final BookService bookService = BookService();
  late TextEditingController codeController;
  late TextEditingController labelController;
  late TextEditingController titleController;
  late TextEditingController editionDateController;
  late TextEditingController descriptionController;
  late TextEditingController numberOfCopiesController;
  late TextEditingController imageUrlController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.book['code']);
    labelController = TextEditingController(text: widget.book['label']);
    titleController = TextEditingController(text: widget.book['title']);
    editionDateController =
        TextEditingController(text: widget.book['editionDate']);
    descriptionController =
        TextEditingController(text: widget.book['description']);
    numberOfCopiesController =
        TextEditingController(text: widget.book['numberOfCopies'].toString());
    imageUrlController = TextEditingController(text: widget.book['imageUrl']);
  }

  Future<void> updateBook() async {
    final updatedBook = {
      "id": widget.book['id'],
      "code": codeController.text,
      "label": labelController.text,
      "title": titleController.text,
      "editionDate": editionDateController.text,
      "description": descriptionController.text,
      "numberOfCopies": int.tryParse(numberOfCopiesController.text) ?? 0,
      "available": true,
      "imageUrl": imageUrlController.text,
      "author": widget.book['author'],
    };

    try {
      await bookService.updateBook(updatedBook);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update book: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(
      {required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Update Book',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/logo.png',
              height: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.book['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.book['imageUrl'],
                        width: 150,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.book, size: 150, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            _buildTextField(label: 'Code', controller: codeController),
            const SizedBox(height: 16.0),
            _buildTextField(label: 'Label', controller: labelController),
            const SizedBox(height: 16.0),
            _buildTextField(label: 'Title', controller: titleController),
            const SizedBox(height: 16.0),
            _buildTextField(
                label: 'Edition Date', controller: editionDateController),
            const SizedBox(height: 16.0),
            _buildTextField(
                label: 'Description', controller: descriptionController),
            const SizedBox(height: 16.0),
            _buildTextField(
              label: 'Number of Copies',
              controller: numberOfCopiesController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            _buildTextField(label: 'Image URL', controller: imageUrlController),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: updateBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 130, 233),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Update Book',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
