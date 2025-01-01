class ClientDto {
  final String fullname;
  final String email;
  final String phone;
  final String role;

  ClientDto({
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
  });

  // Add this method to convert JSON to ClientDto
  factory ClientDto.fromJson(Map<String, dynamic> json) {
    return ClientDto(
      fullname: json['fullname'] ?? 'Unknown',
      email: json['email'] ?? 'No Email',
      phone: json['phone'] ?? 'No Phone',
      role: json['role'] ?? 'No Role',
    );
  }

  // Optionally, you can add a method to convert to Map if needed
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}