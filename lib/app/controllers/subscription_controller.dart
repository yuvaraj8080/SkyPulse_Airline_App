import 'dart:async';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;
import '../data/models/user_model.dart';
import 'auth_controller.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SubscriptionController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxList<purchases.Offering> _offerings = <purchases.Offering>[].obs;
  final Rx<SubscriptionType> _currentSubscription = SubscriptionType.free.obs;
  final Rx<DateTime?> _expiryDate = Rx<DateTime?>(null);
  final RxBool _isInitialized = false.obs;

  bool get isLoading => _isLoading.value;
  List<purchases.Offering> get offerings => _offerings;
  SubscriptionType get currentSubscription => _currentSubscription.value;
  DateTime? get expiryDate => _expiryDate.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }

  // Initialize the RevenueCat SDK
  Future<void> initPlatformState() async {
    _isLoading.value = true;

    try {
      // Configure RevenueCat with proper error handling
      await purchases.Purchases.setDebugLogsEnabled(true);

      // Safely configure with fallback
      try {
        // Try to get API key from environment or constants
        final apiKey = Constants.revenueCatApiKey;
        if (apiKey.isNotEmpty && apiKey != 'YOUR_REVENUECAT_PUBLIC_SDK_KEY') {
          await purchases.Purchases.setup(apiKey);
        } else {
          print(
              'Warning: Using placeholder RevenueCat API key. Set a real key in Constants.');
          // Still setup with placeholder to avoid crashes, but features will be limited
          await purchases.Purchases.setup('temporaryplaceholder');
        }
      } catch (setupError) {
        print('RevenueCat setup error: $setupError');
        // Continue app flow without subscription features
      }

      // Check if user is logged in - with additional error handling
      if (_authController.isAuthenticated && _authController.user != null) {
        try {
          // Identify the user to RevenueCat
          await purchases.Purchases.logIn(_authController.user!.id);

          // Update subscription info
          await _updateSubscriptionStatus();
        } catch (userError) {
          print('Error identifying user with RevenueCat: $userError');
          // Continue with limited functionality
        }
      }

      // Get available offerings with error handling
      try {
        await fetchOfferings();
      } catch (offeringsError) {
        print('Error fetching offerings: $offeringsError');
        // Continue without offerings data
      }

      _isInitialized.value = true;
    } catch (e) {
      print('Error initializing subscription controller: $e');
      // Make sure we mark as initialized anyway to prevent repeated failures
      _isInitialized.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  // Fetch available subscription offerings
  Future<void> fetchOfferings() async {
    _isLoading.value = true;

    try {
      final offerings = await purchases.Purchases.getOfferings();
      if (offerings.current != null) {
        _offerings.value = [offerings.current!];
      } else {
        _offerings.value = offerings.all.values.toList();
      }
    } catch (e) {
      print('Error fetching offerings: $e');
      showErrorSnackBar(message: 'Failed to load subscription options');
    } finally {
      _isLoading.value = false;
    }
  }

  // Purchase a subscription
  Future<void> purchasePackage(purchases.Package package) async {
    if (!_authController.isAuthenticated) {
      showWarningSnackBar(message: 'Please sign in to purchase a subscription');
      Get.toNamed('/login');
      return;
    }

    _isLoading.value = true;

    try {
      final purchaserInfo = await purchases.Purchases.purchasePackage(package);
      await _handlePurchaseInfo(purchaserInfo);
      showSuccessSnackBar(message: 'Subscription successful');
    } on purchases.PurchasesErrorCode catch (e) {
      print('Error purchasing package: $e');

      if (e != purchases.PurchasesErrorCode.purchaseCancelledError) {
        showErrorSnackBar(message: 'Failed to complete purchase: ${e.name}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      showErrorSnackBar(message: 'An unexpected error occurred');
    } finally {
      _isLoading.value = false;
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    if (!_authController.isAuthenticated) {
      showWarningSnackBar(message: 'Please sign in to restore your purchases');
      Get.toNamed('/login');
      return;
    }

    _isLoading.value = true;

    try {
      final purchaserInfo = await purchases.Purchases.restorePurchases();
      await _handlePurchaseInfo(purchaserInfo);
      showSuccessSnackBar(message: 'Purchases restored successfully');
    } catch (e) {
      print('Error restoring purchases: $e');
      showErrorSnackBar(message: 'Failed to restore purchases');
    } finally {
      _isLoading.value = false;
    }
  }

  // Handle purchaser info and update subscription status
  Future<void> _handlePurchaseInfo(purchases.CustomerInfo purchaserInfo) async {
    final entitlements = purchaserInfo.entitlements.active;

    if (entitlements.containsKey('pro')) {
      _currentSubscription.value = SubscriptionType.pro;

      // Parse expiration date from String to DateTime if it exists
      final expirationDateStr =
          purchaserInfo.entitlements.active['pro']?.expirationDate;
      _expiryDate.value = expirationDateStr != null
          ? DateTime.tryParse(expirationDateStr)
          : null;

      if (_authController.isAuthenticated) {
        await _authController.updateSubscription(
          SubscriptionType.pro,
          _expiryDate.value != null
              ? _expiryDate.value!.difference(DateTime.now())
              : const Duration(days: 365),
        );
      }
    } else if (entitlements.containsKey('premium')) {
      _currentSubscription.value = SubscriptionType.premium;

      // Parse expiration date from String to DateTime if it exists
      final expirationDateStr =
          purchaserInfo.entitlements.active['premium']?.expirationDate;
      _expiryDate.value = expirationDateStr != null
          ? DateTime.tryParse(expirationDateStr)
          : null;

      if (_authController.isAuthenticated) {
        await _authController.updateSubscription(
          SubscriptionType.premium,
          _expiryDate.value != null
              ? _expiryDate.value!.difference(DateTime.now())
              : const Duration(days: 365),
        );
      }
    } else {
      _currentSubscription.value = SubscriptionType.free;
      _expiryDate.value = null;

      if (_authController.isAuthenticated) {
        await _authController.updateSubscription(
          SubscriptionType.free,
          const Duration(days: 0),
        );
      }
    }
  }

  // Update subscription status from backend
  Future<void> _updateSubscriptionStatus() async {
    if (!_authController.isAuthenticated) return;

    try {
      // Check if RevenueCat is properly initialized
      if (!_isInitialized.value) {
        print(
            'Warning: Attempting to get purchaser info when RevenueCat is not initialized');
        // Use user data from Supabase as fallback
        if (_authController.user != null) {
          final user = _authController.user!;
          _currentSubscription.value = user.subscriptionType;
          _expiryDate.value = user.subscriptionExpiryDate;
        }
        return;
      }

      // Safely get purchaser info with timeout protection
      purchases.CustomerInfo? purchaserInfo;
      try {
        purchaserInfo = await purchases.Purchases.getCustomerInfo()
            .timeout(const Duration(seconds: 5), onTimeout: () {
          print('Timeout getting purchaser info');
          throw TimeoutException('RevenueCat request timed out');
        });
      } catch (purchaserError) {
        print('Error getting purchaser info: $purchaserError');
        // Continue with app flow without RevenueCat data
        return;
      }

      if (purchaserInfo != null) {
        // Update from RevenueCat info
        await _handlePurchaseInfo(purchaserInfo);
      }

      // Sync with user info from Supabase (use as fallback or to overwrite)
      if (_authController.user != null) {
        final user = _authController.user!;
        _currentSubscription.value = user.subscriptionType;
        _expiryDate.value = user.subscriptionExpiryDate;
      }
    } catch (e) {
      print('Error updating subscription status: $e');
    }
  }

  // Get subscription features
  List<String> getSubscriptionFeatures(SubscriptionType type) {
    final subscriptionKey = type.toString().split('.').last;
    if (Constants.subscriptionPlans.containsKey(subscriptionKey)) {
      return List<String>.from(
          Constants.subscriptionPlans[subscriptionKey]['features']);
    }
    return [];
  }

  // Get subscription price
  String getSubscriptionPrice(SubscriptionType type) {
    final subscriptionKey = type.toString().split('.').last;
    if (Constants.subscriptionPlans.containsKey(subscriptionKey)) {
      final price = Constants.subscriptionPlans[subscriptionKey]['price'];
      return price == 0.0 ? 'Free' : '\$${price.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  // Check if feature is available for current subscription
  bool hasFeature(String featureName) {
    final features = getSubscriptionFeatures(_currentSubscription.value);
    return features
        .any((f) => f.toLowerCase().contains(featureName.toLowerCase()));
  }

  // Check if subscription is active
  bool get isSubscriptionActive {
    return _currentSubscription.value != SubscriptionType.free &&
        (_expiryDate.value == null ||
            DateTime.now().isBefore(_expiryDate.value!));
  }
}
