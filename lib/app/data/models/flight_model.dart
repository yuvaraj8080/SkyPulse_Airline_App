import 'package:get/get.dart';

class Flight {
  final String flightNumber;
  final String airline;
  final String status;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String departureAirport;
  final String departureCity;
  final String departureCountry;
  final String departureTerminal;
  final String departureGate;
  final String arrivalAirport;
  final String arrivalCity;
  final String arrivalCountry;
  final String arrivalTerminal;
  final String arrivalGate;
  final String aircraft;
  final Duration duration;
  final int distanceKm;
  final double? delayMinutes;
  final bool isCancelled;
  final List<FlightPosition>? positions;
  final bool isFavorite;

  Flight({
    required this.flightNumber,
    required this.airline,
    required this.status,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.departureCity,
    required this.departureCountry,
    required this.departureTerminal,
    required this.departureGate,
    required this.arrivalAirport,
    required this.arrivalCity,
    required this.arrivalCountry,
    required this.arrivalTerminal,
    required this.arrivalGate,
    required this.aircraft,
    required this.duration,
    required this.distanceKm,
    this.delayMinutes,
    this.isCancelled = false,
    this.positions,
    this.isFavorite = false,
  });

  Flight copyWith({
    String? flightNumber,
    String? airline,
    String? status,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? departureAirport,
    String? departureCity,
    String? departureCountry,
    String? departureTerminal,
    String? departureGate,
    String? arrivalAirport,
    String? arrivalCity,
    String? arrivalCountry,
    String? arrivalTerminal,
    String? arrivalGate,
    String? aircraft,
    Duration? duration,
    int? distanceKm,
    double? delayMinutes,
    bool? isCancelled,
    List<FlightPosition>? positions,
    bool? isFavorite,
  }) {
    return Flight(
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      status: status ?? this.status,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureAirport: departureAirport ?? this.departureAirport,
      departureCity: departureCity ?? this.departureCity,
      departureCountry: departureCountry ?? this.departureCountry,
      departureTerminal: departureTerminal ?? this.departureTerminal,
      departureGate: departureGate ?? this.departureGate,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      arrivalCountry: arrivalCountry ?? this.arrivalCountry,
      arrivalTerminal: arrivalTerminal ?? this.arrivalTerminal,
      arrivalGate: arrivalGate ?? this.arrivalGate,
      aircraft: aircraft ?? this.aircraft,
      duration: duration ?? this.duration,
      distanceKm: distanceKm ?? this.distanceKm,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      isCancelled: isCancelled ?? this.isCancelled,
      positions: positions ?? this.positions,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flightNumber': flightNumber,
      'airline': airline,
      'status': status,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'departureAirport': departureAirport,
      'departureCity': departureCity,
      'departureCountry': departureCountry,
      'departureTerminal': departureTerminal,
      'departureGate': departureGate,
      'arrivalAirport': arrivalAirport,
      'arrivalCity': arrivalCity,
      'arrivalCountry': arrivalCountry,
      'arrivalTerminal': arrivalTerminal,
      'arrivalGate': arrivalGate,
      'aircraft': aircraft,
      'duration': duration.inMinutes,
      'distanceKm': distanceKm,
      'delayMinutes': delayMinutes,
      'isCancelled': isCancelled,
      'positions': positions?.map((position) => position.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNumber: json['flightNumber'],
      airline: json['airline'],
      status: json['status'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      departureAirport: json['departureAirport'],
      departureCity: json['departureCity'],
      departureCountry: json['departureCountry'],
      departureTerminal: json['departureTerminal'] ?? '',
      departureGate: json['departureGate'] ?? '',
      arrivalAirport: json['arrivalAirport'],
      arrivalCity: json['arrivalCity'],
      arrivalCountry: json['arrivalCountry'],
      arrivalTerminal: json['arrivalTerminal'] ?? '',
      arrivalGate: json['arrivalGate'] ?? '',
      aircraft: json['aircraft'] ?? 'Unknown',
      duration: Duration(minutes: json['duration']),
      distanceKm: json['distanceKm'] ?? 0,
      delayMinutes: json['delayMinutes'],
      isCancelled: json['isCancelled'] ?? false,
      positions: json['positions'] != null
          ? (json['positions'] as List)
              .map((position) => FlightPosition.fromJson(position))
              .toList()
          : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Parse from Aviation Stack API response
  factory Flight.fromAviationStackApi(Map<String, dynamic> json) {
    final flight = json['flight'];
    final departure = json['departure'];
    final arrival = json['arrival'];
    final aircraft = json['aircraft'] ?? {};
    final airline = json['airline'] ?? {};
    final status = json['flight_status'] ?? 'scheduled';
    
    return Flight(
      flightNumber: flight['iata'] ?? flight['icao'] ?? 'Unknown',
      airline: airline['name'] ?? 'Unknown Airline',
      status: status,
      departureTime: departure['scheduled'] != null 
          ? DateTime.parse(departure['scheduled']) 
          : DateTime.now(),
      arrivalTime: arrival['scheduled'] != null 
          ? DateTime.parse(arrival['scheduled']) 
          : DateTime.now().add(const Duration(hours: 2)),
      departureAirport: departure['iata'] ?? departure['icao'] ?? 'Unknown',
      departureCity: departure['airport'] ?? 'Unknown City',
      departureCountry: departure['country'] ?? 'Unknown Country',
      departureTerminal: departure['terminal'] ?? '',
      departureGate: departure['gate'] ?? '',
      arrivalAirport: arrival['iata'] ?? arrival['icao'] ?? 'Unknown',
      arrivalCity: arrival['airport'] ?? 'Unknown City',
      arrivalCountry: arrival['country'] ?? 'Unknown Country',
      arrivalTerminal: arrival['terminal'] ?? '',
      arrivalGate: arrival['gate'] ?? '',
      aircraft: aircraft['registration'] ?? 'Unknown',
      duration: Duration(minutes: json['flight_duration'] ?? 120),
      distanceKm: json['distance'] ?? 0,
      delayMinutes: departure['delay'] != null ? double.parse(departure['delay'].toString()) : null,
      isCancelled: status.toLowerCase() == 'cancelled',
      positions: null,
      isFavorite: false,
    );
  }
  
  bool isDelayed() {
    return delayMinutes != null && delayMinutes! > 0;
  }
  
  bool isDeparted() {
    return DateTime.now().isAfter(departureTime);
  }
  
  bool isArrived() {
    return DateTime.now().isAfter(arrivalTime);
  }
  
  bool isInFlight() {
    final now = DateTime.now();
    return now.isAfter(departureTime) && now.isBefore(arrivalTime);
  }
  
  double getProgressPercentage() {
    if (!isDeparted()) {
      return 0.0;
    }
    
    if (isArrived()) {
      return 1.0;
    }
    
    final totalDuration = arrivalTime.difference(departureTime).inMinutes;
    final elapsedDuration = DateTime.now().difference(departureTime).inMinutes;
    
    return elapsedDuration / totalDuration;
  }
}

class FlightPosition {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  FlightPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FlightPosition.fromJson(Map<String, dynamic> json) {
    return FlightPosition(
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
      speed: json['speed'],
      heading: json['heading'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
