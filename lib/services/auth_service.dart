import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:library_management/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8090';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/AUTH-SERVICE/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save token, username, and email
      await saveToken(data['accessToken'], data['username'], data['email']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Updated saveToken method to include username and email
  Future<void> saveToken(String token, String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // Save token
    await prefs.setString('username', username); // Save username
    await prefs.setString('email', email); // Save email
  }

  Future<String?> getClientUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<Client> getClientDetails(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the saved token

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/AUTH-SERVICE/user/$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add Authorization header
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Client.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to fetch client details: ${response.body}');
    }
  }

  // Retrieve token of the logged-in client
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Retrieve the saved token
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void handleLogin() async {
    try {
      final response = await authService.login(
        usernameController.text,
        passwordController.text,
      );

      // Debug the response structure
      print('Response: $response');

      // Check roles
      final List roles =
          response['roles'] ?? []; // Default to an empty list if null
      if (roles.isEmpty) {
        throw Exception('No roles found in the response.');
      }

      if (roles.contains('ROLE_ADMIN')) {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else if (roles.contains('ROLE_CLIENT')) {
        Navigator.pushReplacementNamed(context, '/userDashboard');
      } else {
        throw Exception('Unknown role');
      }
    } catch (error) {
      print('Login failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
