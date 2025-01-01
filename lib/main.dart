import 'package:flutter/material.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/views/admin/admin_dashboard.dart';
import 'package:library_management/views/admin/books/book_management.dart';
import 'package:library_management/views/admin/user_managment/list_user.dart';
import 'package:library_management/views/admin/user_managment/update_user.dart';
import 'package:library_management/views/user/user_dashboard.dart';
import 'package:library_management/views/admin/books/book_admin_page.dart';
import 'package:library_management/views/user/books/book_user_page.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => RegisterPage(),
        '/admin': (context) => const AdminDashboard(),
        '/user': (context) => const UserDashboard(),
        '/admin-settings': (context) => Scaffold(
            appBar: AppBar(title: const Text('Admin Settings')),
            body: const Center(child: Text('Admin Settings Page'))),
        '/admin_book_management': (context) => const BookManagementPage(),
        '/manage-users': (context) => const ListUserPage(),
        '/admin-book-page': (context) => const BookAdminPage(),
        '/user-book-page': (context) => const BookUserPage(),
      },
      onGenerateRoute: (settings) {
        // Check if the route is for updating a user
        if (settings.name == '/update-user') {
          final client = settings.arguments as Client;
          return MaterialPageRoute(
            builder: (context) => UpdateUserPage(user: client),
          );
        }
        return null; // Let the framework handle other routes
      },
    );
  }
}
