import 'client_dto.dart';

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

  factory Client.fromDto(ClientDto dto) {
    return Client(
      fullname: dto.fullname,
      email: dto.email,
      phone: dto.phone,
      role: dto.role,
    );
  }
}