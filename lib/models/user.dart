class Client {
  final String id; // Make sure id is defined as String here
  final String fullname;
  final String email;
  final String phone;
  final String role;

  Client({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id']
          .toString(), // Ensure the id is converted to a String if it's an int
      fullname: json['fullname'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}
