import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/flight_controller.dart';
import '../../../data/models/flight_model.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class FlightDetailView extends StatefulWidget {
  const FlightDetailView({Key? key}) : super(key: key);

  @override
  State<FlightDetailView> createState() => _FlightDetailViewState();
}

class _FlightDetailViewState extends State<FlightDetailView> {
  final FlightController _flightController = Get.find<FlightController>();
  // final NotificationController _notificationController = Get.find<NotificationController>();
  // final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();

  String? flightNumber;
  // final RxBool _isNotificationEnabled = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _initData() {
    if (Get.arguments != null && Get.arguments['flightNumber'] != null) {
      flightNumber = Get.arguments['flightNumber'];
      _flightController.getFlightByNumber(flightNumber!);
    } else if (_flightController.selectedFlight != null) {
      flightNumber = _flightController.selectedFlight!.flightNumber;
    } else {
      // Navigate back if no flight is selected
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Details', style: AppTextStyles.headline6),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFlightData,
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                _flightController.selectedFlight?.isFavorite == true ? Icons.favorite : Icons.favorite_border,
              ),
              color: _flightController.selectedFlight?.isFavorite == true ? AppColors.accent : null,
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: Obx(
        () => _flightController.isLoading
            ? const LoadingWidget()
            : _flightController.selectedFlight == null
                ? _buildNoFlightSelected()
                : _buildFlightDetails(_flightController.selectedFlight!),
      ),
    );
  }

  Widget _buildNoFlightSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff,
            size: 80,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'No Flight Selected',
            style: AppTextStyles.headline5,
          ),
          const SizedBox(height: 16),
          Text(
            'Please search for a flight or select one from your saved flights',
            style: AppTextStyles.subtitle1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Search Flights',
            onPressed: () => Get.offNamed(Routes.FLIGHT_SEARCH),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetails(Flight flight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFlightHeader(flight),
          const SizedBox(height: 24),
          _buildFlightStatusCard(flight),
          const SizedBox(height: 24),
          _buildDepartureArrivalCard(flight),
          const SizedBox(height: 24),
          _buildFlightProgressCard(flight),
          const SizedBox(height: 24),
          _buildFlightDetailsCard(flight),
          // const SizedBox(height: 24),
          // _buildNotificationSection(flight),
          const SizedBox(height: 24),
          _buildActionButtons(flight),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFlightHeader(Flight flight) {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    flight.airline,
                    style: AppTextStyles.headline5,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    flight.flightNumber,
                    style: AppTextStyles.flightNumber,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(flight.departureTime),
                style: AppTextStyles.subtitle1.copyWith(
                  color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightStatusCard(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 200)), SlideEffect(delay: Duration(milliseconds: 200))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flight Status', style: AppTextStyles.headline6),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getFlightStatusColor(flight.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flight.status.toUpperCase(),
                      style: AppTextStyles.flightStatus.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (flight.isDelayed())
                    Text(
                      'Delayed by ${flight.delayMinutes!.toInt()} min',
                      style: AppTextStyles.subtitle1.copyWith(color: AppColors.warning),
                    ),
                  if (flight.isCancelled)
                    Text(
                      'Flight Cancelled',
                      style: AppTextStyles.subtitle1.copyWith(color: AppColors.error),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartureArrivalCard(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 400)), SlideEffect(delay: Duration(milliseconds: 400))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Departure', style: AppTextStyles.subtitle2),
                        const SizedBox(height: 8),
                        Text(
                          flight.departureAirport,
                          style: AppTextStyles.airportCode,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.departureCity,
                          style: AppTextStyles.airportName,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('h:mm a').format(flight.departureTime),
                          style: AppTextStyles.flightTime,
                        ),
                        if (flight.departureTerminal.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Terminal ${flight.departureTerminal}',
                            style: AppTextStyles.flightInfo,
                          ),
                        ],
                        if (flight.departureGate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gate ${flight.departureGate}',
                            style: AppTextStyles.flightInfo,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.flight_takeoff,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatDuration(flight.duration),
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${flight.distanceKm} km',
                        style: AppTextStyles.subtitle2,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Arrival', style: AppTextStyles.subtitle2),
                        const SizedBox(height: 8),
                        Text(
                          flight.arrivalAirport,
                          style: AppTextStyles.airportCode,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.arrivalCity,
                          style: AppTextStyles.airportName,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('h:mm a').format(flight.arrivalTime),
                          style: AppTextStyles.flightTime,
                        ),
                        if (flight.arrivalTerminal.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Terminal ${flight.arrivalTerminal}',
                            style: AppTextStyles.flightInfo,
                          ),
                        ],
                        if (flight.arrivalGate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gate ${flight.arrivalGate}',
                            style: AppTextStyles.flightInfo,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightProgressCard(Flight flight) {
    final progress = flight.getProgressPercentage();

    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 600)), SlideEffect(delay: Duration(milliseconds: 600))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flight Progress', style: AppTextStyles.headline6),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightDivider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flight.departureAirport, style: AppTextStyles.subtitle2),
                      Text(DateFormat('h:mm a').format(flight.departureTime), style: AppTextStyles.bodyText2),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(flight.arrivalAirport, style: AppTextStyles.subtitle2),
                      Text(DateFormat('h:mm a').format(flight.arrivalTime), style: AppTextStyles.bodyText2),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFlightStatusText(flight, progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightStatusText(Flight flight, double progress) {
    if (flight.isCancelled) {
      return Text(
        'Flight Cancelled',
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.error),
      );
    }

    if (progress >= 1.0) {
      return Text(
        'Flight Arrived',
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.success),
      );
    }

    if (progress > 0) {
      final now = DateTime.now();
      final remaining = flight.arrivalTime.difference(now);
      return Text(
        'In Flight - Arrives in ${formatDuration(remaining)}',
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
      );
    }

    final now = DateTime.now();
    final untilDeparture = flight.departureTime.difference(now);
    if (untilDeparture.isNegative) {
      return Text(
        'Departed',
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.info),
      );
    }

    return Text(
      'Departs in ${formatDuration(untilDeparture)}',
      style: AppTextStyles.subtitle1,
    );
  }

  Widget _buildFlightDetailsCard(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 800)), SlideEffect(delay: Duration(milliseconds: 800))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flight Details', style: AppTextStyles.headline6),
              const SizedBox(height: 16),
              _buildDetailItem('Airline', flight.airline),
              _buildDetailItem('Flight Number', flight.flightNumber),
              _buildDetailItem('Aircraft', flight.aircraft),
              _buildDetailItem('Distance', '${flight.distanceKm} km'),
              _buildDetailItem('Flight Duration', formatDuration(flight.duration)),
              if (flight.isDelayed())
                _buildDetailItem(
                  'Delay',
                  '${flight.delayMinutes!.toInt()} minutes',
                  valueColor: AppColors.warning,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle2.copyWith(
              color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.subtitle1.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

//   Widget _buildNotificationSection(Flight flight) {
//   final isPremium = _subscriptionController.currentSubscription != SubscriptionType.free;

//   return Animate(
//     effects: const [FadeEffect(delay: Duration(milliseconds: 1000)), SlideEffect(delay: Duration(milliseconds: 1000))],
//     child: Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Notifications', style: AppTextStyles.headline6),
//             const SizedBox(height: 16),
//             Obx(() => Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     isPremium
//                         ? 'Get updates about this flight'
//                         : 'Get updates about this flight (Premium feature)',
//                     style: AppTextStyles.bodyText2,
//                   ),
//                 ),
//                 Switch(
//                   value: _isNotificationEnabled.value,
//                   onChanged: isPremium
//                       ? (value) {
//                           _isNotificationEnabled.value = value;
//                           // _toggleNotifications(flight, value);
//                         }
//                       : (value) {
//                           Get.toNamed(Routes.SUBSCRIPTION);
//                         },
//                   activeColor: AppColors.primary,
//                 ),
//               ],
//             )),
//             Obx(() {
//               if (_isNotificationEnabled.value && isPremium) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 16),
//                     Text('Notification Settings', style: AppTextStyles.subtitle1),
//                     const SizedBox(height: 8),
//                     _buildNotificationOption(
//                       'Before Departure',
//                       true,
//                       (value) {},
//                     ),
//                     _buildNotificationOption(
//                       'Gate Changes',
//                       true,
//                       (value) {},
//                     ),
//                     _buildNotificationOption(
//                       'Delays',
//                       true,
//                       (value) {},
//                     ),
//                     _buildNotificationOption(
//                       'Take Off & Landing',
//                       true,
//                       (value) {},
//                     ),
//                   ],
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             }),
//           ],
//         ),
//       ),
//     ),
//   );
// }

//   Widget _buildNotificationOption(String title, bool value, Function(bool) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: AppTextStyles.bodyText2),
//           Switch(
//             value: value,
//             onChanged: onChanged,
//             activeColor: AppColors.primary,
//           ),
//         ],
//       ),
//     );
//   }

  Widget _buildActionButtons(Flight flight) {
    return Animate(
      effects: const [
        FadeEffect(delay: Duration(milliseconds: 1200)),
        SlideEffect(delay: Duration(milliseconds: 1200))
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: _shareFlight,
          ),
          _buildActionButton(
            icon: Icons.map,
            label: 'Map',
            onTap: () => Get.toNamed(
              Routes.FLIGHT_MAP,
              arguments: {'flight': flight},
            ),
          ),
          _buildActionButton(
            icon: flight.isFavorite ? Icons.favorite : Icons.favorite_border,
            label: flight.isFavorite ? 'Saved' : 'Save',
            onTap: _toggleFavorite,
            isHighlighted: flight.isFavorite,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? AppColors.primary : AppColors.lightDivider,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isHighlighted ? AppColors.primary : null,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isHighlighted ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshFlightData() {
    if (flightNumber != null) {
      _flightController.refreshFlightInfo(flightNumber!);
    }
  }

  void _toggleFavorite() {
    if (_flightController.selectedFlight != null) {
      _flightController.toggleFavoriteFlight(_flightController.selectedFlight!);
    }
  }

  void _shareFlight() {
    // This would implement share functionality
    if (_flightController.selectedFlight != null) {
      final flight = _flightController.selectedFlight!;
      final shareText =
          'Track ${flight.airline} flight ${flight.flightNumber} from ${flight.departureAirport} to ${flight.arrivalAirport} on Flight Tracker.';

      Get.snackbar(
        'Share Flight',
        'Sharing: $shareText',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // void _toggleNotifications(Flight flight, bool enabled) {
  //   if (enabled) {
  //     _notificationController.subscribeToFlight(flight.flightNumber);
  //     _notificationController.scheduleFlightNotification(
  //       flight,
  //       const Duration(hours: 2),
  //     );
  //   } else {
  //     _notificationController.unsubscribeFromFlight(flight.flightNumber);
  //     _notificationController.cancelFlightNotification(flight.flightNumber);
  //   }
  // }
}
