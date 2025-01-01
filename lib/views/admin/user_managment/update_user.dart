import 'package:flutter/material.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/services/user_service.dart';

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final UserService userService = UserService();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  late String userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Client user = ModalRoute.of(context)!.settings.arguments as Client;
    userId = user.id;
    fullnameController.text = user.fullname;
    emailController.text = user.email;
    phoneController.text = user.phone;
    roleController.text = user.role;
  }

  void updateUser() async {
    try {
      await userService.updateUser({
        'id': userId,
        'fullname': fullnameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'role': roleController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context); // Return to the list page after updating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fullnameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateUser,
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
