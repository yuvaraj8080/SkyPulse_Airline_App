import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flight_tracker/app/data/models/ticket_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/models/flight_model.dart';
import '../data/repositories/flight_repository.dart';
import '../data/repositories/user_repository.dart';
import '../utils/helpers.dart';
import 'auth_controller.dart';

class FlightController extends GetxController {
  final FlightRepository _flightRepository;
  final UserRepository _userRepository;
  final AuthController _authController;

  final RxList<Ticket> selectedTicket = <Ticket>[].obs;
  final RxBool _isLoading = false.obs;
  final RxList<Flight> _flights = <Flight>[].obs;
  final RxList<Flight> _savedFlights = <Flight>[].obs;
  final Rx<Flight?> _selectedFlight = Rx<Flight?>(null);
  final RxList<String> _recentSearches = <String>[].obs;
  final RxBool _isConnected = true.obs;
  final RxString _lastUpdated = RxString('');
  final RxInt _refreshInterval = 60.obs;
  Timer? _refreshTimer;

  FlightController({
    required FlightRepository flightRepository,
    required UserRepository userRepository,
    required AuthController authController,
  })  : _flightRepository = flightRepository,
        _userRepository = userRepository,
        _authController = authController;

  bool get isLoading => _isLoading.value;
  List<Flight> get flights => _flights.toList();
  List<Flight> get savedFlights => _savedFlights.toList();
  Flight? get selectedFlight => _selectedFlight.value;
  List<String> get recentSearches => _recentSearches.toList();
  bool get isConnected => _isConnected.value;
  List<Ticket> get tickets => selectedTicket.toList();
  String get lastUpdated => _lastUpdated.value;

  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _monitorConnectivity();
    loadSavedFlights();
    loadRecentSearches();
    _startRefreshTimer();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval.value),
      (timer) {
        if (_selectedFlight.value != null && _isConnected.value) {
          refreshFlightInfo(_selectedFlight.value!.flightNumber);
          _lastUpdated.value = 'Last updated: ${DateFormat('h:mm a').format(DateTime.now())}';
        }
      },
    );
  }

  void setRefreshInterval(int seconds) {
    _refreshInterval.value = seconds;
    _startRefreshTimer();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isConnected.value = connectivityResult != ConnectivityResult.none;
  }

  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        _isConnected.value = results.first != ConnectivityResult.none;
        if (_isConnected.value && _selectedFlight.value != null) {
          refreshFlightInfo(_selectedFlight.value!.flightNumber);
        }
      }
    });
  }

  String getDelayStatus() {
    if (_selectedFlight.value == null) return 'Unknown';
    return _selectedFlight.value!.getDelayStatusText();
  }

  double getOnTimePercentage() {
    if (_selectedFlight.value == null) return 0.0;
    return _selectedFlight.value!.onTimePercentage ?? 0.0;
  }

  Future<void> getFlightByNumber(String flightNumber) async {
    if (flightNumber.isEmpty) return;

    _isLoading.value = true;
    try {
      final flight = await _flightRepository.getFlightByNumber(flightNumber);
      if (flight != null) {
        final isFavorite = _flightRepository.isFlightFavorite(flightNumber);

        // Get flight history to calculate additional metrics
        final history = await _flightRepository.getFlightHistory(flightNumber);
        final onTimePercentage = _flightRepository.calculateOnTimePercentage(history);

        // Get alternative routes and delay history
        final alternativeRoutes = await _flightRepository.getAlternativeRoutes(flightNumber);
        final delayHistory = await _flightRepository.generateDelayHistory(flightNumber);

        _selectedFlight.value = flight.copyWith(
          isFavorite: isFavorite,
          onTimePercentage: onTimePercentage,
          alternativeRoutes: alternativeRoutes,
          delayHistory: delayHistory,
        );

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

  void setSelectedFlight(Flight flight) {
    _selectedFlight.value = flight;
  }

  Future<void> refreshFlightInfo(String flightNumber) async {
    if (flightNumber.isEmpty) return;

    _isLoading.value = true;
    try {
      final flight = await _flightRepository.getFlightByNumber(flightNumber);
      if (flight != null) {
        final isFavorite = _flightRepository.isFlightFavorite(flightNumber);

        // Get flight history to calculate additional metrics
        final history = await _flightRepository.getFlightHistory(flightNumber);
        final onTimePercentage = _flightRepository.calculateOnTimePercentage(history);

        // Get alternative routes and delay history
        final alternativeRoutes = await _flightRepository.getAlternativeRoutes(flightNumber);
        final delayHistory = await _flightRepository.generateDelayHistory(flightNumber);

        _selectedFlight.value = flight.copyWith(
          isFavorite: isFavorite,
          onTimePercentage: onTimePercentage,
          alternativeRoutes: alternativeRoutes,
          delayHistory: delayHistory,
        );
      }
    } catch (e) {
      print('Error refreshing flight info: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleFavoriteFlight(Flight flight) async {
    try {
      final isFavorite = _flightRepository.isFlightFavorite(flight.flightNumber);

      if (isFavorite) {
        await _flightRepository.removeFavoriteFlight(flight.flightNumber);
        if (_authController.isAuthenticated) {
          await _userRepository.removeSavedFlight(
            _authController.user!.id,
            flight.flightNumber,
          );
        }
        showSuccessSnackBar(message: 'Flight removed from favorites');
      } else {
        await _flightRepository.saveFavoriteFlight(flight);
        if (_authController.isAuthenticated) {
          await _userRepository.saveFlight(_authController.user!.id, flight);
        }
        showSuccessSnackBar(message: 'Flight saved to favorites');
      }

      if (_selectedFlight.value?.flightNumber == flight.flightNumber) {
        _selectedFlight.value = _selectedFlight.value?.copyWith(
          isFavorite: !isFavorite,
        );
      }

      loadSavedFlights();
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    }
  }

  Future<void> loadSavedFlights() async {
    _isLoading.value = true;
    try {
      // First get local favorites
      List<Flight> flights = _flightRepository.getFavoriteFlights();

      // Then get cloud favorites if user is authenticated
      if (_authController.isAuthenticated) {
        try {
          final cloudFlights = await _userRepository.getSavedFlights(
            _authController.user!.id,
          );

          // For each cloud flight
          for (final cloudFlight in cloudFlights) {
            // Check if we already have this flight locally
            final existingIndex = flights.indexWhere((f) => f.flightNumber == cloudFlight.flightNumber);

            if (existingIndex >= 0) {
              // Replace with updated cloud version
              flights[existingIndex] = cloudFlight;
            } else {
              // Add new flight from cloud
              flights.add(cloudFlight);
            }
          }
        } catch (e) {
          print('Error loading cloud saved flights: $e');
          // Continue with local flights if cloud fails
        }
      }

      // Set favorite flag for all flights explicitly
      final markedFavorites = flights.map((f) => f.copyWith(isFavorite: true)).toList();

      _savedFlights.value = markedFavorites;
      print('Loaded ${_savedFlights.length} saved flights');

      // Cache flights for offline use
      if (markedFavorites.isNotEmpty) {
        await _flightRepository.saveFavoriteFlight(markedFavorites.first);
      }
    } catch (e) {
      print('Error loading saved flights: $e');
    } finally {
      _isLoading.value = false;
    }
  }

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

  Future<void> clearFlightCache() async {
    try {
      await _flightRepository.clearFlightCache();
      showSuccessSnackBar(message: 'Cache cleared successfully');
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getAirportInfo(String airportCode) async {
    try {
      return await _flightRepository.getAirportInfo(airportCode);
    } catch (e) {
      print('Error getting airport info: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAirlineInfo(String airlineCode) async {
    try {
      return await _flightRepository.getAirlineInfo(airlineCode);
    } catch (e) {
      print('Error getting airline info: $e');
      return null;
    }
  }

  Future<List<Flight>> getFlightHistory(String flightNumber, {int days = 7}) async {
    try {
      return await _flightRepository.getFlightHistory(flightNumber, days: days);
    } catch (e) {
      print('Error getting flight history: $e');
      return [];
    }
  }

  Future<List<FlightRoute>> getAlternativeRoutes(String flightNumber) async {
    try {
      return await _flightRepository.getAlternativeRoutes(flightNumber);
    } catch (e) {
      print('Error getting alternative routes: $e');
      return [];
    }
  }

  Future<List<FlightDelay>> getDelayHistory(String flightNumber, {int days = 30}) async {
    try {
      return await _flightRepository.generateDelayHistory(flightNumber, days: days);
    } catch (e) {
      print('Error getting delay history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAircraftInfo(String registrationNumber) async {
    try {
      return await _flightRepository.getAircraftInfo(registrationNumber);
    } catch (e) {
      print('Error getting aircraft info: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFlightStatus(String flightNumber, String date) async {
    try {
      return await _flightRepository.getFlightStatus(flightNumber, date);
    } catch (e) {
      print('Error getting flight status: $e');
      return null;
    }
  }

  Future<Map<String, List<Flight>>> getAirportSchedule(String airportCode, String date) async {
    try {
      return await _flightRepository.getAirportSchedule(airportCode, date);
    } catch (e) {
      print('Error getting airport schedule: $e');
      return {'arrivals': [], 'departures': []};
    }
  }

  Future<void> getFlightByTicket(String ticketNumber) async {
    if (ticketNumber.isEmpty) return;
    _isLoading.value = true;
    try {
      final ticket = await _flightRepository.getTicketDetails(ticketNumber);
      if (ticket != null) {
        selectedTicket.add(ticket);
        final flight = await _flightRepository.getFlightByNumber(ticket.flightNumber);
        if (flight != null) {
          final isFavorite = _flightRepository.isFlightFavorite(flight.flightNumber);
          _selectedFlight.value = flight.copyWith(isFavorite: isFavorite);
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

  void clearSelectedTicket() {
    selectedTicket.clear();
  }
}
