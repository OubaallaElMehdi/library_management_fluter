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
    return Client(
      id: json['id'],
      email: json['email'] ?? 'Unknown Email',
      username: json['username'] ?? 'Unknown Username',
      phone: json['phone'] ?? 'Unknown Phone',
      role: json['roleUsers'][0]['role']['authority'] ?? 'Unknown Role',
      firstName: json['firstName'] ?? 'Unknown First Name',
      lastName: json['lastName'] ?? 'Unknown Last Name',
    );
  }
}
