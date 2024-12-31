import 'package:flutter/material.dart';
import '../../services/book_service.dart';

class UpdateBookPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const UpdateBookPage({Key? key, required this.book}) : super(key: key);

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
      "numberOfCopies": int.parse(numberOfCopiesController.text),
      "available": true,
      "imageUrl": imageUrlController.text,
      "author": widget.book['author'],
    };

    await bookService.updateBook(updatedBook);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: widget.book['imageUrl'] != null
                  ? Image.network(
                      widget.book['imageUrl'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.book, size: 150),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: editionDateController,
              decoration: const InputDecoration(labelText: 'Edition Date'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: numberOfCopiesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Copies'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateBook,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Update Book'),
            ),
          ],
        ),
      ),
    );
  }
}
