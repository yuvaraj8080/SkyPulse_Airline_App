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
import '../../../widgets/flight_card.dart';

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
    final AuthController authController = Get.find<AuthController>();
    final FlightController flightController = Get.find<FlightController>();
    final SubscriptionController subscriptionController = Get.find<SubscriptionController>();

    // Load saved flights when home tab is shown
    flightController.loadSavedFlights();

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
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.flight, color: AppColors.primary),
            ),
            SizedBox(width: 8),
            Text('SkyPulse', style: AppTextStyles.headline6),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => flightController.loadSavedFlights(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Flights',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(authController),
              const SizedBox(height: 20),
              _buildUpcomingFlightsSection(flightController),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Quick Actions',
                  style: AppTextStyles.headline5,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionGrid(),
              const SizedBox(height: 24),
              if (subscriptionController.currentSubscription == SubscriptionType.free)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSubscriptionCard(subscriptionController),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(AuthController authController) {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withBlue(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    radius: 24,
                    child: Text(
                      authController.user?.fullName?.isNotEmpty == true
                          ? authController.user!.fullName![0].toUpperCase()
                          : 'T',
                      style: AppTextStyles.headline5.copyWith(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: AppTextStyles.subtitle2.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${authController.user?.fullName ?? 'Traveler'}',
                        style: AppTextStyles.headline5.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Where are you flying today?',
              style: AppTextStyles.subtitle1.copyWith(color: Colors.white.withOpacity(0.9)),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed(Routes.FLIGHT_SEARCH);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Track a Flight'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingFlightsSection(FlightController flightController) {
    return Obx(() {
      if (flightController.isLoading) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Your Flights', style: AppTextStyles.headline5),
                  ],
                ),
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
          ),
          const SizedBox(height: 12),
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
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flight,
                  size: 36,
                  color: AppColors.primary,
                ),
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
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Get.toNamed(Routes.FLIGHT_SEARCH);
                },
                icon: Icon(Icons.search),
                label: Text('Search Flights'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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

    // If we have no flights at this point, try loading them again
    if (displayFlights.isEmpty) {
      flightController.loadSavedFlights();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayFlights.length,
      itemBuilder: (context, index) {
        return Animate(
          effects: [
            FadeEffect(delay: Duration(milliseconds: 300 + (index * 100))),
            SlideEffect(delay: Duration(milliseconds: 300 + (index * 100))),
          ],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FlightCard(
              flight: displayFlights[index],
              onTap: () {
                flightController.setSelectedFlight(displayFlights[index]);
                Get.toNamed(
                  Routes.FLIGHT_DETAIL,
                  arguments: {'flightNumber': displayFlights[index].flightNumber},
                );
              },
              showFavoriteIcon: true,
              isDetailed: true, // Set to true to show more details
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionGrid() {
    final actions = [
      {
        'icon': Icons.flight_takeoff,
        'color': AppColors.primary,
        'title': 'Flight Number',
        'route': Routes.FLIGHT_SEARCH,
      },
      {
        'icon': Icons.location_on_outlined,
        'color': AppColors.info,
        'title': 'Airport Routes',
        'route': Routes.FLIGHT_SEARCH,
      },
      {
        'icon': Icons.calendar_today,
        'color': AppColors.success,
        'title': 'Flight Date',
        'route': Routes.FLIGHT_SEARCH,
      },
      {
        'icon': Icons.favorite_border,
        'color': AppColors.accent,
        'title': 'Saved Flights',
        'route': Routes.SAVED_FLIGHTS,
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return Animate(
          effects: [
            FadeEffect(delay: Duration(milliseconds: 200 + (index * 100))),
            SlideEffect(delay: Duration(milliseconds: 200 + (index * 100))),
          ],
          child: _buildQuickActionCard(
            icon: actions[index]['icon'] as IconData,
            color: actions[index]['color'] as Color,
            title: actions[index]['title'] as String,
            onTap: () => Get.toNamed(actions[index]['route'] as String),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionController subscriptionController) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 400)), SlideEffect(delay: Duration(milliseconds: 400))],
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accent.withRed(230)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Upgrade to Premium',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Get early delay notifications, detailed flight predictions, and more!',
                style: AppTextStyles.bodyText2.copyWith(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.SUBSCRIPTION);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Upgrade Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
