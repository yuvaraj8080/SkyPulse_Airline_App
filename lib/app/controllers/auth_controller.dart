import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import '../routes/app_routes.dart';
import '../utils/helpers.dart';

class AuthController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  
  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _user.value != null;
  
  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }
  
  // Check if user is already authenticated
Future<void> checkAuthStatus() async {
  _isLoading.value = true;
  
  try {
    // First check local authentication flag
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('is_authenticated') ?? false;
    
    if (isAuth) {
      // Give Supabase time to restore session
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Now check with Supabase
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser != null) {
        _user.value = currentUser;
      } else {
        // If Supabase says no user but we have local auth, clear both
        await _userRepository.signOut();
        await prefs.setBool('is_authenticated', false);
      }
    }
  } catch (e) {
    print('Error checking auth status: $e');
    // On error, assume not authenticated
    await _userRepository.signOut();
  } finally {
    _isLoading.value = false;
  }
}
  
  // Sign up with email and password
  Future<void> signUp(String email, String password, String? fullName) async {
    _isLoading.value = true;
    
    try {
      final user = await _userRepository.signUp(email, password, fullName);
      
      if (user != null) {
        _user.value = user;
        Get.offAllNamed(Routes.HOME);
        showSuccessSnackBar(message: 'Account created successfully!');
      } else {
        showErrorSnackBar(message: 'Failed to create account.');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _isLoading.value = true;
    
    try {
      final user = await _userRepository.signIn(email, password);
      
      if (user != null) {
        _user.value = user;
        Get.offAllNamed(Routes.HOME);
      } else {
        showErrorSnackBar(message: 'Invalid credentials.');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _isLoading.value = true;
    
    try {
      await _userRepository.signOut();
      _user.value = null;
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      showErrorSnackBar(message: 'Error signing out: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    _isLoading.value = true;
    
    try {
      await _userRepository.resetPassword(email);
      showSuccessSnackBar(message: 'Password reset link sent to $email');
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user.value == null) return;
    
    _isLoading.value = true;
    
    try {
      final updatedUser = await _userRepository.updateUserProfile(_user.value!.id, data);
      
      if (updatedUser != null) {
        _user.value = updatedUser;
        showSuccessSnackBar(message: 'Profile updated successfully');
      } else {
        showErrorSnackBar(message: 'Failed to update profile');
      }
    } catch (e) {
      showErrorSnackBar(message: 'Error: ${e.toString()}');
    } finally {
      _isLoading.value = false;
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
