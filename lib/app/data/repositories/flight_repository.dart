import 'dart:convert';
import 'package:flight_tracker/app/data/models/ticket_model.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/api_provider.dart';
import '../models/flight_model.dart';
import '../../utils/constants.dart';

class FlightRepository {
  final FlightApiProvider _apiProvider = FlightApiProvider();
  final Box _flightBox = Hive.box(Constants.flightBox);
  
  // Get flight by flight number
  Future<Flight?> getFlightByNumber(String flightNumber) async {
    try {
      // Try to get from API first
      final flight = await _apiProvider.getFlightByNumber(flightNumber);
      
      if (flight != null) {
        // Cache the result
        await _saveCachedFlight(flightNumber, flight);
        return flight;
      }
      
      // If API call fails, try to get from cache
      return _getCachedFlight(flightNumber);
    } catch (e) {
      print('Error getting flight: $e');
      // If there's an error, try to get from cache
      return _getCachedFlight(flightNumber);
    }
  }
  
  // Search flights by airports
  Future<List<Flight>> searchFlights({
    required String departureAirport,
    required String arrivalAirport,
    String? date,
  }) async {
    try {
      final flights = await _apiProvider.searchFlights(
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        date: date,
      );
      
      // Cache the search results
      final cacheKey = 'search_${departureAirport}_${arrivalAirport}_${date ?? ""}';
      await _flightBox.put(cacheKey, jsonEncode(flights.map((f) => f.toJson()).toList()));
      
      return flights;
    } catch (e) {
      print('Error searching flights: $e');
      
      // Try to get from cache if online search fails
      final cacheKey = 'search_${departureAirport}_${arrivalAirport}_${date ?? ""}';
      final cachedData = _flightBox.get(cacheKey);
      
      if (cachedData != null) {
        final flightsJson = jsonDecode(cachedData);
        return (flightsJson as List).map((json) => Flight.fromJson(json)).toList();
      }
      
      return [];
    }
  }
  
  // Get airport information
  Future<Map<String, dynamic>?> getAirportInfo(String airportCode) async {
    try {
      final airportInfo = await _apiProvider.getAirportInfo(airportCode);
      
      if (airportInfo != null) {
        // Cache the airport info
        await _flightBox.put('airport_$airportCode', jsonEncode(airportInfo));
      }
      
      return airportInfo;
    } catch (e) {
      print('Error getting airport info: $e');
      
      // Try to get from cache
      final cachedData = _flightBox.get('airport_$airportCode');
      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      
      return null;
    }
  }
  
  // Get airline information
  Future<Map<String, dynamic>?> getAirlineInfo(String airlineCode) async {
    try {
      final airlineInfo = await _apiProvider.getAirlineInfo(airlineCode);
      
      if (airlineInfo != null) {
        // Cache the airline info
        await _flightBox.put('airline_$airlineCode', jsonEncode(airlineInfo));
      }
      
      return airlineInfo;
    } catch (e) {
      print('Error getting airline info: $e');
      
      // Try to get from cache
      final cachedData = _flightBox.get('airline_$airlineCode');
      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      
      return null;
    }
  }
  Future<Ticket?> getTicketDetails(String ticketNumber) async {
  try {
    // Implement your API call here
    // For now, let's return a dummy ticket for testing
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // In a real app, you'd make an API call here
    // final response = await _apiService.get('/tickets/$ticketNumber');
    // return Ticket.fromJson(response.data);
    
    // For testing only - remove in production
    if (ticketNumber.startsWith('TKT')) {
      return Ticket(
        ticketNumber: ticketNumber,
        flightNumber: 'AA123',
        passengerName: 'John Doe',
        seatNumber: '12A',
        travelClass: 'Economy',
        isCheckedIn: false,
        bookingReference: 'ABC123',
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
  
  // Save a flight to local cache
  Future<void> _saveCachedFlight(String flightNumber, Flight flight) async {
    await _flightBox.put('flight_$flightNumber', jsonEncode(flight.toJson()));
    
    // Also store the timestamp when this flight was cached
    await _flightBox.put('flight_${flightNumber}_timestamp', DateTime.now().toIso8601String());
  }
  
  // Get a flight from local cache
  Flight? _getCachedFlight(String flightNumber) {
    final cachedData = _flightBox.get('flight_$flightNumber');
    
    if (cachedData != null) {
      return Flight.fromJson(jsonDecode(cachedData));
    }
    
    return null;
  }
  
  // Check if a cached flight is still valid (not too old)
  bool isCachedFlightValid(String flightNumber) {
    final timestampStr = _flightBox.get('flight_${flightNumber}_timestamp');
    
    if (timestampStr != null) {
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      
      // Cache is valid for 30 minutes
      return now.difference(timestamp).inMinutes < 30;
    }
    
    return false;
  }
  
  // Clear flight cache
  Future<void> clearFlightCache() async {
    final keys = _flightBox.keys.where((key) => 
      key.toString().startsWith('flight_') ||
      key.toString().startsWith('search_') ||
      key.toString().startsWith('airport_') ||
      key.toString().startsWith('airline_')
    );
    
    for (final key in keys) {
      await _flightBox.delete(key);
    }
  }
  
  // Save a flight locally as favorite
  Future<void> saveFavoriteFlight(Flight flight) async {
    final favoriteFlights = getFavoriteFlights();
    
    // Check if the flight is already saved
    if (!favoriteFlights.any((f) => f.flightNumber == flight.flightNumber)) {
      favoriteFlights.add(flight.copyWith(isFavorite: true));
      
      // Save the updated list
      await _flightBox.put(
        'favorite_flights',
        jsonEncode(favoriteFlights.map((f) => f.toJson()).toList()),
      );
    }
  }
  
  // Remove a flight from favorites
  Future<void> removeFavoriteFlight(String flightNumber) async {
    final favoriteFlights = getFavoriteFlights();
    
    favoriteFlights.removeWhere((f) => f.flightNumber == flightNumber);
    
    // Save the updated list
    await _flightBox.put(
      'favorite_flights',
      jsonEncode(favoriteFlights.map((f) => f.toJson()).toList()),
    );
  }
  
  // Get all favorite flights
  List<Flight> getFavoriteFlights() {
    final cachedData = _flightBox.get('favorite_flights');
    
    if (cachedData != null) {
      final flightsJson = jsonDecode(cachedData);
      return (flightsJson as List).map((json) => Flight.fromJson(json)).toList();
    }
    
    return [];
  }
  
  // Check if a flight is a favorite
  bool isFlightFavorite(String flightNumber) {
    final favoriteFlights = getFavoriteFlights();
    return favoriteFlights.any((f) => f.flightNumber == flightNumber);
  }
}
