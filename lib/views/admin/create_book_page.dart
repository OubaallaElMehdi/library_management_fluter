import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../../services/book_service.dart';

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({Key? key}) : super(key: key);

  @override
  State<CreateBookPage> createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final BookService bookService = BookService();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController numberOfCopiesController =
      TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  DateTime? selectedEditionDate;
  String? selectedAuthorId;
  bool available = true;
  List<dynamic> authors = [];

  @override
  void initState() {
    super.initState();
    fetchAuthors();
  }

  Future<void> fetchAuthors() async {
    authors = await bookService.fetchAuthors();
    setState(() {});
  }

  Future<void> createBook() async {
    if (codeController.text.isNotEmpty &&
        labelController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        selectedEditionDate != null &&
        numberOfCopiesController.text.isNotEmpty &&
        selectedAuthorId != null &&
        imageUrlController.text.isNotEmpty) {
      final newBook = {
        "code": codeController.text,
        "label": labelController.text,
        "title": titleController.text,
        "editionDate":
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedEditionDate!),
        "description": descriptionController.text,
        "numberOfCopies": int.tryParse(numberOfCopiesController.text) ?? 0,
        "available": available,
        "imageUrl": imageUrlController.text,
        "author": {
          "id": int.parse(selectedAuthorId!)
        }, // Ensure author ID is passed correctly
        "copies": [] // Adding an empty copies list
      };

      try {
        await bookService.createBook(newBook);
        Navigator.pop(
            context); // Close the dialog or go back after creating the book
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create book: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Show a dialog if validation fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill all required fields.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code*'),
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label*'),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title*'),
            ),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedEditionDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  selectedEditionDate != null
                      ? DateFormat('dd/MM/yyyy HH:mm')
                          .format(selectedEditionDate!)
                      : 'Select Edition Date*',
                ),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: numberOfCopiesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of Copies*'),
            ),
            SwitchListTile(
              title: const Text('Available*'),
              value: available,
              onChanged: (value) {
                setState(() {
                  available = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedAuthorId,
              decoration: const InputDecoration(labelText: 'Select Author*'),
              items: authors
                  .map((author) => DropdownMenuItem(
                        value: author['id'].toString(),
                        child: Text(author['fullName']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedAuthorId = value;
                });
              },
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL*'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: createBook,
              child: const Text('Create Book'),
            ),
          ],
        ),
      ),
    );
  }
}
