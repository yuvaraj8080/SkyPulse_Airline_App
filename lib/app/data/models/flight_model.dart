import 'package:equatable/equatable.dart';

class Flight extends Equatable {
  final String flightNumber;
  final String airline;
  final String airlineName;
  final String departureAirport;
  final String arrivalAirport;
  final String departureCity;
  final String arrivalCity;
  final DateTime? scheduledDeparture;
  final DateTime? scheduledArrival;
  final DateTime? actualDeparture;
  final DateTime? actualArrival;
  final String status;
  final int departureDelayMinutes;
  final int arrivalDelayMinutes;
  final bool isCancelled;
  final bool isDiverted;
  final String aircraftRegistration;
  final String aircraftType;
  final double? onTimePercentage;
  final List<FlightRoute> alternativeRoutes;
  final List<FlightDelay> delayHistory;
  final bool isFavorite;
  final String? terminal;
  final String? gate;
  final double? distance;
  final int? flightDuration;
  final List<String>? flightServices;

  const Flight({
    required this.flightNumber,
    required this.airline,
    required this.airlineName,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureCity,
    required this.arrivalCity,
    this.scheduledDeparture,
    this.scheduledArrival,
    this.actualDeparture,
    this.actualArrival,
    required this.status,
    this.departureDelayMinutes = 0,
    this.arrivalDelayMinutes = 0,
    this.isCancelled = false,
    this.isDiverted = false,
    this.aircraftRegistration = '',
    this.aircraftType = '',
    this.onTimePercentage,
    this.alternativeRoutes = const [],
    this.delayHistory = const [],
    this.isFavorite = false,
    this.terminal,
    this.gate,
    this.distance,
    this.flightDuration,
    this.flightServices,
  });

  // Helper method to check if flight is delayed
  bool isDelayed() {
    return departureDelayMinutes > 15 || arrivalDelayMinutes > 15;
  }

  // Helper method to check if flight is on time
  bool isOnTime() {
    return !isDelayed() && !isCancelled && !isDiverted;
  }

  // Helper method to get delay status text
  String getDelayStatusText() {
    if (isCancelled) return 'Cancelled';
    if (isDiverted) return 'Diverted';
    if (departureDelayMinutes > 120 || arrivalDelayMinutes > 120) return 'Severely Delayed';
    if (departureDelayMinutes > 60 || arrivalDelayMinutes > 60) return 'Very Delayed';
    if (departureDelayMinutes > 15 || arrivalDelayMinutes > 15) return 'Delayed';
    return 'On Time';
  }

  // Factory method to create from AeroDataBox API response
  factory Flight.fromAeroDataBoxApi(Map<String, dynamic> json) {
    final departure = json['departure'] ?? {};
    final arrival = json['arrival'] ?? {};
    final aircraft = json['aircraft'] ?? {};
    final airline = json['airline'] ?? {};
    final flightStatus = json['status'] ?? 'Unknown';

    // Handle DateTime parsing safely
    DateTime? parseDateTime(Map<String, dynamic>? timeData) {
      if (timeData == null || timeData['utc'] == null) return null;
      try {
        return DateTime.parse(timeData['utc']);
      } catch (e) {
        print('Error parsing DateTime: $e');
        return null;
      }
    }

    // Handle integer values safely
    int parseIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is bool) return value ? 1 : 0;
      try {
        // For string values, handle both numeric strings and other formats
        final stringValue = value.toString().trim();
        if (stringValue.isEmpty) return 0;

        // Try parsing as double first to handle decimal strings
        return double.parse(stringValue).toInt();
      } catch (e) {
        print('Error parsing int value: $e for $value');
        return 0;
      }
    }

    // Handle double values safely
    double? parseDoubleValue(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      try {
        return double.parse(value.toString());
      } catch (e) {
        print('Error parsing double value: $e for $value');
        return null;
      }
    }

    // Extract distance safely
    double? distance;
    if (json['greatCircleDistance'] != null) {
      try {
        if (json['greatCircleDistance'] is Map) {
          // AeroDataBox returns a Map with different units - we'll use km
          final distanceMap = json['greatCircleDistance'] as Map;
          if (distanceMap.containsKey('km')) {
            distance = parseDoubleValue(distanceMap['km']);
          }
        } else {
          distance = parseDoubleValue(json['greatCircleDistance']);
        }
      } catch (e) {
        print('Error parsing distance: $e');
      }
    }

    // Calculate flight duration if not provided
    int? flightDuration;
    if (json['flightTime'] != null) {
      try {
        if (json['flightTime'] is String) {
          flightDuration = parseIntValue(json['flightTime']);
        } else if (json['flightTime'] is int) {
          flightDuration = json['flightTime'];
        } else if (json['flightTime'] is double) {
          flightDuration = json['flightTime'].toInt();
        }
      } catch (e) {
        print('Error parsing flightTime: $e');
      }
    } else {
      // If flightTime is not provided, estimate based on scheduled times
      final scheduledDep = parseDateTime(departure['scheduledTime']);
      final scheduledArr = parseDateTime(arrival['scheduledTime']);
      if (scheduledDep != null && scheduledArr != null) {
        final diff = scheduledArr.difference(scheduledDep).inMinutes;
        if (diff > 0) flightDuration = diff;
      }
    }

    return Flight(
      flightNumber: json['number'] ?? '',
      airline: airline['iata'] ?? '',
      airlineName: airline['name'] ?? '',
      departureAirport: departure['airport']?['iata'] ?? '',
      arrivalAirport: arrival['airport']?['iata'] ?? '',
      departureCity: departure['airport']?['municipalityName'] ?? departure['airport']?['name'] ?? '',
      arrivalCity: arrival['airport']?['municipalityName'] ?? arrival['airport']?['name'] ?? '',
      scheduledDeparture: parseDateTime(departure['scheduledTime']),
      scheduledArrival: parseDateTime(arrival['scheduledTime']),
      actualDeparture: parseDateTime(departure['actualTime']),
      actualArrival: parseDateTime(arrival['actualTime']),
      status: flightStatus,
      departureDelayMinutes: parseIntValue(departure['delay']),
      arrivalDelayMinutes: parseIntValue(arrival['delay']),
      isCancelled: flightStatus.toLowerCase() == 'cancelled',
      isDiverted: flightStatus.toLowerCase() == 'diverted',
      aircraftRegistration: aircraft['reg'] ?? '',
      aircraftType: aircraft['model'] ?? '',
      terminal: departure['terminal'] ?? arrival['terminal'],
      gate: departure['gate'] ?? arrival['gate'],
      distance: distance,
      flightDuration: flightDuration,
    );
  }

  // Method to convert Flight object to JSON
  Map<String, dynamic> toJson() {
    return {
      'flightNumber': flightNumber,
      'airline': airline,
      'airlineName': airlineName,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureCity': departureCity,
      'arrivalCity': arrivalCity,
      'scheduledDeparture': scheduledDeparture?.toIso8601String(),
      'scheduledArrival': scheduledArrival?.toIso8601String(),
      'actualDeparture': actualDeparture?.toIso8601String(),
      'actualArrival': actualArrival?.toIso8601String(),
      'status': status,
      'departureDelayMinutes': departureDelayMinutes,
      'arrivalDelayMinutes': arrivalDelayMinutes,
      'isCancelled': isCancelled,
      'isDiverted': isDiverted,
      'aircraftRegistration': aircraftRegistration,
      'aircraftType': aircraftType,
      'onTimePercentage': onTimePercentage,
      'alternativeRoutes': alternativeRoutes.map((route) => route.toJson()).toList(),
      'delayHistory': delayHistory.map((delay) => delay.toJson()).toList(),
      'isFavorite': isFavorite,
      'terminal': terminal,
      'gate': gate,
      'distance': distance,
      'flightDuration': flightDuration,
      'flightServices': flightServices,
    };
  }

  // Create a copy of Flight with some fields changed
  Flight copyWith({
    String? flightNumber,
    String? airline,
    String? airlineName,
    String? departureAirport,
    String? arrivalAirport,
    String? departureCity,
    String? arrivalCity,
    DateTime? scheduledDeparture,
    DateTime? scheduledArrival,
    DateTime? actualDeparture,
    DateTime? actualArrival,
    String? status,
    int? departureDelayMinutes,
    int? arrivalDelayMinutes,
    bool? isCancelled,
    bool? isDiverted,
    String? aircraftRegistration,
    String? aircraftType,
    double? onTimePercentage,
    List<FlightRoute>? alternativeRoutes,
    List<FlightDelay>? delayHistory,
    bool? isFavorite,
    String? terminal,
    String? gate,
    double? distance,
    int? flightDuration,
    List<String>? flightServices,
  }) {
    return Flight(
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      airlineName: airlineName ?? this.airlineName,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureCity: departureCity ?? this.departureCity,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      scheduledDeparture: scheduledDeparture ?? this.scheduledDeparture,
      scheduledArrival: scheduledArrival ?? this.scheduledArrival,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      actualArrival: actualArrival ?? this.actualArrival,
      status: status ?? this.status,
      departureDelayMinutes: departureDelayMinutes ?? this.departureDelayMinutes,
      arrivalDelayMinutes: arrivalDelayMinutes ?? this.arrivalDelayMinutes,
      isCancelled: isCancelled ?? this.isCancelled,
      isDiverted: isDiverted ?? this.isDiverted,
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      aircraftType: aircraftType ?? this.aircraftType,
      onTimePercentage: onTimePercentage ?? this.onTimePercentage,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      delayHistory: delayHistory ?? this.delayHistory,
      isFavorite: isFavorite ?? this.isFavorite,
      terminal: terminal ?? this.terminal,
      gate: gate ?? this.gate,
      distance: distance ?? this.distance,
      flightDuration: flightDuration ?? this.flightDuration,
      flightServices: flightServices ?? this.flightServices,
    );
  }

  @override
  List<Object?> get props => [
        flightNumber,
        airline,
        departureAirport,
        arrivalAirport,
        scheduledDeparture,
        scheduledArrival,
        status,
        isCancelled,
        isDiverted,
        isFavorite,
      ];
}

class FlightRoute {
  final String departureAirport;
  final String arrivalAirport;
  final String airline;
  final String flightNumber;
  final double? reliability;

  FlightRoute({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.airline,
    required this.flightNumber,
    this.reliability,
  });

  factory FlightRoute.fromApi(Map<String, dynamic> json) {
    return FlightRoute(
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      airline: json['airline'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      reliability: json['reliability']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'airline': airline,
      'flightNumber': flightNumber,
      'reliability': reliability,
    };
  }

  factory FlightRoute.fromJson(Map<String, dynamic> json) {
    return FlightRoute(
      departureAirport: json['departureAirport'],
      arrivalAirport: json['arrivalAirport'],
      airline: json['airline'],
      flightNumber: json['flightNumber'],
      reliability: json['reliability'],
    );
  }
}

class FlightDelay {
  final DateTime date;
  final int departureDelay;
  final int arrivalDelay;
  final String reason;

  FlightDelay({
    required this.date,
    required this.departureDelay,
    required this.arrivalDelay,
    required this.reason,
  });

  factory FlightDelay.fromApi(Map<String, dynamic> json) {
    return FlightDelay(
      date: DateTime.parse(json['date']),
      departureDelay: json['departure_delay'] ?? 0,
      arrivalDelay: json['arrival_delay'] ?? 0,
      reason: json['reason'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'departureDelay': departureDelay,
      'arrivalDelay': arrivalDelay,
      'reason': reason,
    };
  }

  factory FlightDelay.fromJson(Map<String, dynamic> json) {
    return FlightDelay(
      date: DateTime.parse(json['date']),
      departureDelay: json['departureDelay'],
      arrivalDelay: json['arrivalDelay'],
      reason: json['reason'],
    );
  }
}
