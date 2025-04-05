import 'dart:convert';
import 'dart:math';

import 'package:flight_tracker/app/data/models/ticket_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/flight_model.dart';
import '../providers/api_provider.dart';

class FlightRepository {
  final FlightApiProvider _apiProvider;
  final Box _flightBox;

  FlightRepository({
    required FlightApiProvider apiProvider,
    required Box flightBox,
  })  : _apiProvider = apiProvider,
        _flightBox = flightBox;

  // Get flight by flight number with enhanced data
  Future<Flight?> getFlightByNumber(String flightNumber) async {
    try {
      // Check cache first if we have a valid recent flight
      if (isCachedFlightValid(flightNumber)) {
        print('Using cached flight data for $flightNumber');
        final cachedFlight = _getCachedFlight(flightNumber);
        if (cachedFlight != null) {
          return cachedFlight;
        }
      }

      // Try to get from API
      print('Fetching flight data from API for $flightNumber');
      final flight = await _apiProvider.getFlightByNumber(flightNumber);

      if (flight != null) {
        // Enhanced flight object with estimated data
        final enhancedFlight = flight.copyWith(
          onTimePercentage: _calculateEstimatedOnTimePercentage(flight),
          alternativeRoutes: [],
          delayHistory: [],
        );

        // Cache the result
        await _saveCachedFlight(flightNumber, enhancedFlight);
        return enhancedFlight;
      }

      // If API call fails, try to get from cache even if expired
      print('API call failed, trying expired cache for $flightNumber');
      return _getCachedFlight(flightNumber);
    } catch (e) {
      print('Error getting flight: $e');
      return _getCachedFlight(flightNumber);
    }
  }

  // Calculate estimated on-time percentage based on flight data
  double _calculateEstimatedOnTimePercentage(Flight flight) {
    // Use historical data if available or a basic estimate
    if (flight.isDelayed()) {
      return 75.0; // Slightly lower percentage for currently delayed flights
    } else if (flight.isCancelled || flight.isDiverted) {
      return 65.0; // Even lower for problematic flights
    }
    return 85.0; // Default percentage for on-time flights
  }

  // Search flights with enhanced caching
  Future<List<Flight>> searchFlights({
    String? departureAirport,
    String? arrivalAirport,
    String? date,
  }) async {
    final cacheKey = 'search_${departureAirport ?? ""}_${arrivalAirport ?? ""}_${date ?? ""}';

    try {
      // Check if we have cached results that are not too old (30 minutes)
      final cachedTimestampStr = _flightBox.get('${cacheKey}_timestamp');
      if (cachedTimestampStr != null) {
        final cachedTimestamp = DateTime.parse(cachedTimestampStr);
        if (DateTime.now().difference(cachedTimestamp).inMinutes < 30) {
          final cachedData = _flightBox.get(cacheKey);
          if (cachedData != null) {
            print('Using cached flight search results');
            final List<dynamic> jsonList = jsonDecode(cachedData);
            final flights = jsonList
                .map((json) => Flight(
                      flightNumber: json['flightNumber'] ?? '',
                      airline: json['airline'] ?? '',
                      airlineName: json['airlineName'] ?? '',
                      departureAirport: json['departureAirport'] ?? '',
                      arrivalAirport: json['arrivalAirport'] ?? '',
                      departureCity: json['departureCity'] ?? '',
                      arrivalCity: json['arrivalCity'] ?? '',
                      scheduledDeparture:
                          json['scheduledDeparture'] != null ? DateTime.parse(json['scheduledDeparture']) : null,
                      scheduledArrival:
                          json['scheduledArrival'] != null ? DateTime.parse(json['scheduledArrival']) : null,
                      actualDeparture: json['actualDeparture'] != null ? DateTime.parse(json['actualDeparture']) : null,
                      actualArrival: json['actualArrival'] != null ? DateTime.parse(json['actualArrival']) : null,
                      status: json['status'] ?? 'Unknown',
                      departureDelayMinutes: json['departureDelayMinutes'] ?? 0,
                      arrivalDelayMinutes: json['arrivalDelayMinutes'] ?? 0,
                      isCancelled: json['isCancelled'] ?? false,
                      isDiverted: json['isDiverted'] ?? false,
                      aircraftRegistration: json['aircraftRegistration'] ?? '',
                      aircraftType: json['aircraftType'] ?? '',
                      onTimePercentage: json['onTimePercentage']?.toDouble(),
                      alternativeRoutes: _parseAlternativeRoutes(json['alternativeRoutes']),
                      delayHistory: _parseDelayHistory(json['delayHistory']),
                      isFavorite: json['isFavorite'] ?? false,
                      terminal: json['terminal'],
                      gate: json['gate'],
                      distance: json['distance']?.toDouble(),
                      flightDuration: json['flightDuration'],
                      flightServices: json['flightServices'] != null ? List<String>.from(json['flightServices']) : null,
                    ))
                .toList();
            return flights;
          }
        }
      }

      // Fetch from API if no valid cache
      print('Fetching flight search results from API');
      final flights = await _apiProvider.searchFlights(
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        date: date,
      );

      // Enhance flights with additional information
      final enhancedFlights = flights
          .map((flight) => flight.copyWith(
                onTimePercentage: _calculateEstimatedOnTimePercentage(flight),
                alternativeRoutes: [],
                delayHistory: [],
              ))
          .toList();

      // Cache the results
      await _flightBox.put(cacheKey, jsonEncode(enhancedFlights.map((f) => f.toJson()).toList()));
      await _flightBox.put('${cacheKey}_timestamp', DateTime.now().toIso8601String());

      return enhancedFlights;
    } catch (e) {
      print('Error searching flights: $e');
      // Try to use expired cache as fallback
      final cachedData = _flightBox.get(cacheKey);
      if (cachedData != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedData);
          return jsonList
              .map((json) => Flight(
                    flightNumber: json['flightNumber'] ?? '',
                    airline: json['airline'] ?? '',
                    airlineName: json['airlineName'] ?? '',
                    departureAirport: json['departureAirport'] ?? '',
                    arrivalAirport: json['arrivalAirport'] ?? '',
                    departureCity: json['departureCity'] ?? '',
                    arrivalCity: json['arrivalCity'] ?? '',
                    scheduledDeparture:
                        json['scheduledDeparture'] != null ? DateTime.parse(json['scheduledDeparture']) : null,
                    scheduledArrival:
                        json['scheduledArrival'] != null ? DateTime.parse(json['scheduledArrival']) : null,
                    actualDeparture: json['actualDeparture'] != null ? DateTime.parse(json['actualDeparture']) : null,
                    actualArrival: json['actualArrival'] != null ? DateTime.parse(json['actualArrival']) : null,
                    status: json['status'] ?? 'Unknown',
                    departureDelayMinutes: json['departureDelayMinutes'] ?? 0,
                    arrivalDelayMinutes: json['arrivalDelayMinutes'] ?? 0,
                    isCancelled: json['isCancelled'] ?? false,
                    isDiverted: json['isDiverted'] ?? false,
                    aircraftRegistration: json['aircraftRegistration'] ?? '',
                    aircraftType: json['aircraftType'] ?? '',
                    onTimePercentage: json['onTimePercentage']?.toDouble(),
                    alternativeRoutes: _parseAlternativeRoutes(json['alternativeRoutes']),
                    delayHistory: _parseDelayHistory(json['delayHistory']),
                    isFavorite: json['isFavorite'] ?? false,
                    terminal: json['terminal'],
                    gate: json['gate'],
                    distance: json['distance']?.toDouble(),
                    flightDuration: json['flightDuration'],
                    flightServices: json['flightServices'] != null ? List<String>.from(json['flightServices']) : null,
                  ))
              .toList();
        } catch (e) {
          print('Error parsing cached search results: $e');
          return [];
        }
      }
      return [];
    }
  }

  // Get flight history with a mix of real data and mockups when needed
  Future<List<Flight>> getFlightHistory(String flightNumber, {int days = 7}) async {
    final cacheKey = 'history_$flightNumber';

    // First check if we have real cached data for this flight
    final List<Flight> realFlights = [];

    // Search through cached flight statuses for this flight number
    final keys = _flightBox.keys.where((key) =>
        key.toString().startsWith('status_$flightNumber') || key.toString().startsWith('flight_$flightNumber'));

    for (final key in keys) {
      try {
        final data = _flightBox.get(key);
        if (data != null) {
          final flight = Flight.fromAeroDataBoxApi(jsonDecode(data));
          if (flight.actualDeparture != null) {
            realFlights.add(flight);
          }
        }
      } catch (e) {
        // Skip invalid entries
        print('Error parsing cached flight: $e');
      }
    }

    // Sort real flights by departure time
    realFlights.sort((a, b) => (a.actualDeparture ?? DateTime.now()).compareTo(b.actualDeparture ?? DateTime.now()));

    // If we have enough real flights, use them
    if (realFlights.length >= days) {
      return realFlights.take(days).toList();
    }

    // Otherwise, supplement with mock data
    final currentFlight = await getFlightByNumber(flightNumber);
    final List<Flight> history = List.from(realFlights);

    if (currentFlight != null) {
      final mockNeeded = days - history.length;
      for (int i = 1; i <= mockNeeded; i++) {
        final pastDate = DateTime.now().subtract(Duration(days: i + history.length));

        // Generate status and delay
        final status = _generateRealisticStatus(i);
        final delayMinutes = _generateRealisticDelay(i);

        // Create historic flight entry
        final adjustedDeparture = _adjustTimeToMatchDayOfWeek(currentFlight.scheduledDeparture, pastDate);
        final adjustedArrival = _adjustTimeToMatchDayOfWeek(currentFlight.scheduledArrival, pastDate);

        history.add(currentFlight.copyWith(
          scheduledDeparture: adjustedDeparture,
          scheduledArrival: adjustedArrival,
          actualDeparture: status != 'Cancelled' ? adjustedDeparture?.add(Duration(minutes: delayMinutes)) : null,
          actualArrival: status != 'Cancelled' ? adjustedArrival?.add(Duration(minutes: delayMinutes - 5)) : null,
          status: status,
          departureDelayMinutes: delayMinutes,
          arrivalDelayMinutes: max(0, delayMinutes - 5), // Usually arrival makes up some time
          isCancelled: status == 'Cancelled',
        ));
      }
    }

    // Cache the combined result
    await _flightBox.put(cacheKey, jsonEncode(history.map((f) => f.toJson()).toList()));
    return history;
  }

  // Helper to adjust time while preserving day of week patterns
  DateTime? _adjustTimeToMatchDayOfWeek(DateTime? originalTime, DateTime targetDate) {
    if (originalTime == null) return null;

    // Keep the time but change the date
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      originalTime.hour,
      originalTime.minute,
    );
  }

  // Generate realistic status based on statistics
  String _generateRealisticStatus(int seed) {
    final rand = Random(seed);
    final roll = rand.nextDouble();

    // Based on industry averages: ~80% on-time, ~15% delayed, ~5% cancelled
    if (roll > 0.95) return 'Cancelled';
    if (roll > 0.80) return 'Delayed';
    return 'Landed';
  }

  // Generate realistic delay based on industry statistics
  int _generateRealisticDelay(int seed) {
    final rand = Random(seed);
    final isDelayed = _generateRealisticStatus(seed) == 'Delayed';

    if (!isDelayed) return 0;

    // Most delays are 15-45 minutes
    return 15 + rand.nextInt(30);
  }

  // Get airport information with extended data
  Future<Map<String, dynamic>?> getAirportInfo(String airportCode) async {
    try {
      final airportInfo = await _apiProvider.getAirportInfo(airportCode);
      if (airportInfo != null) {
        await _flightBox.put('airport_$airportCode', jsonEncode(airportInfo));
      }
      return airportInfo;
    } catch (e) {
      print('Error getting airport info: $e');
      final cachedData = _flightBox.get('airport_$airportCode');
      return cachedData != null ? jsonDecode(cachedData) : null;
    }
  }

  // Get airport flight schedules
  Future<Map<String, List<Flight>>> getAirportSchedule(String airportCode, String date) async {
    final cacheKey = 'schedule_${airportCode}_$date';
    try {
      final schedule = await _apiProvider.getAirportSchedule(airportCode, date);
      await _flightBox.put(
          cacheKey,
          jsonEncode({
            'arrivals': schedule['arrivals']?.map((f) => f.toJson()).toList() ?? [],
            'departures': schedule['departures']?.map((f) => f.toJson()).toList() ?? [],
          }));
      return schedule;
    } catch (e) {
      print('Error getting airport schedule: $e');
      final cachedData = _flightBox.get(cacheKey);
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        return {
          'arrivals': (data['arrivals'] as List).map((json) => Flight.fromAeroDataBoxApi(json)).toList(),
          'departures': (data['departures'] as List).map((json) => Flight.fromAeroDataBoxApi(json)).toList(),
        };
      }
      return {'arrivals': [], 'departures': []};
    }
  }

  // Get airline information with extended data
  Future<Map<String, dynamic>?> getAirlineInfo(String airlineCode) async {
    try {
      final airlineInfo = await _apiProvider.getAirlineInfo(airlineCode);
      if (airlineInfo != null) {
        await _flightBox.put('airline_$airlineCode', jsonEncode(airlineInfo));
      }
      return airlineInfo;
    } catch (e) {
      print('Error getting airline info: $e');
      final cachedData = _flightBox.get('airline_$airlineCode');
      return cachedData != null ? jsonDecode(cachedData) : null;
    }
  }

  // Get flight status and tracking
  Future<Map<String, dynamic>?> getFlightStatus(String flightNumber, String date) async {
    final cacheKey = 'status_${flightNumber}_$date';
    try {
      final status = await _apiProvider.getFlightStatus(flightNumber, date);
      if (status != null) {
        await _flightBox.put(cacheKey, jsonEncode(status));
      }
      return status;
    } catch (e) {
      print('Error getting flight status: $e');
      final cachedData = _flightBox.get(cacheKey);
      return cachedData != null ? jsonDecode(cachedData) : null;
    }
  }

  // Get aircraft information
  Future<Map<String, dynamic>?> getAircraftInfo(String registrationNumber) async {
    final cacheKey = 'aircraft_$registrationNumber';
    try {
      final aircraftInfo = await _apiProvider.getAircraftInfo(registrationNumber);
      if (aircraftInfo != null) {
        await _flightBox.put(cacheKey, jsonEncode(aircraftInfo));
      }
      return aircraftInfo;
    } catch (e) {
      print('Error getting aircraft info: $e');
      final cachedData = _flightBox.get(cacheKey);
      return cachedData != null ? jsonDecode(cachedData) : null;
    }
  }

  // Ticket details with mock implementation (replace with real API)
  Future<Ticket?> getTicketDetails(String ticketNumber) async {
    try {
      // In production, replace with actual API call:
      // return await _apiProvider.getTicketDetails(ticketNumber);

      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      if (ticketNumber.startsWith('TKT')) {
        return Ticket(
          ticketNumber: ticketNumber,
          flightNumber: 'AA${ticketNumber.substring(3, 6)}',
          passengerName: 'John Doe',
          seatNumber: '${ticketNumber.substring(3, 5)}A',
          travelClass: 'Economy',
          isCheckedIn: false,
          bookingReference: 'REF$ticketNumber',
          boardingGroup: 'B',
          issueDate: DateTime.now().subtract(const Duration(days: 5)),
          baggageAllowance: 23.0,
          hasPriorityBoarding: true,
          services: ['Meal', 'Extra Legroom'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting ticket details: $e');
      return null;
    }
  }

  // Calculate on-time percentage from history
  double calculateOnTimePercentage(List<Flight> history) {
    if (history.isEmpty) return 0.0;
    final onTimeCount = history.where((f) => f.isOnTime()).length;
    return (onTimeCount / history.length) * 100;
  }

  // Cache management methods
  Future<void> _saveCachedFlight(String flightNumber, Flight flight) async {
    await _flightBox.put('flight_$flightNumber', jsonEncode(flight.toJson()));
    await _flightBox.put('flight_${flightNumber}_timestamp', DateTime.now().toIso8601String());
  }

  Flight? _getCachedFlight(String flightNumber) {
    try {
      final cachedData = _flightBox.get('flight_$flightNumber');
      if (cachedData != null) {
        final jsonData = jsonDecode(cachedData);
        return Flight(
          flightNumber: jsonData['flightNumber'] ?? '',
          airline: jsonData['airline'] ?? '',
          airlineName: jsonData['airlineName'] ?? '',
          departureAirport: jsonData['departureAirport'] ?? '',
          arrivalAirport: jsonData['arrivalAirport'] ?? '',
          departureCity: jsonData['departureCity'] ?? '',
          arrivalCity: jsonData['arrivalCity'] ?? '',
          scheduledDeparture:
              jsonData['scheduledDeparture'] != null ? DateTime.parse(jsonData['scheduledDeparture']) : null,
          scheduledArrival: jsonData['scheduledArrival'] != null ? DateTime.parse(jsonData['scheduledArrival']) : null,
          actualDeparture: jsonData['actualDeparture'] != null ? DateTime.parse(jsonData['actualDeparture']) : null,
          actualArrival: jsonData['actualArrival'] != null ? DateTime.parse(jsonData['actualArrival']) : null,
          status: jsonData['status'] ?? 'Unknown',
          departureDelayMinutes: jsonData['departureDelayMinutes'] ?? 0,
          arrivalDelayMinutes: jsonData['arrivalDelayMinutes'] ?? 0,
          isCancelled: jsonData['isCancelled'] ?? false,
          isDiverted: jsonData['isDiverted'] ?? false,
          aircraftRegistration: jsonData['aircraftRegistration'] ?? '',
          aircraftType: jsonData['aircraftType'] ?? '',
          onTimePercentage: jsonData['onTimePercentage']?.toDouble(),
          alternativeRoutes: _parseAlternativeRoutes(jsonData['alternativeRoutes']),
          delayHistory: _parseDelayHistory(jsonData['delayHistory']),
          isFavorite: jsonData['isFavorite'] ?? false,
          terminal: jsonData['terminal'],
          gate: jsonData['gate'],
          distance: jsonData['distance']?.toDouble(),
          flightDuration: jsonData['flightDuration'],
          flightServices: jsonData['flightServices'] != null ? List<String>.from(jsonData['flightServices']) : null,
        );
      }
      return null;
    } catch (e) {
      print('Error parsing cached flight: $e');
      return null;
    }
  }

  // Helper methods to parse complex nested objects
  List<FlightRoute> _parseAlternativeRoutes(dynamic routes) {
    if (routes == null) return [];
    try {
      return (routes as List).map((routeJson) => FlightRoute.fromJson(routeJson)).toList();
    } catch (e) {
      print('Error parsing alternative routes: $e');
      return [];
    }
  }

  List<FlightDelay> _parseDelayHistory(dynamic delays) {
    if (delays == null) return [];
    try {
      return (delays as List).map((delayJson) => FlightDelay.fromJson(delayJson)).toList();
    } catch (e) {
      print('Error parsing delay history: $e');
      return [];
    }
  }

  bool isCachedFlightValid(String flightNumber) {
    final timestampStr = _flightBox.get('flight_${flightNumber}_timestamp');
    if (timestampStr != null) {
      return DateTime.now().difference(DateTime.parse(timestampStr)).inMinutes < 30;
    }
    return false;
  }

  Future<void> clearFlightCache() async {
    final keys = _flightBox.keys.where((key) =>
        key.toString().startsWith('flight_') ||
        key.toString().startsWith('search_') ||
        key.toString().startsWith('status_') ||
        key.toString().startsWith('schedule_') ||
        key.toString().startsWith('aircraft_') ||
        key.toString().startsWith('airport_') ||
        key.toString().startsWith('airline_'));

    for (final key in keys) {
      await _flightBox.delete(key);
    }
  }

  // Favorite flights management
  Future<void> saveFavoriteFlight(Flight flight) async {
    final favorites = getFavoriteFlights();
    if (!favorites.any((f) => f.flightNumber == flight.flightNumber)) {
      favorites.add(flight.copyWith(isFavorite: true));
      await _flightBox.put('favorite_flights', jsonEncode(favorites.map((f) => f.toJson()).toList()));
    }
  }

  Future<void> removeFavoriteFlight(String flightNumber) async {
    final favorites = getFavoriteFlights();
    favorites.removeWhere((f) => f.flightNumber == flightNumber);
    await _flightBox.put('favorite_flights', jsonEncode(favorites.map((f) => f.toJson()).toList()));
  }

  List<Flight> getFavoriteFlights() {
    try {
      final cachedData = _flightBox.get('favorite_flights');
      if (cachedData == null) return [];

      // Parse the JSON data
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final List<Flight> flights = [];

      // Safely parse each flight
      for (var json in jsonList) {
        try {
          // Use the Flight constructor directly instead of fromAeroDataBoxApi
          // to avoid parsing issues with the API format
          final flight = Flight(
            flightNumber: json['flightNumber'] ?? '',
            airline: json['airline'] ?? '',
            airlineName: json['airlineName'] ?? '',
            departureAirport: json['departureAirport'] ?? '',
            arrivalAirport: json['arrivalAirport'] ?? '',
            departureCity: json['departureCity'] ?? '',
            arrivalCity: json['arrivalCity'] ?? '',
            scheduledDeparture: json['scheduledDeparture'] != null ? DateTime.parse(json['scheduledDeparture']) : null,
            scheduledArrival: json['scheduledArrival'] != null ? DateTime.parse(json['scheduledArrival']) : null,
            actualDeparture: json['actualDeparture'] != null ? DateTime.parse(json['actualDeparture']) : null,
            actualArrival: json['actualArrival'] != null ? DateTime.parse(json['actualArrival']) : null,
            status: json['status'] ?? 'Unknown',
            departureDelayMinutes: json['departureDelayMinutes'] ?? 0,
            arrivalDelayMinutes: json['arrivalDelayMinutes'] ?? 0,
            isCancelled: json['isCancelled'] ?? false,
            isDiverted: json['isDiverted'] ?? false,
            aircraftRegistration: json['aircraftRegistration'] ?? '',
            aircraftType: json['aircraftType'] ?? '',
            onTimePercentage: json['onTimePercentage']?.toDouble(),
            alternativeRoutes: _parseAlternativeRoutes(json['alternativeRoutes']),
            delayHistory: _parseDelayHistory(json['delayHistory']),
            isFavorite: true, // Always true for favorites
            terminal: json['terminal'],
            gate: json['gate'],
            distance: json['distance']?.toDouble(),
            flightDuration: json['flightDuration'],
            flightServices: json['flightServices'] != null ? List<String>.from(json['flightServices']) : null,
          );
          flights.add(flight);
        } catch (e) {
          print('Error parsing individual flight in favorites: $e');
          // Continue with next flight if one fails
        }
      }

      return flights;
    } catch (e) {
      print('Error getting favorite flights: $e');
      return [];
    }
  }

  bool isFlightFavorite(String flightNumber) {
    return getFavoriteFlights().any((f) => f.flightNumber == flightNumber);
  }

  // Get alternative routes for a flight - mockup implementation
  Future<List<FlightRoute>> getAlternativeRoutes(String flightNumber) async {
    final cacheKey = 'routes_$flightNumber';
    try {
      // Get current flight to base mock data on
      final currentFlight = await getFlightByNumber(flightNumber);
      if (currentFlight == null || currentFlight.departureAirport.isEmpty || currentFlight.arrivalAirport.isEmpty) {
        return [];
      }

      // Extract numeric part safely
      String numericPart = currentFlight.flightNumber.replaceAll(RegExp(r'[^0-9]'), '');
      int flightNum = 0;
      try {
        flightNum = int.parse(numericPart);
      } catch (e) {
        print('Could not parse numeric part of flight number: $e');
        flightNum = Random().nextInt(900) + 100; // Fallback to random 3-digit number
      }

      // Generate alternative routes
      final List<FlightRoute> routes = [
        // Direct route with same airline
        FlightRoute(
          departureAirport: currentFlight.departureAirport,
          arrivalAirport: currentFlight.arrivalAirport,
          airline: currentFlight.airline,
          flightNumber: "${currentFlight.airline}${flightNum + 2}",
          reliability: 92.5,
        ),
        // Alternative with different airline
        FlightRoute(
          departureAirport: currentFlight.departureAirport,
          arrivalAirport: currentFlight.arrivalAirport,
          airline: _getRandomAlternativeAirline(currentFlight.airline),
          flightNumber: "${_getRandomAlternativeAirline(currentFlight.airline)}123",
          reliability: 88.3,
        ),
      ];

      await _flightBox.put(cacheKey, jsonEncode(routes.map((r) => r.toJson()).toList()));
      return routes;
    } catch (e) {
      print('Error getting alternative routes: $e');
      final cachedData = _flightBox.get(cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((json) => FlightRoute.fromJson(json)).toList();
      }
      return [];
    }
  }

  // Helper to get random alternative airline
  String _getRandomAlternativeAirline(String currentAirline) {
    final alternatives = ['AA', 'DL', 'UA', 'BA', 'LH', 'EK', 'SQ', 'QF'];
    final filtered = alternatives.where((a) => a != currentAirline).toList();
    return filtered[Random().nextInt(filtered.length)];
  }

  // Generate mock delay history for a flight
  Future<List<FlightDelay>> generateDelayHistory(String flightNumber, {int days = 30}) async {
    final cacheKey = 'delay_history_$flightNumber';
    try {
      final flightHistory = await getFlightHistory(flightNumber, days: days);
      final List<FlightDelay> delayHistory = [];

      // Extract delays from history
      for (var flight in flightHistory) {
        if (flight.isDelayed()) {
          delayHistory.add(FlightDelay(
            date: flight.scheduledDeparture ?? DateTime.now(),
            departureDelay: flight.departureDelayMinutes,
            arrivalDelay: flight.arrivalDelayMinutes,
            reason: _generateDelayReason(flight.departureDelayMinutes),
          ));
        }
      }

      await _flightBox.put(cacheKey, jsonEncode(delayHistory.map((d) => d.toJson()).toList()));
      return delayHistory;
    } catch (e) {
      print('Error generating delay history: $e');
      final cachedData = _flightBox.get(cacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        return jsonList.map((json) => FlightDelay.fromJson(json)).toList();
      }
      return [];
    }
  }

  // Generate realistic delay reason
  String _generateDelayReason(int delayMinutes) {
    final reasons = {
      'Weather': 0.35,
      'Air Traffic Control': 0.25,
      'Aircraft Maintenance': 0.15,
      'Crew Scheduling': 0.10,
      'Security': 0.08,
      'Late Aircraft Arrival': 0.07,
    };

    double roll = Random().nextDouble();
    double cumulative = 0.0;

    // Weighted selection based on common airline delay reasons
    for (var entry in reasons.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    return 'Operational Issues';
  }

  // Add retry capability for all API calls
  Future<T?> retryOperation<T>(Future<T?> Function() operation, {int maxRetries = 2}) async {
    for (var i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) return null;
        await Future.delayed(Duration(seconds: 1 * (i + 1)));
      }
    }
    return null;
  }
}
