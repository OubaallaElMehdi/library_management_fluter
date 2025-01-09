import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../services/book_service.dart';

class CreateBookPage extends StatefulWidget {
  const CreateBookPage({super.key});

  @override
  State<CreateBookPage> createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final BookService bookService = BookService();

  // Text controllers
  final TextEditingController codeController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController numberOfCopiesController =
      TextEditingController();

  // Copies List
  List<TextEditingController> copyControllers = [];
  List<Map<String, dynamic>> copies = [];

  // Date & availability
  DateTime? selectedEditionDate;
  bool available = true;

  // Author dropdown
  List<dynamic> authors = [];
  String? selectedAuthorId;

  // Category dropdown
  List<dynamic> categories = [];
  String? selectedCategoryId;

  // For previewing selected image bytes
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    fetchAuthors();
    fetchCategories();
  }

  Future<void> fetchAuthors() async {
    authors = await bookService.fetchAuthors();
    setState(() {});
  }

  Future<void> fetchCategories() async {
    categories = await bookService.fetchCategories();
    setState(() {});
  }

  // Pick a file (image) via file_picker
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.isNotEmpty) {
      // For web, bytes is directly available
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        setState(() {
          _imageBytes = fileBytes;
        });
      }
    }
  }

  void addCopyField() {
    final controller = TextEditingController();
    setState(() {
      copyControllers.add(controller);
    });
  }

  void removeCopyField(int index) {
    setState(() {
      copyControllers.removeAt(index);
    });
  }

  Future<void> createBook() async {
    // Validate required fields
    if (codeController.text.isNotEmpty &&
        labelController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        selectedEditionDate != null &&
        numberOfCopiesController.text.isNotEmpty &&
        selectedAuthorId != null &&
        selectedCategoryId != null &&
        _imageBytes != null) {
      // Collect all copies
      copies = copyControllers.map((controller) {
        return {
          "serialNumber": controller.text,
          "book": {
            "code": "",
            "label": "",
            "title": "",
            "editionDate": null,
            "description": "",
            "numberOfCopies": null,
            "available": null,
            "imageUrl": "",
            "imageBase64": "",
            "copies": []
          }
        };
      }).toList();

      // Find the selected category object
      final selectedCategory = categories.firstWhere(
        (cat) => cat['id'].toString() == selectedCategoryId,
        orElse: () => null,
      );

      // Build the book JSON
      final newBook = {
        "code": codeController.text,
        "label": labelController.text,
        "title": titleController.text,
        "editionDate":
            DateFormat('MM/dd/yyyy HH:mm').format(selectedEditionDate!),
        "description": descriptionController.text,
        "numberOfCopies": int.tryParse(numberOfCopiesController.text) ?? 0,
        "available": available,
        "imageUrl": "",
        "author": {
          "id": int.parse(selectedAuthorId!),
        },
        "category": {
          "id": selectedCategory['id'],
          "label": selectedCategory['label'],
          "code": selectedCategory['code'],
        },
        "copies": copies, // Add copies here
      };

      try {
        // Use the new method for Web: createBookWithImageFromBytes
        await bookService.createBookWithImageFromBytes(newBook, _imageBytes!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book created successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        _showErrorDialog('Failed to create book: $e');
      }
    } else {
      _showErrorDialog('Please fill all required fields (including an image).');
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
          .map(
            (author) => DropdownMenuItem(
              value: author['id'].toString(),
              child: Text(author['fullName'] ?? ''),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedAuthorId = value;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Select Category*',
        border: OutlineInputBorder(),
      ),
      items: categories
          .map(
            (cat) => DropdownMenuItem(
              value: cat['id'].toString(),
              child: Text(cat['label'] ?? ''),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildCopyFields() {
    return Column(
      children: [
        for (int i = 0; i < copyControllers.length; i++)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    'Serial Number ${i + 1}', copyControllers[i]),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => removeCopyField(i),
              ),
            ],
          ),
        ElevatedButton(
          onPressed: addCopyField,
          child: const Text('Add Copy'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Book (Web)'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            _buildTextField('Number of Copies*', numberOfCopiesController,
                keyboardType: TextInputType.number),
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
            _buildCategoryDropdown(),
            const SizedBox(height: 16.0),
            _buildCopyFields(), // Add Copy Fields Here
            const SizedBox(height: 16.0),
            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                width: 100,
                height: 100,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
