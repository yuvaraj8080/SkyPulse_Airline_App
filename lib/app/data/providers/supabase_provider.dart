import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/flight_model.dart';
import '../models/user_model.dart';

class SupabaseProvider {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  // Authentication methods
  Future<User?> signUp(String email, String password, String? fullName) async {
    try {
      final effectiveFullName = (fullName?.trim().isNotEmpty == true)
          ? fullName!.trim()
          : 'Flight Enthusiast';

      final supabase.AuthResponse response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': effectiveFullName},
        emailRedirectTo: null,
      );

      if (response.user != null) {
        // Wait for trigger to create user row (max 5 seconds)
        User? user = await _waitForUserRow(response.user!.id, maxAttempts: 10);

        if (user == null) {
          // Trigger failed, create user row manually
          print('Trigger failed, creating user row manually');
          user =
              await _createUserRowManually(response.user!, effectiveFullName);
        }

        return user;
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final supabase.AuthResponse response =
          await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        return await _getUserFromDatabase(response.user!.id);
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
        return await _getUserFromDatabase(user.id);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<User?> refreshUserProfile(String userId) async {
    try {
      final currentAuthUser = _client.auth.currentUser;
      if (currentAuthUser?.id != userId) {
        print('User is not authenticated or ID mismatch');
        return null;
      }
      return await _getUserFromDatabase(userId);
    } catch (e) {
      print('Error refreshing user profile: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // User profile methods
  Future<User?> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('users').update(data).eq('id', userId);

      return await _getUserFromDatabase(userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Saved flights methods
  Future<List<Flight>> getSavedFlights(String userId) async {
    try {
      final response = await _client
          .from('saved_flights')
          .select('flight_data')
          .eq('user_id', userId);

      return response
          .map((data) => Flight.fromJson(data['flight_data']))
          .toList();
    } catch (e) {
      print('Error getting saved flights: $e');
      return [];
    }
  }

  Future<bool> saveFlight(String userId, Flight flight) async {
    try {
      await _client.from('saved_flights').upsert({
        'user_id': userId,
        'flight_number': flight.flightNumber,
        'flight_data': flight.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving flight: $e');
      return false;
    }
  }

  Future<bool> removeSavedFlight(String userId, String flightNumber) async {
    try {
      await _client
          .from('saved_flights')
          .delete()
          .eq('user_id', userId)
          .eq('flight_number', flightNumber);
      return true;
    } catch (e) {
      print('Error removing saved flight: $e');
      return false;
    }
  }

  // Recent searches methods
  Future<void> saveRecentSearch(String userId, String searchQuery) async {
    try {
      await _client.from('recent_searches').upsert({
        'user_id': userId,
        'search_query': searchQuery.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  Future<void> clearRecentSearches(String userId) async {
    try {
      await _client.from('recent_searches').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // Subscription methods
  Future<bool> updateSubscription(
      String userId, SubscriptionType type, DateTime expiryDate) async {
    try {
      await _client.from('users').update({
        'subscription_type': type.toString().split('.').last,
        'subscription_expiry_date': expiryDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }

  // Helper methods
  Future<User?> _waitForUserRow(String userId, {int maxAttempts = 10}) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final userData =
            await _client.from('users').select().eq('id', userId).single();

        return User.fromJson(userData);
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          // Last attempt failed, return null to trigger manual creation
          print('Failed to find user row after $maxAttempts attempts');
          return null;
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
    return null;
  }

  Future<User?> _createUserRowManually(
      supabase.User authUser, String fullName) async {
    try {
      // Try to create the user row manually
      final userData = {
        'id': authUser.id,
        'email': authUser.email ?? '',
        'full_name': fullName,
        'subscription_type': 'free',
        'saved_flights': [],
        'recent_searches': [],
        'preferences': {},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('users').insert(userData);

      // Fetch the created user
      final response =
          await _client.from('users').select().eq('id', authUser.id).single();

      return User.fromJson(response);
    } catch (e) {
      print('Error creating user row manually: $e');
      // Fallback to auth data
      return User.fromSupabaseAuth(authUser.toJson());
    }
  }

  Future<User?> _getUserFromDatabase(String userId) async {
    try {
      final userData =
          await _client.from('users').select().eq('id', userId).single();

      return User.fromJson(userData);
    } catch (e) {
      print('Error fetching user from database: $e');
      // Fallback to auth data
      final authUser = _client.auth.currentUser;
      if (authUser != null) {
        return User.fromSupabaseAuth(authUser.toJson());
      }
      return null;
    }
  }
}
