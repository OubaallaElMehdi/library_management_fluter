class Client {
  final String fullname;
  final String email;
  final String phone;
  final String role;

  Client({
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      fullname: json['fullname'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}