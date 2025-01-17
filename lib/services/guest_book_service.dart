import 'dart:convert';
import 'package:http/http.dart' as http;

class GuestBookService {
  final String baseUrl = 'http://localhost:8090/BOOKS-SERVICE';

  Future<Map<String, dynamic>> fetchPaginatedBooks({
    required String endpoint,
    required int page,
    required int maxResults,
    required String sortOrder,
    required String sortField,
  }) async {
    // Construct the full API URL
    final url = Uri.parse('$baseUrl$endpoint');

    // Log request details for debugging
    print('Fetching books from: $url');
    print(
        'Request Body: {"page": $page, "maxResults": $maxResults, "sortOrder": "$sortOrder", "sortField": "$sortField"}');

    // Make the POST request without a token
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "page": page,
        "maxResults": maxResults,
        "sortOrder": sortOrder,
        "sortField": sortField,
      }),
    );

    // Check response status and parse data
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.body}');
      throw Exception('Failed to fetch books: ${response.body}');
    }
  }
}
