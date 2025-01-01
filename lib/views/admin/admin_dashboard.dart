import 'package:flutter/material.dart';
import 'package:library_management/widgets/custom_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const CustomDrawer(role: 'Admin'),
      body: const Center(
        child: Text('Welcome to the Admin Dashboard'),
      ),
    );
  }
}
