import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../routes/app_routes.dart';
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
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading.value = true;
    try {
      final isStoredAuthenticated = await _userRepository.isAuthenticated();

      if (isStoredAuthenticated) {
        final currentUser = await _userRepository.getCurrentUser();

        if (currentUser != null) {
          _user.value = currentUser;
          _isAuthenticated.value = true;
          logger.i('User authenticated: ${currentUser.email}');
        } else {
          // Clear invalid auth state
          await _clearAuthState();
          logger.w('Invalid stored auth state cleared');
        }
      } else {
        _isAuthenticated.value = false;
        logger.i('User not authenticated');
      }
    } catch (e) {
      logger.e('Error checking auth status', error: e);
      _isAuthenticated.value = false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      showErrorSnackBar(message: 'Please enter valid email and password');
      return false;
    }

    _isLoading.value = true;
    update();

    try {
      final user = await _userRepository.signIn(email, password);

      if (user != null) {
        _user.value = user;
        _isAuthenticated.value = true;
        await _saveAuthState();

        logger.i('User signed in: ${user.email}');
        showSuccessSnackBar(
            message: 'Welcome back, ${user.fullName ?? 'User'}!');

        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);
        return true;
      } else {
        showErrorSnackBar(message: 'Invalid email or password');
        return false;
      }
    } catch (e) {
      logger.e('Error signing in', error: e);
      _handleAuthError(e);
      return false;
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<bool> signUp(String email, String password, String? fullName) async {
    if (email.trim().isEmpty || password.isEmpty) {
      showErrorSnackBar(message: 'Please enter valid email and password');
      return false;
    }

    if (password.length < 6) {
      showErrorSnackBar(message: 'Password must be at least 6 characters');
      return false;
    }

    _isLoading.value = true;
    update();

    try {
      final user = await _userRepository.signUp(email, password, fullName);

      if (user != null) {
        _user.value = user;
        _isAuthenticated.value = true;
        await _saveAuthState();

        logger.i('User signed up: ${user.email}');
        showSuccessSnackBar(
            message: 'Welcome to SkyPulse, ${user.fullName ?? 'User'}!');

        // Navigate to home screen
        Get.offAllNamed(Routes.HOME);
        return true;
      } else {
        showErrorSnackBar(message: 'Failed to create account');
        return false;
      }
    } catch (e) {
      logger.e('Error signing up', error: e);
      _handleAuthError(e);
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
      await _clearAuthState();

      _user.value = null;
      _isAuthenticated.value = false;

      logger.i('User signed out');
      showSuccessSnackBar(message: 'Signed out successfully');
    } catch (e) {
      logger.e('Error signing out', error: e);
      showErrorSnackBar(message: 'Error signing out');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      showErrorSnackBar(message: 'Please enter a valid email');
      return;
    }

    _isLoading.value = true;
    update();

    try {
      await _userRepository.resetPassword(email);
      logger.i('Password reset email sent to: $email');
      showSuccessSnackBar(message: 'Password reset email sent!');
    } catch (e) {
      logger.e('Error resetting password', error: e);
      _handleAuthError(e);
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
      final updatedUser =
          await _userRepository.updateUserProfile(user!.id, data);
      if (updatedUser != null) {
        _user.value = updatedUser;
        logger.i('User profile updated');
        showSuccessSnackBar(message: 'Profile updated successfully');
      }
    } catch (e) {
      logger.e('Error updating profile', error: e);
      showErrorSnackBar(message: 'Failed to update profile');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> updateSubscription(
      SubscriptionType type, Duration duration) async {
    if (_user.value == null) return;

    _isLoading.value = true;
    update();

    try {
      final expiryDate = DateTime.now().add(duration);
      final success = await _userRepository.updateSubscription(
        _user.value!.id,
        type,
        expiryDate,
      );

      if (success) {
        final updatedUser = await _userRepository.getCurrentUser();
        if (updatedUser != null) {
          _user.value = updatedUser;
        }
        showSuccessSnackBar(message: 'Subscription updated successfully');
      } else {
        showErrorSnackBar(message: 'Failed to update subscription');
      }
    } catch (e) {
      logger.e('Error updating subscription', error: e);
      showErrorSnackBar(message: 'Error updating subscription');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _userRepository.saveUserSettings(settings);
    } catch (e) {
      logger.e('Error saving settings', error: e);
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _userRepository.getUserSettings();
    } catch (e) {
      logger.e('Error getting settings', error: e);
      return {};
    }
  }

  // Helper methods
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', true);
  }

  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
  }

  void _handleAuthError(dynamic error) {
    String message = 'Authentication failed';

    if (error.toString().contains('Invalid login credentials')) {
      message = 'Invalid email or password';
    } else if (error.toString().contains('Email not confirmed')) {
      message = 'Please check your email and confirm your account';
    } else if (error.toString().contains('over_email_send_rate_limit')) {
      message = 'Please wait before trying again';
    } else if (error.toString().contains('User already registered')) {
      message = 'An account with this email already exists';
    } else if (error.toString().contains('Password should be at least')) {
      message = 'Password is too weak';
    } else if (error.toString().contains('User row not found after signup')) {
      message = 'Account created but setup incomplete. Please try signing in.';
    } else if (error.toString().contains('User row not found')) {
      message = 'Account created but setup incomplete. Please try signing in.';
    }

    showErrorSnackBar(message: message);
  }
}
