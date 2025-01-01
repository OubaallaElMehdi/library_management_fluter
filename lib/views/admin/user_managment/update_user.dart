import 'package:flutter/material.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/services/user_service.dart';

class UpdateUserPage extends StatefulWidget {
  final Client user;

  const UpdateUserPage({super.key, required this.user});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final UserService userService = UserService();

  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the user data passed to the page
    emailController = TextEditingController(text: widget.user.email);
    usernameController = TextEditingController(text: widget.user.username);
    phoneController = TextEditingController(text: widget.user.phone);
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    selectedRole = widget.user.role; // Assuming `role` is a string here
  }

  Future<void> updateUser() async {
    final updatedUser = {
      "id": widget.user.id,
      "email": emailController.text,
      "username": usernameController.text,
      "phone": phoneController.text,
      "roleUsers": [
        {
          "id": 1, // ROLE_ADMIN (or other depending on selection)
          "role": {
            "id": selectedRole == "ROLE_ADMIN"
                ? 1
                : 2, // Based on the role dropdown
            "authority": selectedRole
          }
        }
      ],
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "accountNonExpired": true, // Assuming fixed values
      "accountNonLocked": true,
      "credentialsNonExpired": true,
      "passwordChanged": false, // Assuming fixed values
    };

    await userService.updateUser(updatedUser);
    Navigator.pop(context); // Close the update page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            DropdownButton<String>(
              value: selectedRole,
              items: ['ROLE_ADMIN', 'ROLE_USER']
                  .map((role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateUser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}
