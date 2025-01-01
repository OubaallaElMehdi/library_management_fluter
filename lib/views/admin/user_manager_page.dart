import 'package:flutter/material.dart';
import 'package:library_management/models/client_dto.dart';

import '../../services/user_service.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('User Manager'),
    ),
    body: FutureBuilder<List<ClientDto>>(
      future: UserService().fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users available.'));
        }

        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.fullname),
              subtitle: Text(user.email),
            );
          },
        );
      },
    ),
  );
}