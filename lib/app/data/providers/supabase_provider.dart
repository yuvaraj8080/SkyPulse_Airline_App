import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/flight_model.dart';
import '../models/user_model.dart';

class SupabaseProvider {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  // Authentication methods
  Future<User?> signUp(String email, String password, String? fullName) async {
    try {
      final supabase.AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user != null) {
        // The database trigger will automatically create the user record
        // Just return the user information from the auth response
        return User.fromSupabaseAuth(response.user!.toJson());
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
        // Fetch user data from the users table
        final userData = await _client.from('users').select().eq('id', response.user!.id).single();

        if (userData != null) {
          return User.fromJson(userData);
        }

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
        // Fetch user data from the users table
        final userData = await _client.from('users').select().eq('id', user.id).single();

        if (userData != null) {
          return User.fromJson(userData);
        }

        return User.fromSupabaseAuth(user.toJson());
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
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

      await _client.from('users').update(data).eq('id', userId);

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

  // Flight tracking methods
  Future<List<Flight>> getSavedFlights(String userId) async {
    try {
      final data = await _client.from('saved_flights').select('flight_data').eq('user_id', userId);

      if (data != null) {
        return (data as List).map((item) => Flight.fromJson(item['flight_data'])).toList();
      }
      return [];
    } catch (e) {
      print('Error getting saved flights: $e');
      return [];
    }
  }

  Future<bool> saveFlight(String userId, Flight flight) async {
    try {
      await _client.from('saved_flights').insert({
        'user_id': userId,
        'flight_number': flight.flightNumber,
        'flight_data': flight.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Also update the user's saved flights array
      final user = await getCurrentUser();
      if (user != null) {
        final savedFlights = [...user.savedFlights, flight.flightNumber];
        await updateUserProfile(userId, {'saved_flights': savedFlights});
      }

      return true;
    } catch (e) {
      print('Error saving flight: $e');
      return false;
    }
  }

  Future<bool> removeSavedFlight(String userId, String flightNumber) async {
    try {
      await _client.from('saved_flights').delete().eq('user_id', userId).eq('flight_number', flightNumber);

      // Also update the user's saved flights array
      final user = await getCurrentUser();
      if (user != null) {
        final savedFlights = user.savedFlights.where((f) => f != flightNumber).toList();
        await updateUserProfile(userId, {'saved_flights': savedFlights});
      }

      return true;
    } catch (e) {
      print('Error removing saved flight: $e');
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
