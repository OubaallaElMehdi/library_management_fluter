import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../../../services/book_service.dart';

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({super.key});

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
        },
        "copies": []
      };

      try {
        await bookService.createBook(newBook);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book created successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog('Failed to create book: $e');
      }
    } else {
      _showErrorDialog('Please fill all required fields.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
          'Create Book',
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
            _buildTextField('Code*', codeController),
            const SizedBox(height: 16.0),
            _buildTextField('Label*', labelController),
            const SizedBox(height: 16.0),
            _buildTextField('Title*', titleController),
            const SizedBox(height: 16.0),
            _buildDatePicker('Select Edition Date*'),
            const SizedBox(height: 16.0),
            _buildTextField('Description', descriptionController),
            const SizedBox(height: 16.0),
            _buildTextField(
              'Number of Copies*',
              numberOfCopiesController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Available*'),
              value: available,
              onChanged: (value) {
                setState(() {
                  available = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            _buildAuthorDropdown(),
            const SizedBox(height: 16.0),
            _buildTextField('Image URL*', imageUrlController),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: createBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 130, 233),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Create Book',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDatePicker(String label) {
    return GestureDetector(
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
              ? DateFormat('dd/MM/yyyy HH:mm').format(selectedEditionDate!)
              : label,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _buildAuthorDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedAuthorId,
      decoration: const InputDecoration(
        labelText: 'Select Author*',
        border: OutlineInputBorder(),
      ),
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
    );
  }
}
