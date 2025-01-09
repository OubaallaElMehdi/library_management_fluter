import 'package:flutter/material.dart';
import 'package:library_management/services/CopyService.dart';
import 'package:library_management/models/copy.dart';
import 'package:library_management/views/admin/copys/copy_create_page.dart';

class CopyAdminPage extends StatefulWidget {
  const CopyAdminPage({super.key});

  @override
  State<CopyAdminPage> createState() => _CopyAdminPageState();
}

class _CopyAdminPageState extends State<CopyAdminPage> {
  final CopyService copyService = CopyService();

  late Future<List<Copy>> copiesFuture;
  int currentPage = 0;
  final int maxResults = 2; // Or however many you want per page

  @override
  void initState() {
    super.initState();
    copiesFuture = fetchCopies();
  }

  Future<List<Copy>> fetchCopies() async {
    final response = await copyService.fetchPaginatedCopies(
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'serialNumber', // or another field
    );
    // response = { "list": [...], "dataSize": X }
    final List<dynamic> data = response['list'];
    return data.map((json) => Copy.fromJson(json)).toList();
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
      copiesFuture = fetchCopies();
    });
  }

  void loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        copiesFuture = fetchCopies();
      });
    }
  }

  void goToCreateCopyPage() async {
    // Navigate to create copy page
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCopyPage()),
    );
    // After returning, refresh list
    setState(() {
      copiesFuture = fetchCopies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Copies'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Button to create copy
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: goToCreateCopyPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Create New Copy'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Copy>>(
              future: copiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No copies found.'),
                  );
                }

                final copies = snapshot.data!;
                return ListView.builder(
                  itemCount: copies.length,
                  itemBuilder: (context, index) {
                    final copy = copies[index];
                    final bookMap = copy.book;
                    // bookMap = { "id":..., "title":..., etc. }

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.blue[50],
                      child: ListTile(
                        title: Text('Serial: ${copy.serialNumber}'),
                        subtitle: Text('Book Title: ${bookMap["title"] ?? ""}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Pagination
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
