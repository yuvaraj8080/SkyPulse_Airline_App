import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../utils/helpers.dart';

class AuthController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final logger = Logger();

  Rx<User?> _user = Rx<User?>(null);
  RxBool _isLoading = false.obs;
  RxBool _isAuthenticated = false.obs;

  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    // Authentication state will be checked in checkAuthStatus
  }

  Future<void> checkAuthStatus() async {
    _isLoading.value = true;
    try {
      // First check SharedPreferences
      bool isStoredAuthenticated = await _userRepository.isAuthenticated();

      if (isStoredAuthenticated) {
        // Then verify with Supabase current session
        final currentUser = await _userRepository.getCurrentUser();

        if (currentUser != null) {
          _user.value = currentUser;
          _isAuthenticated.value = true;

          // Explicitly log user details for debugging
          logger.i('User is authenticated: ${currentUser.email}');
          logger.i('User full name: ${currentUser.fullName ?? "No name set"}');
          logger.i('User ID: ${currentUser.id}');

          // If user profile is incomplete, fetch full profile
          if (currentUser.fullName == null || currentUser.fullName!.isEmpty) {
            try {
              final fullProfile = await _userRepository.refreshUserProfile(currentUser.id);
              if (fullProfile != null) {
                _user.value = fullProfile;
                logger.i('Updated user profile with full name: ${fullProfile.fullName}');
              }
            } catch (profileError) {
              logger.e('Error fetching complete user profile', error: profileError);
            }
          }
        } else {
          // Session is invalid but preferences say logged in - clear it
          _isAuthenticated.value = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_authenticated', false);
          logger.w('Stored auth state was true but no valid session found');
        }
      } else {
        _isAuthenticated.value = false;
        logger.i('User is not authenticated');
      }
    } catch (e) {
      logger.e('Error checking auth status', error: e);
      _isAuthenticated.value = false;
    } finally {
      _isLoading.value = false;
      update(); // Notify listeners to update UI
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading.value = true;
    update();

    try {
      final user = await _userRepository.signIn(email, password);

      if (user != null) {
        _user.value = user;
        _isAuthenticated.value = true;

        // Explicitly save authentication state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);

        logger.i('User signed in: ${user.email}');
        update();
        return true;
      } else {
        logger.w('Sign in failed: User is null');
        update();
        return false;
      }
    } catch (e) {
      logger.e('Error signing in', error: e);
      _isAuthenticated.value = false;
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<bool> signUp(String email, String password, String? fullName) async {
    _isLoading.value = true;
    update();

    try {
      // Ensure a default name if none provided
      final effectiveFullName = (fullName != null && fullName.isNotEmpty) ? fullName : 'Flight Enthusiast';

      final user = await _userRepository.signUp(email, password, fullName);

      if (user != null) {
        _user.value = user;
        _isAuthenticated.value = true;

        // Explicitly save authentication state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);

        // Make sure the user profile is properly set with name
        if (user.fullName == null || user.fullName!.isEmpty) {
          try {
            await _userRepository.updateUserProfile(user.id, {'full_name': effectiveFullName});
            // Refresh the user object with updated profile
            final updatedUser = await _userRepository.refreshUserProfile(user.id);
            if (updatedUser != null) {
              _user.value = updatedUser;
            }
          } catch (e) {
            logger.e('Error updating user profile during signup', error: e);
          }
        }

        logger.i('User signed up: ${user.email}');
        update();
        return true;
      } else {
        logger.w('Sign up failed: User is null');
        update();
        return false;
      }
    } catch (e) {
      logger.e('Error signing up', error: e);
      update();
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> signOut() async {
    _isLoading.value = true;
    update();

    try {
      await _userRepository.signOut();
      _user.value = null;
      _isAuthenticated.value = false;

      // Explicitly clear authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', false);

      logger.i('User signed out');
    } catch (e) {
      logger.e('Error signing out', error: e);
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading.value = true;
    update();

    try {
      await _userRepository.resetPassword(email);
      logger.i('Password reset email sent to: $email');
    } catch (e) {
      logger.e('Error resetting password', error: e);
      rethrow;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (user == null) return;

    _isLoading.value = true;
    update();

    try {
      final updatedUser = await _userRepository.updateUserProfile(user!.id, data);
      if (updatedUser != null) {
        _user.value = updatedUser;
        logger.i('User profile updated');
      }
    } catch (e) {
      logger.e('Error updating profile', error: e);
      rethrow;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Update user subscription
  Future<void> updateSubscription(SubscriptionType type, Duration duration) async {
    if (_user.value == null) return;

    _isLoading.value = true;

    try {
      final expiryDate = DateTime.now().add(duration);
      final success = await _userRepository.updateSubscription(
        _user.value!.id,
        type,
        expiryDate,
      );

      if (success) {
        // Refresh user data
        final updatedUser = await _userRepository.getCurrentUser();
        if (updatedUser != null) {
          _user.value = updatedUser;
        }

        showSuccessSnackBar(message: 'Subscription updated successfully');
      } else {
        showErrorSnackBar(message: 'Failed to update subscription');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Save user settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _userRepository.saveUserSettings(settings);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Get user settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _userRepository.getUserSettings();
    } catch (e) {
      print('Error getting settings: $e');
      return {};
    }
  }
}
