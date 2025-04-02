class Ticket {
  final String ticketNumber;
  final String flightNumber;
  final String passengerName;
  final String seatNumber;
  final String travelClass;
  final bool isCheckedIn;
  final String bookingReference;
  final String boardingGroup;
  final DateTime issueDate;
  final double? baggageAllowance;
  final bool hasPriorityBoarding;
  final List<String> services; // Additional services

  Ticket({
    required this.ticketNumber,
    required this.flightNumber,
    required this.passengerName,
    required this.seatNumber,
    required this.travelClass,
    required this.isCheckedIn,
    required this.bookingReference,
    required this.boardingGroup,
    required this.issueDate,
    this.baggageAllowance,
    this.hasPriorityBoarding = false,
    this.services = const [],
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketNumber: json['ticketNumber'],
      flightNumber: json['flightNumber'],
      passengerName: json['passengerName'],
      seatNumber: json['seatNumber'],
      travelClass: json['travelClass'],
      isCheckedIn: json['isCheckedIn'] ?? false,
      bookingReference: json['bookingReference'],
      boardingGroup: json['boardingGroup'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      baggageAllowance: json['baggageAllowance'],
      hasPriorityBoarding: json['hasPriorityBoarding'] ?? false,
      services: List<String>.from(json['services'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketNumber': ticketNumber,
      'flightNumber': flightNumber,
      'passengerName': passengerName,
      'seatNumber': seatNumber,
      'travelClass': travelClass,
      'isCheckedIn': isCheckedIn,
      'bookingReference': bookingReference,
      'boardingGroup': boardingGroup,
      'issueDate': issueDate.toIso8601String(),
      'baggageAllowance': baggageAllowance,
      'hasPriorityBoarding': hasPriorityBoarding,
      'services': services,
    };
  }
}