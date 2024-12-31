import 'package:flutter/material.dart';
import 'package:library_management/views/admin/admin_dashboard.dart';
import 'package:library_management/views/user/user_dashboard.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';

import 'views/book_catalog_page.dart';

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
        '/catalog': (context) => const BookCatalogPage(),
        '/manage-users': (context) => Scaffold(
              appBar: AppBar(title: const Text('Manage Users')),
              body: const Center(child: Text('Manage Users Page')),
            ),
        '/admin-settings': (context) => Scaffold(
              appBar: AppBar(title: const Text('Admin Settings')),
              body: const Center(child: Text('Admin Settings Page')),
            ),
      },
    );
  }
}
