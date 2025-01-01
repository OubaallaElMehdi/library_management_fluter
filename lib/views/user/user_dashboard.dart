import 'package:flutter/material.dart';
import 'package:library_management/widgets/custom_drawer.dart';
import 'package:library_management/widgets/custom_text_field.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      drawer: const CustomDrawer(role: 'User'),
      body: const Center(
        child: Text('Welcome to the User Dashboard'),
      ),
    );
  }
}
