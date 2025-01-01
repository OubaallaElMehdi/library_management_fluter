import 'package:flutter/material.dart';
import 'package:library_management/services/user_service.dart';
import 'package:library_management/models/user.dart';

class ListUserPage extends StatefulWidget {
  const ListUserPage({Key? key}) : super(key: key);

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  final UserService userService = UserService();
  late Future<Map<String, dynamic>> usersFuture;
  int currentPage = 0;
  final int maxResults = 8;

  @override
  void initState() {
    super.initState();
    usersFuture = fetchUsers();
  }

  Future<Map<String, dynamic>> fetchUsers() {
    return userService.fetchPaginatedUsers(
      page: currentPage,
      maxResults: maxResults,
      sortOrder: 'ASC',
      sortField: 'fullname',
    );
  }

  void deleteUser(String userId) async {
    try {
      await userService.deleteUser(int.parse(userId));
      setState(() {
        usersFuture = fetchUsers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${e.toString()}')),
      );
    }
  }

  void loadNextPage() {
    setState(() {
      currentPage++;
      usersFuture = fetchUsers();
    });
  }

  void loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        usersFuture = fetchUsers();
      });
    }
  }

  void showUpdateUserDialog(Client user) {
    final fullnameController = TextEditingController(text: user.fullname);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final roleController = TextEditingController(text: user.role);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: SingleChildScrollView(
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userService.updateUser({
                    'id': user.id,
                    'fullname': fullnameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'role': roleController.text,
                  });
                  Navigator.pop(context); // Close the dialog
                  setState(() {
                    usersFuture = fetchUsers(); // Refresh the user list
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error updating user: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['list'].isEmpty) {
            return const Center(child: Text('No users available.'));
          }

          final users = snapshot.data!['list'];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(user['fullname'] ?? 'Unknown Name'),
                        subtitle: Text(user['email'] ?? 'Unknown Email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                showUpdateUserDialog(Client.fromJson(
                                    user)); // Show dialog for editing user
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteUser(user['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 0 ? loadPreviousPage : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: loadNextPage,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
