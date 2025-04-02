import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flight_tracker/app/data/models/ticket_model.dart';
import 'package:get/get.dart';

import '../data/models/flight_model.dart';
import '../data/repositories/flight_repository.dart';
import '../data/repositories/user_repository.dart';
import '../utils/helpers.dart';
import 'auth_controller.dart';

class FlightController extends GetxController {
  final FlightRepository _flightRepository = FlightRepository();
  final UserRepository _userRepository = UserRepository();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<Ticket> selectedTicket = <Ticket>[].obs;
  final RxBool _isLoading = false.obs;
  final RxList<Flight> _flights = <Flight>[].obs;
  final RxList<Flight> _savedFlights = <Flight>[].obs;
  final Rx<Flight?> _selectedFlight = Rx<Flight?>(null);
  final RxList<String> _recentSearches = <String>[].obs;
  final RxBool _isConnected = true.obs;

  bool get isLoading => _isLoading.value;
  List<Flight> get flights => _flights.toList();
  List<Flight> get savedFlights => _savedFlights.toList();
  Flight? get selectedFlight => _selectedFlight.value;
  List<String> get recentSearches => _recentSearches.toList();
  bool get isConnected => _isConnected.value;
  List<Ticket> get tickets => selectedTicket.toList();

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _monitorConnectivity();
    loadSavedFlights();
    Future.delayed(Duration.zero, () {
      loadRecentSearches();
    });
  }

  // Check initial connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isConnected.value = connectivityResult != ConnectivityResult.none;
  }

  // Monitor connectivity changes
  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      Future.delayed(Duration.zero, () {
        _isConnected.value = result != ConnectivityResult.none;
      });

      if (_isConnected.value && _selectedFlight.value != null) {
        refreshFlightInfo(_selectedFlight.value!.flightNumber);
      }
    });
  }

  // Get flight by flight number
  Future<void> getFlightByNumber(String flightNumber) async {
    if (flightNumber.isEmpty) return;

    _isLoading.value = true;

    try {
      final flight = await _flightRepository.getFlightByNumber(flightNumber);

      if (flight != null) {
        // Check if this flight is favorited
        final isFavorite = _flightRepository.isFlightFavorite(flightNumber);
        _selectedFlight.value = flight.copyWith(isFavorite: isFavorite);

        // Save this search to recent searches
        if (_authController.isAuthenticated) {
          await _userRepository.saveRecentSearch(
            _authController.user!.id,
            flightNumber,
          );
          loadRecentSearches();
        }
      } else {
        showErrorSnackBar(message: 'Flight not found');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Search flights by airports
  Future<void> searchFlights({
    required String departureAirport,
    required String arrivalAirport,
    String? date,
  }) async {
    if (departureAirport.isEmpty || arrivalAirport.isEmpty) return;

    _isLoading.value = true;

    try {
      final result = await _flightRepository.searchFlights(
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        date: date,
      );

      _flights.value = result;

      // Save this search to recent searches
      if (_authController.isAuthenticated) {
        final searchQuery = '$departureAirport to $arrivalAirport';
        await _userRepository.saveRecentSearch(
          _authController.user!.id,
          searchQuery,
        );
        loadRecentSearches();
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Set selected flight
  void setSelectedFlight(Flight flight) {
    _selectedFlight.value = flight;
  }

  // Refresh current flight info
  Future<void> refreshFlightInfo(String flightNumber) async {
    if (flightNumber.isEmpty) return;

    _isLoading.value = true;

    try {
      final flight = await _flightRepository.getFlightByNumber(flightNumber);

      if (flight != null) {
        // Preserve the favorite status from the previous flight
        final isFavorite = _selectedFlight.value?.isFavorite ?? _flightRepository.isFlightFavorite(flightNumber);
        _selectedFlight.value = flight.copyWith(isFavorite: isFavorite);
      }
    } catch (e) {
      print('Error refreshing flight info: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Save/unsave a flight to favorites
  Future<void> toggleFavoriteFlight(Flight flight) async {
    try {
      final isFavorite = _flightRepository.isFlightFavorite(flight.flightNumber);

      if (isFavorite) {
        // Remove from favorites
        await _flightRepository.removeFavoriteFlight(flight.flightNumber);

        // If user is authenticated, also remove from cloud
        if (_authController.isAuthenticated) {
          await _userRepository.removeSavedFlight(
            _authController.user!.id,
            flight.flightNumber,
          );
        }

        showSuccessSnackBar(message: 'Flight removed from favorites');
      } else {
        // Add to favorites
        await _flightRepository.saveFavoriteFlight(flight);

        // If user is authenticated, also save to cloud
        if (_authController.isAuthenticated) {
          await _userRepository.saveFlight(_authController.user!.id, flight);
        }

        showSuccessSnackBar(message: 'Flight saved to favorites');
      }

      // Update the selected flight if it's the same one
      if (_selectedFlight.value?.flightNumber == flight.flightNumber) {
        _selectedFlight.value = _selectedFlight.value?.copyWith(
          isFavorite: !isFavorite,
        );
      }

      // Refresh saved flights list
      loadSavedFlights();
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    }
  }

  // Load saved flights
  Future<void> loadSavedFlights() async {
    try {
      // Get local saved flights
      List<Flight> flights = _flightRepository.getFavoriteFlights();

      // If user is authenticated, merge with cloud saved flights
      if (_authController.isAuthenticated) {
        final cloudFlights = await _userRepository.getSavedFlights(
          _authController.user!.id,
        );

        // Merge both lists, avoiding duplicates
        for (final cloudFlight in cloudFlights) {
          if (!flights.any((f) => f.flightNumber == cloudFlight.flightNumber)) {
            flights.add(cloudFlight);
          }
        }
      }

      _savedFlights.value = flights;
    } catch (e) {
      print('Error loading saved flights: $e');
    }
  }

  // Load recent searches
  Future<void> loadRecentSearches() async {
    if (!_authController.isAuthenticated) return;

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        _recentSearches.value = user.recentSearches;
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    if (!_authController.isAuthenticated) return;

    try {
      await _userRepository.clearRecentSearches(_authController.user!.id);
      _recentSearches.clear();
      showSuccessSnackBar(message: 'Recent searches cleared');
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    }
  }

  // Clear flight cache
  Future<void> clearFlightCache() async {
    try {
      await _flightRepository.clearFlightCache();
      showSuccessSnackBar(message: 'Cache cleared successfully');
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    }
  }

  // Get airport information
  Future<Map<String, dynamic>?> getAirportInfo(String airportCode) async {
    try {
      return await _flightRepository.getAirportInfo(airportCode);
    } catch (e) {
      print('Error getting airport info: $e');
      return null;
    }
  }

  // Get airline information
  Future<Map<String, dynamic>?> getAirlineInfo(String airlineCode) async {
    try {
      return await _flightRepository.getAirlineInfo(airlineCode);
    } catch (e) {
      print('Error getting airline info: $e');
      return null;
    }
  }

  // Check if a flight is favorited
  // bool isFlightFavorite(String flightNumber) {
  //   return _flightRepository.isFlightFavorite(flightNumber);
  // }
  //   // Get on-time rating based on flight history and current conditions
  // double getOnTimeRating() {
  //   try {
  //     if (_selectedFlight.value == null) return 0.0;

  //     // Calculate base rating from flight status
  //     double baseRating = _selectedFlight.value!.isCancelled ? 0.0 :
  //                        _selectedFlight.value!.isDelayed() ? 60.0 : 90.0;

  //     // Adjust based on weather conditions
  //     if (_selectedFlight.value!.departureWeather?.condition.toLowerCase().contains('storm') ?? false) {
  //       baseRating *= 0.8;
  //     }

  //     return baseRating;
  //   } catch (e) {
  //     print('Error calculating on-time rating: $e');
  //     return 0.0;
  //   }
  // }

  // // Get delay prediction status
  // String getDelayPrediction() {
  //   try {
  //     if (_selectedFlight.value == null) return 'Unknown';

  //     // Check weather conditions
  //     bool hasBadWeather = _selectedFlight.value!.departureWeather?.condition.toLowerCase().contains('storm') ?? false ||
  //                         _selectedFlight.value!.arrivalWeather?.condition.toLowerCase().contains('storm') ?? false;

  //     // Check current delay status
  //     if (_selectedFlight.value!.isDelayed()) {
  //       return _selectedFlight.value!.delayMinutes! > 60 ? 'High' : 'Medium';
  //     }

  //     // Predict based on conditions
  //     if (hasBadWeather) {
  //       return 'Medium';
  //     }

  //     return 'Low';
  //   } catch (e) {
  //     print('Error calculating delay prediction: $e');
  //     return 'Unknown';
  //   }
  // }

  Future<void> getFlightByTicket(String ticketNumber) async {
    if (ticketNumber.isEmpty) return;

    _isLoading.value = true;

    try {
      // Step 1: Get ticket details
      final ticket = await _flightRepository.getTicketDetails(ticketNumber);

      if (ticket != null) {
        selectedTicket.add(ticket);

        // Step 2: Also get the flight details
        final flight = await _flightRepository.getFlightByNumber(ticket.flightNumber);

        if (flight != null) {
          // Check if this flight is favorited
          final isFavorite = _flightRepository.isFlightFavorite(flight.flightNumber);
          _selectedFlight.value = flight.copyWith(isFavorite: isFavorite);

          // Save this search to recent searches
          if (_authController.isAuthenticated) {
            await _userRepository.saveRecentSearch(
              _authController.user!.id,
              "Ticket: $ticketNumber",
            );
            loadRecentSearches();
          }

          showSuccessSnackBar(message: 'Ticket found');
        } else {
          showWarningSnackBar(message: 'Ticket found but flight details unavailable');
        }
      } else {
        showErrorSnackBar(message: 'Ticket not found');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear selected ticket
  void clearSelectedTicket() {
    selectedTicket.clear();
  }
}
