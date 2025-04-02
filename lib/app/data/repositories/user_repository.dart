import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/supabase_provider.dart';
import '../models/user_model.dart';
import '../models/flight_model.dart';

class UserRepository {
  final SupabaseProvider _supabaseProvider = SupabaseProvider();
  
  // Authentication methods
  Future<User?> signUp(String email, String password, String? fullName) async {
    try {
      return await _supabaseProvider.signUp(email, password, fullName);
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }
  
  Future<User?> signIn(String email, String password) async {
    try {
      final user = await _supabaseProvider.signIn(email, password);
      
      if (user != null) {
        // Save authentication state to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
      }
      
      return user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabaseProvider.signOut();
      
      // Clear authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', false);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  Future<User?> getCurrentUser() async {
    try {
      return await _supabaseProvider.getCurrentUser();
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseProvider.resetPassword(email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
  
  // User profile methods
  Future<User?> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      return await _supabaseProvider.updateUserProfile(userId, data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  // Saved flights methods
  Future<List<Flight>> getSavedFlights(String userId) async {
    try {
      return await _supabaseProvider.getSavedFlights(userId);
    } catch (e) {
      print('Error getting saved flights: $e');
      return [];
    }
  }
  
  Future<bool> saveFlight(String userId, Flight flight) async {
    try {
      return await _supabaseProvider.saveFlight(userId, flight);
    } catch (e) {
      print('Error saving flight: $e');
      return false;
    }
  }
  
  Future<bool> removeSavedFlight(String userId, String flightNumber) async {
    try {
      return await _supabaseProvider.removeSavedFlight(userId, flightNumber);
    } catch (e) {
      print('Error removing saved flight: $e');
      return false;
    }
  }
  
  // Recent searches methods
  Future<void> saveRecentSearch(String userId, String searchQuery) async {
    try {
      await _supabaseProvider.saveRecentSearch(userId, searchQuery);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }
  
  Future<void> clearRecentSearches(String userId) async {
    try {
      await _supabaseProvider.clearRecentSearches(userId);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }
  
  // Subscription methods
  Future<bool> updateSubscription(String userId, SubscriptionType type, DateTime expiryDate) async {
    try {
      return await _supabaseProvider.updateSubscription(userId, type, expiryDate);
    } catch (e) {
      print('Error updating subscription: $e');
      return false;
    }
  }
  
  // Check authentication state from local storage
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_authenticated') ?? false;
    } catch (e) {
      print('Error checking authentication state: $e');
      return false;
    }
  }
  
  // Save user settings locally
  Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in settings.entries) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value);
        } else if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value);
        } else if (entry.value is double) {
          await prefs.setDouble(entry.key, entry.value);
        }
      }
    } catch (e) {
      print('Error saving user settings: $e');
    }
  }
  
  // Get user settings from local storage
  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'theme_mode': prefs.getString('theme_mode') ?? 'system',
        'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
        'use_24_hour_format': prefs.getBool('use_24_hour_format') ?? false,
        'distance_unit': prefs.getString('distance_unit') ?? 'km',
      };
    } catch (e) {
      print('Error getting user settings: $e');
      return {
        'theme_mode': 'system',
        'notifications_enabled': true,
        'use_24_hour_format': false,
        'distance_unit': 'km',
      };
    }
  }
}
