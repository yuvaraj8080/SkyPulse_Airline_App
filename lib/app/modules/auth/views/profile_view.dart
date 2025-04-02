import 'package:flight_tracker/app/controllers/flight_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/subscription_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class ProfileView extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();
  
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _initControllers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headline6),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Obx(
        () => _authController.isLoading
            ? const LoadingWidget()
            : _authController.user == null
                ? _buildNotLoggedIn()
                : _buildProfile(),
      ),
    );
  }

  void _initControllers() {
    if (_authController.user != null && _authController.user!.fullName != null) {
      _nameController.text = _authController.user!.fullName!;
    }
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'You are not logged in',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          Text(
            'Please sign in to access your profile',
            style: AppTextStyles.subtitle1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Sign In',
            onPressed: () => Get.toNamed(Routes.LOGIN),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 32),
          _buildProfileForm(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSubscriptionSection(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Animate(
      effects: const [FadeEffect(), SlideEffect(duration: Duration(milliseconds: 500))],
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(
                _authController.user!.subscriptionIcon,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _authController.user!.fullName ?? 'Flight Enthusiast',
              style: AppTextStyles.headline5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _authController.user!.email,
              style: AppTextStyles.subtitle1.copyWith(
                color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getSubscriptionColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getSubscriptionText(),
                style: AppTextStyles.subtitle2.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTextStyles.headline6),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: _authController.user!.email,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Save Changes',
            onPressed: _updateProfile,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subscription', style: AppTextStyles.headline6),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(
            _getSubscriptionIcon(),
            color: _getSubscriptionColor(),
            size: 32,
          ),
          title: Text(
            _getSubscriptionText(),
            style: AppTextStyles.subtitle1,
          ),
          subtitle: Text(
            _getSubscriptionDetails(),
            style: AppTextStyles.bodyText2,
          ),
          trailing: CustomButton(
            text: 'Manage',
            onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
            height: 36,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: AppTextStyles.headline6),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: Text('Notifications', style: AppTextStyles.subtitle1),
          trailing: Switch(
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update notification settings
              _authController.saveSettings({'notifications_enabled': value});
            },
            activeColor: AppColors.primary,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text('24-Hour Format', style: AppTextStyles.subtitle1),
          trailing: Switch(
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update time format settings
              _authController.saveSettings({'use_24_hour_format': value});
            },
            activeColor: AppColors.primary,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: Text('Clear Cache', style: AppTextStyles.subtitle1),
          onTap: () {
            // Show confirmation dialog and clear cache
            Get.dialog(
              AlertDialog(
                title: Text('Clear Cache', style: AppTextStyles.headline5),
                content: Text(
                  'This will clear all cached flight data. Continue?',
                  style: AppTextStyles.bodyText2,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.find<FlightController>().clearFlightCache();
                    },
                    child: Text('Clear', style: AppTextStyles.button),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return CustomButton(
      text: 'Log Out',
      onPressed: _logout,
      isFullWidth: true,
      buttonType: ButtonType.outlined,
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _authController.updateProfile({
        'full_name': _nameController.text.trim(),
      });
    }
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Log Out', style: AppTextStyles.headline5),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyText2,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _authController.signOut();
            },
            child: Text('Log Out', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor() {
    switch (_authController.user!.subscriptionType) {
      case SubscriptionType.premium:
        return AppColors.premiumSubscription;
      case SubscriptionType.pro:
        return AppColors.proSubscription;
      default:
        return AppColors.freeSubscription;
    }
  }

  IconData _getSubscriptionIcon() {
    switch (_authController.user!.subscriptionType) {
      case SubscriptionType.premium:
        return Icons.star;
      case SubscriptionType.pro:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  String _getSubscriptionText() {
    switch (_authController.user!.subscriptionType) {
      case SubscriptionType.premium:
        return 'Premium';
      case SubscriptionType.pro:
        return 'Pro';
      default:
        return 'Free';
    }
  }

  String _getSubscriptionDetails() {
    if (_authController.user!.subscriptionType == SubscriptionType.free) {
      return 'Basic features';
    }

    if (_authController.user!.subscriptionExpiryDate != null) {
      final expiryDate = _authController.user!.subscriptionExpiryDate!;
      return 'Expires on ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}';
    }

    return 'Active subscription';
  }
}
