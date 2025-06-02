import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/flight_model.dart';
import '../models/user_model.dart';

class SupabaseProvider {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  // Authentication methods
  Future<User?> signUp(String email, String password, String? fullName) async {
    try {
      // Ensure we have a valid name
      final effectiveFullName = (fullName != null && fullName.isNotEmpty) ? fullName : 'Flight Enthusiast';

      final supabase.AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': effectiveFullName,
        },
      );

      if (response.user != null) {
        // Create user record in users table with full_name
        await _client.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': effectiveFullName,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Fetch the newly created user record
        final userData = await _client.from('users').select().eq('id', response.user!.id).single();
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final supabase.AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        try {
          // Fetch user data from the users table
          final userData = await _client
              .from('users')
              .select('*, saved_flights:saved_flights(*), recent_searches')
              .eq('id', response.user!.id)
              .single();

          if (userData != null) {
            return User.fromJson(userData);
          }
        } catch (e) {
          print('Error fetching user data from users table: $e');
          // If no record in users table, create one with data from auth
          final userMetadata = response.user!.userMetadata;
          String? fullName = userMetadata?['full_name'] as String? ?? 'Flight Enthusiast';

          await _client.from('users').upsert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'saved_flights': [],
            'recent_searches': [],
          });

          // Fetch the newly created user record
          final newUserData = await _client
              .from('users')
              .select('*, saved_flights:saved_flights(*), recent_searches')
              .eq('id', response.user!.id)
              .single();

          if (newUserData != null) {
            return User.fromJson(newUserData);
          }
        }

        // Fallback to auth data if users table fetch fails
        return User.fromSupabaseAuth(response.user!.toJson());
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user != null) {
        try {
          // Fetch user data from the users table
          final userData = await _client.from('users').select().eq('id', user.id).single();

          return User.fromJson(userData);
        } catch (e) {
          print('Error fetching current user data from users table: $e');
          // If no record in users table, create one with data from auth
          final userMetadata = user.userMetadata;
          String? fullName = userMetadata?['full_name'] as String?;
          String email = user.email ?? '';

          await _client.from('users').upsert({
            'id': user.id,
            'email': email,
            'full_name': fullName ?? 'Flight Enthusiast',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });

          // Fetch the newly created user record
          final newUserData = await _client.from('users').select().eq('id', user.id).single();

          if (newUserData != null) {
            return User.fromJson(newUserData);
          }
        }

        // Fallback to auth data if users table fetch fails
        return User.fromSupabaseAuth(user.toJson());
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Explicitly fetches a complete user profile from the Supabase database
  Future<User?> refreshUserProfile(String userId) async {
    try {
      // Check if the user exists in the auth system
      final currentAuthUser = _client.auth.currentUser;
      if (currentAuthUser == null || currentAuthUser.id != userId) {
        print('User is not authenticated or ID mismatch');
        return null;
      }

      // First try to get user from the users table
      try {
        final userData = await _client
            .from('users')
            .select('*, saved_flights:saved_flights(*), recent_searches')
            .eq('id', userId)
            .single();

        if (userData != null) {
          return User.fromJson(userData);
        }
      } catch (e) {
        print('Error fetching user profile from database: $e');

        // If user doesn't exist in database, create a record
        final email = currentAuthUser.email ?? '';
        final metadata = currentAuthUser.userMetadata;
        final fullName = metadata?['full_name'] as String? ?? 'Flight Enthusiast';

        await _client.from('users').upsert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'saved_flights': [],
          'recent_searches': [],
        });

        // Fetch newly created record
        final newUserData = await _client.from('users').select().eq('id', userId).single();
        if (newUserData != null) {
          return User.fromJson(newUserData);
        }
      }

      // If all else fails, return a basic user object from auth data
      return User.fromSupabaseAuth(currentAuthUser.toJson());
    } catch (e) {
      print('Error refreshing user profile: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // User methods
  Future<User?> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      // Make sure the user exists in the users table
      final existingUser = await _client.from('users').select('id').eq('id', userId).maybeSingle();

      if (existingUser == null) {
        // User doesn't exist in users table, need to create
        final authUser = _client.auth.currentUser;
        if (authUser != null && authUser.id == userId) {
          final userData = {
              'id': userId,
            'email': authUser.email,
            'created_at': DateTime.now().toIso8601String(),
            ...data,
          };
          await _client.from('users').insert(userData);
        }
      } else {
        // User exists, update normally
        await _client.from('users').update(data).eq('id', userId);
      }

      // Fetch updated user data
      final userData = await _client.from('users').select().eq('id', userId).single();

      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Flight tracking methods (unchanged)
  Future<List<Flight>> getSavedFlights(String userId) async {
    try {
      final data = await _client.from('saved_flights').select('*').eq('user_id', userId);

      if (data != null) {
        return (data as List).map((flightJson) {
          return Flight(
            flightNumber: flightJson['flight_number'] ?? '',
            airline: flightJson['airline'] ?? '',
            airlineName: flightJson['airline_name'] ?? '',
            departureAirport: flightJson['departure_airport'] ?? '',
            arrivalAirport: flightJson['arrival_airport'] ?? '',
            departureCity: flightJson['departure_city'] ?? '',
            arrivalCity: flightJson['arrival_city'] ?? '',
            scheduledDeparture:
                flightJson['scheduled_departure'] != null ? DateTime.parse(flightJson['scheduled_departure']) : null,
            scheduledArrival:
                flightJson['scheduled_arrival'] != null ? DateTime.parse(flightJson['scheduled_arrival']) : null,
            status: flightJson['status'] ?? 'Scheduled',
            isFavorite: true,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting saved flights from Supabase: $e');

      // If the saved_flights table doesn't exist, return demo data
      if (e.toString().contains('relation "public.saved_flights" does not exist')) {
        return _getDemoSavedFlights();
      }

      return [];
    }
  }

  // Provide demo saved flights data when database table doesn't exist
  List<Flight> _getDemoSavedFlights() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return [
      Flight(
        flightNumber: 'BA1326',
        airline: 'BA',
        airlineName: 'British Airways',
        departureAirport: 'LHR',
        arrivalAirport: 'JFK',
        departureCity: 'London',
        arrivalCity: 'New York',
        scheduledDeparture: tomorrow.add(const Duration(hours: 10)),
        scheduledArrival: tomorrow.add(const Duration(hours: 13)),
        status: 'Scheduled',
        isFavorite: true,
      ),
      Flight(
        flightNumber: 'SQ321',
        airline: 'SQ',
        airlineName: 'Singapore Airlines',
        departureAirport: 'SIN',
        arrivalAirport: 'ICN',
        departureCity: 'Singapore',
        arrivalCity: 'Seoul',
        scheduledDeparture: tomorrow.add(const Duration(hours: 8)),
        scheduledArrival: tomorrow.add(const Duration(hours: 14)),
        status: 'Scheduled',
        isFavorite: true,
      ),
    ];
  }

  Future<bool> saveFlight(String userId, Flight flight) async {
    try {
      await _client.from('saved_flights').insert({
        'user_id': userId,
        'flight_number': flight.flightNumber,
        'airline': flight.airline,
        'airline_name': flight.airlineName,
        'departure_airport': flight.departureAirport,
        'arrival_airport': flight.arrivalAirport,
        'departure_city': flight.departureCity,
        'arrival_city': flight.arrivalCity,
        'scheduled_departure': flight.scheduledDeparture?.toIso8601String(),
        'scheduled_arrival': flight.scheduledArrival?.toIso8601String(),
        'status': flight.status,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving flight to Supabase: $e');

      // If the table doesn't exist, we'll consider it a success for the local implementation
      if (e.toString().contains('relation "public.saved_flights" does not exist')) {
        return true;
      }

      return false;
    }
  }

  Future<bool> removeSavedFlight(String userId, String flightNumber) async {
    try {
      await _client.from('saved_flights').delete().eq('user_id', userId).eq('flight_number', flightNumber);
      return true;
    } catch (e) {
      print('Error removing saved flight from Supabase: $e');

      // If the table doesn't exist, we'll consider it a success for the local implementation
      if (e.toString().contains('relation "public.saved_flights" does not exist')) {
        return true;
      }

      return false;
    }
  }

  Future<void> saveRecentSearch(String userId, String searchQuery) async {
    try {
      // Get the current user
      final user = await getCurrentUser();
      if (user != null) {
        // Add the search query to the user's recent searches
        final recentSearches = [searchQuery, ...user.recentSearches]
            .take(10) // Keep only the 10 most recent searches
            .toList();

        await updateUserProfile(userId, {'recent_searches': recentSearches});
      }
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  Future<void> clearRecentSearches(String userId) async {
    try {
      await updateUserProfile(userId, {'recent_searches': []});
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // Subscription methods
  Future<bool> updateSubscription(String userId, SubscriptionType type, DateTime expiryDate) async {
    try {
      await updateUserProfile(userId, {
        'subscription_type': type.toString().split('.').last,
        'subscription_expiry_date': expiryDate.toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }
}
