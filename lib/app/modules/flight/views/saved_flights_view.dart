import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../controllers/flight_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/flight_card.dart';
import '../../../widgets/loading_widget.dart';

class SavedFlightsView extends StatelessWidget {
  final FlightController _flightController = Get.find<FlightController>();

  SavedFlightsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load saved flights when the page is opened
    _flightController.loadSavedFlights();

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Flights', style: AppTextStyles.headline6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _flightController.loadSavedFlights,
          ),
        ],
      ),
      body: Obx(() {
        if (_flightController.isLoading) {
          return const LoadingWidget();
        }

        if (_flightController.savedFlights.isEmpty) {
          return _buildEmptyState();
        }

        return _buildSavedFlightsList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Animate(
        effects: const [FadeEffect(), SlideEffect()],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Flights',
              style: AppTextStyles.headline5,
            ),
            const SizedBox(height: 16),
            Text(
              'Your saved flights will appear here',
              style: AppTextStyles.subtitle1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.FLIGHT_SEARCH),
              icon: const Icon(Icons.search),
              label: Text('Search Flights', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedFlightsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flightController.savedFlights.length,
      itemBuilder: (context, index) {
        final flight = _flightController.savedFlights[index];
        return Animate(
          effects: [
            FadeEffect(delay: Duration(milliseconds: 100 * index)),
            SlideEffect(delay: Duration(milliseconds: 100 * index)),
          ],
          child: Dismissible(
            key: Key('flight_${flight.flightNumber}'),
            background: Container(
              color: AppColors.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _flightController.toggleFavoriteFlight(flight);
            },
            confirmDismiss: (direction) async {
              return await showDialog(
                context: Get.context!,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remove Flight', style: AppTextStyles.headline5),
                    content: Text(
                      'Are you sure you want to remove this flight from your saved list?',
                      style: AppTextStyles.bodyText2,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        child: Text('Remove', style: AppTextStyles.button),
                      ),
                    ],
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FlightCard(
                flight: flight,
                onTap: () {
                  _flightController.setSelectedFlight(flight);
                  Get.toNamed(
                    Routes.FLIGHT_DETAIL,
                    arguments: {'flightNumber': flight.flightNumber},
                  );
                },
                showFavoriteIcon: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
