import 'package:flight_tracker/app/modules/auth/views/profile_view.dart';
import 'package:flight_tracker/app/modules/flight/views/flight_search_view.dart';
import 'package:flight_tracker/app/modules/flight/views/saved_flights_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/flight_controller.dart';
import '../../../controllers/subscription_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/flight_card.dart';
import '../../../widgets/loading_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController _authController = Get.find<AuthController>();
  final FlightController _flightController = Get.find<FlightController>();
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const FlightSearchView(),
    SavedFlightsView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final FlightController flightController = Get.find<FlightController>();
    final SubscriptionController subscriptionController = Get.find<SubscriptionController>();

    // Load saved flights when home tab is shown
    flightController.loadSavedFlights();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyPulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications or go to notification settings
              Get.toNamed(Routes.PROFILE);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await flightController.loadSavedFlights();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(authController),
              const SizedBox(height: 24),
              _buildQuickSearchSection(),
              const SizedBox(height: 24),
              _buildUpcomingFlightsSection(flightController),
              const SizedBox(height: 24),
              _buildSubscriptionCard(subscriptionController),
              const SizedBox(height: 24),
              _buildFlightStats(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthController authController) {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  'Welcome, ${authController.user?.fullName ?? 'Traveler'}!',
                  style: AppTextStyles.headline4.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your flight status, delays, and more',
                style: AppTextStyles.subtitle1.copyWith(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(Routes.FLIGHT_SEARCH);
                },
                icon: const Icon(Icons.search),
                label: const Text('Track a Flight'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Search', style: AppTextStyles.headline5),
        const SizedBox(height: 16),
        Animate(
          effects: const [
            FadeEffect(delay: Duration(milliseconds: 200)),
            SlideEffect(delay: Duration(milliseconds: 200))
          ],
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickSearchCard(
                    icon: Icons.flight_takeoff,
                    title: 'Flight Number',
                    subtitle: 'Search by flight code',
                    onTap: () {
                      Get.toNamed(Routes.FLIGHT_SEARCH);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickSearchCard(
                    icon: Icons.location_on_outlined,
                    title: 'Airport',
                    subtitle: 'Search by route',
                    onTap: () {
                      Get.toNamed(Routes.FLIGHT_SEARCH);
                      // Switch to route tab - would need to be implemented
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSearchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodyText2.copyWith(
                  color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingFlightsSection(FlightController flightController) {
    return Obx(() {
      if (flightController.isLoading) {
        return const LoadingWidget();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Flights', style: AppTextStyles.headline5),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.SAVED_FLIGHTS);
                },
                child: Text(
                  'View All',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (flightController.savedFlights.isEmpty)
            _buildNoSavedFlightsCard()
          else
            _buildSavedFlightsCards(flightController),
        ],
      );
    });
  }

  Widget _buildNoSavedFlightsCard() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 300)), SlideEffect(delay: Duration(milliseconds: 300))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(
                Icons.flight,
                size: 48,
                color: AppColors.lightTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Saved Flights',
                style: AppTextStyles.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking flights by searching for a flight number or route',
                style: AppTextStyles.bodyText2.copyWith(
                  color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.FLIGHT_SEARCH);
                },
                child: const Text('Track a Flight'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedFlightsCards(FlightController flightController) {
    // Show up to 2 flights in the home view
    final displayFlights = flightController.savedFlights.take(2).toList();

    return Column(
      children: [
        for (var i = 0; i < displayFlights.length; i++)
          Animate(
            effects: [
              FadeEffect(delay: Duration(milliseconds: 300 + (i * 100))),
              SlideEffect(delay: Duration(milliseconds: 300 + (i * 100))),
            ],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FlightCard(
                flight: displayFlights[i],
                onTap: () {
                  flightController.setSelectedFlight(displayFlights[i]);
                  Get.toNamed(
                    Routes.FLIGHT_DETAIL,
                    arguments: {'flightNumber': displayFlights[i].flightNumber},
                  );
                },
                showFavoriteIcon: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionCard(SubscriptionController subscriptionController) {
    return Obx(() {
      if (subscriptionController.currentSubscription != SubscriptionType.free) {
        // User already has a subscription
        return _buildCurrentSubscriptionCard(subscriptionController);
      }

      return Animate(
        effects: const [
          FadeEffect(delay: Duration(milliseconds: 400)),
          SlideEffect(delay: Duration(milliseconds: 400))
        ],
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Premium Features',
                      style: AppTextStyles.headline5.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Upgrade to get priority notifications, detailed flight predictions, and more!',
                  style: AppTextStyles.bodyText2.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Learn more about subscription
                          Get.toNamed(Routes.SUBSCRIPTION);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Learn More'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Go to subscription page
                          Get.toNamed(Routes.SUBSCRIPTION);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accent,
                        ),
                        child: const Text('Upgrade'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionController subscriptionController) {
    final subscriptionType = subscriptionController.currentSubscription;
    final expiryDate = subscriptionController.expiryDate;

    String expiryText;
    if (expiryDate != null) {
      expiryText = 'Valid until ${formatDate(expiryDate)}';
    } else {
      expiryText = 'Active subscription';
    }

    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 400)), SlideEffect(delay: Duration(milliseconds: 400))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: subscriptionType == SubscriptionType.premium
                ? AppColors.premiumSubscription.withOpacity(0.2)
                : AppColors.proSubscription.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: subscriptionType == SubscriptionType.premium
                  ? AppColors.premiumSubscription
                  : AppColors.proSubscription,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    subscriptionType == SubscriptionType.premium ? Icons.star : Icons.workspace_premium,
                    color: subscriptionType == SubscriptionType.premium
                        ? AppColors.premiumSubscription
                        : AppColors.proSubscription,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    subscriptionType == SubscriptionType.premium ? 'Premium Subscription' : 'Pro Subscription',
                    style: AppTextStyles.headline5,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for supporting Flight Tracker!',
                style: AppTextStyles.bodyText1,
              ),
              const SizedBox(height: 8),
              Text(
                expiryText,
                style: AppTextStyles.subtitle2.copyWith(
                  color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Go to manage subscription
                  Get.toNamed(Routes.SUBSCRIPTION);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: subscriptionType == SubscriptionType.premium
                      ? AppColors.premiumSubscription
                      : AppColors.proSubscription,
                ),
                child: const Text('Manage Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightStats() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 500)), SlideEffect(delay: Duration(milliseconds: 500))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flight Stats', style: AppTextStyles.headline5),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'On-Time Rating',
                  value: '82%',
                  icon: Icons.timelapse,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Delay Prediction',
                  value: 'Low',
                  icon: Icons.assessment,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: AppTextStyles.headline4.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.subtitle2.copyWith(
                color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
