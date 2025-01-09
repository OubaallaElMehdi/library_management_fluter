class Client {
  final int id;
  final String email;
  final String username;
  final String phone;
  final String role;
  final String firstName;
  final String lastName;

  Client({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    // Adjust as needed based on actual JSON structure from your server
    return Client(
      id: json['id'] ?? 0,
      email: json['email'] ?? 'Unknown Email',
      username: json['username'] ?? 'Unknown Username',
      phone: json['phone'] ?? 'Unknown Phone',
      // If your server returns a list under "roles" or "roleUsers"
      // We'll handle that gracefully:
      role: json['roleUsers'] != null && (json['roleUsers'] as List).isNotEmpty
          ? json['roleUsers'][0]['role']['authority'] ?? 'Unknown Role'
          : (json['roles'] != null && (json['roles'] as List).isNotEmpty
              ? json['roles'][0]
              : 'Unknown Role'),
      firstName: json['firstName'] ?? 'Unknown First Name',
      lastName: json['lastName'] ?? 'Unknown Last Name',
    );
  }
}
