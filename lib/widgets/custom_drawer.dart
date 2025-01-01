import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final String role; // Either "Admin" or "User"

  const CustomDrawer({Key? key, required this.role}) : super(key: key);

  void handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove the token

    Navigator.pushReplacementNamed(context, '/'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.book, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Library App',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Book Catalog'),
            onTap: () {
              // Navigate based on role
              if (role == 'Admin') {
                Navigator.pushNamed(
                    context, '/admin-book-page'); // Admin catalog
              } else {
                Navigator.pushNamed(context, '/user-book-page'); // User catalog
              }
            },
          ),
          if (role == 'Admin') ...[
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Book Management Page'),
              onTap: () {
                Navigator.pushNamed(context, '/admin_book_management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pushNamed(context, '/manage-users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/admin-settings');
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              handleLogout(context);
            },
          ),
        ],
      ),
    );
  }
}