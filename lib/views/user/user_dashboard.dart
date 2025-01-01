import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

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
        child: ListView(
          children: [
            UserCard(
              fullname: 'Khalil Zouizza',
              email: 'KhalilZouizza@gmail.com',
              phone: '+212 777 777 777',
              role: 'Admin',
            ),
            UserCard(
              fullname: 'Khalil Zouizza',
              email: 'KhalilZouizza@gmail.com',
              phone: '+212 777 777 777',
              role: 'Admin',
            ),
            UserCard(
              fullname: 'Khalil Zouizza',
              email: 'KhalilZouizza@gmail.com',
              phone: '+212 777 777 777',
              role: 'Admin',
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
