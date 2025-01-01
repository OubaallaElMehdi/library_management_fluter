import 'package:flutter/material.dart';
import 'package:library_management/views/admin/admin_dashboard.dart';
import 'package:library_management/views/admin/book_management.dart';
import 'package:library_management/views/user/manage_users.dart';
import 'package:library_management/views/user/user_dashboard.dart';
import 'package:library_management/views/admin/book_admin_page.dart'; // New Admin Book Page
import 'package:library_management/views/user/book_user_page.dart'; // New User Book Page
import 'views/login_screen.dart';
import 'views/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/manage-users': (context) => const ManageUsers(),
        '/admin-settings': (context) => Scaffold(
              appBar: AppBar(title: const Text('Admin Settings')),
              body: const Center(child: Text('Admin Settings Page')),
            ),
        // New Routes
        '/admin_book_management': (context) =>
            const BookManagementPage(), // New Admin Book Management Page

        '/admin-book-page': (context) => const BookAdminPage(),
        '/user-book-page': (context) => const BookUserPage(),
      },
    );
  }
}
