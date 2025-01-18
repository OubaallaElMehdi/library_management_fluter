class Reservationitem {
  final int id; // New id field
  final String booklabel;
  final String requestDate;
  final String theoreticalReturnDate;
  final String? effectiveReturnDate;
  final List<dynamic> reservationItems;
  final Map<String, dynamic> client;
  final String code; // Code is now initialized in the constructor
  final ReservationState? reservationState;

  Reservationitem({
    required this.id, // Require id
    required this.booklabel,
    required this.requestDate,
    required this.theoreticalReturnDate,
    this.effectiveReturnDate,
    required this.reservationItems,
    required this.client,
    required this.code, // Make `code` required
    this.reservationState,
  });

  // Static variable to store the last generated code
  static int _lastCode = 1000;

  // Static method to generate the reservation code
  static String generateCode() {
    _lastCode++; // Increment the code
    return 'R$_lastCode'; // Format the code (e.g., R1001, R1002)
  }

  // Factory constructor for creating instances from JSON
  factory Reservationitem.fromJson(Map<String, dynamic> json) {
    return Reservationitem(
      id: json['id'] ?? 0, // Default id to 0 if not provided
      booklabel: json['booklabel'] ?? '',
      requestDate: json['requestDate'] ?? '',
      theoreticalReturnDate: json['theoreticalReturnDate'] ?? '',
      effectiveReturnDate: json['effectiveReturnDate'],
      reservationItems: json['reservationItems'] ?? [],
      client: json['client'] ?? {},
      code: json['code'] ?? '', // Initialize code from JSON or use default
      reservationState: json['reservationState'] != null
          ? ReservationState.fromJson(json['reservationState'])
          : null,
    );
  }

  // Method for converting instances to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id in the JSON
      'booklabel': booklabel,
      'requestDate': requestDate,
      'theoreticalReturnDate': theoreticalReturnDate,
      'effectiveReturnDate': effectiveReturnDate,
      'reservationItems': reservationItems,
      'client': client,
      'code': code,
      'reservationState': reservationState?.toJson(),
    };
  }
}

class ReservationState {
  final int id;
  final String label;
  final String style;
  final String code;

  ReservationState({
    required this.id,
    required this.label,
    required this.style,
    required this.code,
  });

  factory ReservationState.fromJson(Map<String, dynamic> json) {
    return ReservationState(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      style: json['style'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'style': style,
      'code': code,
    };
  }
}
