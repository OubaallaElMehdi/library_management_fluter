import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final String role; // Either "Admin" or "User"

  const CustomDrawer({super.key, required this.role});

  void handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Library App',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.library_books,
                    color: Color.fromARGB(255, 4, 95, 169),
                  ),
                  title: const Text('Book Catalog'),
                  onTap: () {
                    // Navigate based on role
                    if (role == 'Admin') {
                      Navigator.pushNamed(context, '/admin_list_book');
                    } else {
                      Navigator.pushNamed(context, '/user-list-book');
                    }
                  },
                ),
                if (role == 'Admin') ...[
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('Manage Books'),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_manage_book');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('Manage copys'),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_list_copy');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.book_online,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('Manage Reservations'),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_list_reservations');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('Manage Users'),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_list_user');
                    },
                  ),
                  /*
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('Admin Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin-settings');
                    },
                  ),
                  */
                  ListTile(
                    leading: const Icon(
                      Icons.chat,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('ChatBot'),
                    onTap: () {
                      Navigator.pushNamed(context, '/chatbot');
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(
                      Icons.bookmark,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('My Reservations'),
                    onTap: () {
                      Navigator.pushNamed(context, '/client-reservations');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.chat,
                      color: Color.fromARGB(255, 4, 95, 169),
                    ),
                    title: const Text('ChatBot'),
                    onTap: () {
                      Navigator.pushNamed(context, '/ChatBotClient');
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                handleLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
