import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../controllers/subscription_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class SubscriptionView extends StatelessWidget {
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();

  SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Plans', style: AppTextStyles.headline6),
      ),
      body: Obx(
        () => _subscriptionController.isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSubscriptionCards(),
                    const SizedBox(height: 24),
                    _buildBenefitsSection(),
                    const SizedBox(height: 24),
                    _buildFAQSection(),
                    const SizedBox(height: 24),
                    _buildRestorePurchasesButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade Your Experience',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Get premium features and support the app development',
            style: AppTextStyles.subtitle1.copyWith(
              color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCards() {
    return Column(
      children: [
        _buildSubscriptionCard(
          title: 'Free',
          price: 'Free',
          features: Constants.subscriptionPlans['free']?['features'] as List<dynamic>? ?? [],
          type: SubscriptionType.free,
          animationDelay: 0,
        ),
        const SizedBox(height: 16),
        _buildSubscriptionCard(
          title: 'Premium',
          price: '\$${Constants.subscriptionPlans['premium']?['price']}',
          features: Constants.subscriptionPlans['premium']?['features'] as List<dynamic>? ?? [],
          type: SubscriptionType.premium,
          animationDelay: 200,
          isRecommended: true,
        ),
        const SizedBox(height: 16),
        _buildSubscriptionCard(
          title: 'Pro',
          price: '\$${Constants.subscriptionPlans['pro']?['price']}',
          features: Constants.subscriptionPlans['pro']?['features'] as List<dynamic>? ?? [],
          type: SubscriptionType.pro,
          animationDelay: 400,
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required List<dynamic> features,
    required SubscriptionType type,
    required int animationDelay,
    bool isRecommended = false,
  }) {
    final isCurrentSubscription = _subscriptionController.currentSubscription == type;
    final cardColor = _getSubscriptionColor(type);
    
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: animationDelay)),
        SlideEffect(delay: Duration(milliseconds: animationDelay)),
      ],
      child: Card(
        elevation: isRecommended ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isRecommended
              ? BorderSide(color: cardColor, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'RECOMMENDED',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headline5,
                      ),
                      if (isCurrentSubscription)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardColor),
                          ),
                          child: Text(
                            'CURRENT',
                            style: AppTextStyles.button.copyWith(
                              color: cardColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: AppTextStyles.subscriptionPrice.copyWith(
                      color: cardColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type == SubscriptionType.free ? '' : 'per month',
                    style: AppTextStyles.bodyText2.copyWith(
                      color: Get.isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  ...features.map((feature) => _buildFeatureItem(feature.toString())),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isCurrentSubscription
                        ? 'Current Plan'
                        : (type == SubscriptionType.free
                            ? 'Current Plan'
                            : 'Subscribe'),
                    onPressed: () => _handleSubscription(type),
                    isFullWidth: true,
                    buttonType: isCurrentSubscription
                        ? ButtonType.disabled
                        : ButtonType.filled,
                    color: cardColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.subscriptionFeature,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 600)), SlideEffect(delay: Duration(milliseconds: 600))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Benefits',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.notifications_active,
            title: 'Priority Notifications',
            description:
                'Get alerts about flight status changes, gate changes, and boarding times before everyone else.',
          ),
          const SizedBox(height: 12),
          _buildBenefitCard(
            icon: Icons.timelapse,
            title: 'Delay Predictions',
            description:
                'Our advanced algorithm predicts delays before they\'re officially announced.',
          ),
          const SizedBox(height: 12),
          _buildBenefitCard(
            icon: Icons.remove_circle,
            title: 'Ad-Free Experience',
            description:
                'Enjoy a clean, distraction-free experience without any advertisements.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: Get.isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 800)), SlideEffect(delay: Duration(milliseconds: 800))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            question: 'Can I cancel my subscription anytime?',
            answer:
                'Yes, you can cancel your subscription at any time from your App Store or Google Play account settings. Your premium features will remain active until the end of your billing cycle.',
          ),
          _buildFAQItem(
            question: 'How do I restore my purchases?',
            answer:
                'If you\'ve previously subscribed and need to restore your purchases, simply tap the "Restore Purchases" button at the bottom of this page.',
          ),
          _buildFAQItem(
            question: 'Is my payment information secure?',
            answer:
                'We use Apple App Store and Google Play Store for all subscription payments. We never store your payment information on our servers.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestorePurchasesButton() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 1000)), SlideEffect(delay: Duration(milliseconds: 1000))],
      child: Center(
        child: TextButton(
          onPressed: _subscriptionController.restorePurchases,
          child: Text(
            'Restore Purchases',
            style: AppTextStyles.button.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubscription(SubscriptionType type) async {
    if (type == SubscriptionType.free || _subscriptionController.currentSubscription == type) {
      return;
    }

    // Check if offerings are available
    if (_subscriptionController.offerings.isEmpty) {
      Get.snackbar(
        'No Subscriptions Available',
        'Please try again later or check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Find the appropriate package based on the subscription type
      for (final offering in _subscriptionController.offerings) {
        for (final package in offering.availablePackages) {
          if ((type == SubscriptionType.premium && package.packageType == PackageType.monthly) ||
              (type == SubscriptionType.pro && package.packageType == PackageType.annual)) {
            await _subscriptionController.purchasePackage(package);
            return;
          }
        }
      }

      // If we get here, we couldn't find a matching package
      Get.snackbar(
        'Subscription Not Available',
        'The selected subscription plan is currently unavailable.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Subscription Error',
        'An error occurred during the subscription process. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color _getSubscriptionColor(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.premium:
        return AppColors.premiumSubscription;
      case SubscriptionType.pro:
        return AppColors.proSubscription;
      default:
        return AppColors.freeSubscription;
    }
  }
}
