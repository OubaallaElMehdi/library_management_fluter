import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({Key? key}) : super(key: key);

  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final UserService clientService = UserService();
  late Future<List<Client>> futureClients;

  @override
  void initState() {
    super.initState();
    futureClients = clientService.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Action de recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Action de tri
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Client>>(
                future: futureClients,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No clients available.'));
                  }

                  final clients = snapshot.data!;
                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return UserCard(
                        fullname: client.fullname,
                        email: client.email,
                        phone: client.phone,
                        role: client.role,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String fullname;
  final String email;
  final String phone;
  final String role;

  const UserCard({
    Key? key,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue[100],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fullname: $fullname', style: const TextStyle(fontSize: 16)),
            Text('Email: $email', style: const TextStyle(fontSize: 16)),
            Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
            Text('Role: $role', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Action de mise à jour
                  },
                  child: const Text('Update', style: TextStyle(color: Colors.green)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // Action de suppression
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}