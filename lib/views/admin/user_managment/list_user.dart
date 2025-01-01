import 'package:flutter/material.dart';
import 'package:library_management/models/user.dart';
import 'package:library_management/services/user_service.dart';
import 'package:library_management/views/admin/user_managment/update_user.dart';

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
                        title: Text(user['firstName'] ?? 'Unknown Name'),
                        subtitle: Text(user['email'] ?? 'Unknown Email'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateUserPage(
                                        user: Client.fromJson(user)),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    usersFuture = fetchUsers();
                                  });
                                });
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
