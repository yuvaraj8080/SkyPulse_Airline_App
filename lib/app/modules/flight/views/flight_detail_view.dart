import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../controllers/flight_controller.dart';
import '../../../data/models/flight_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class FlightDetailView extends StatefulWidget {
  const FlightDetailView({super.key});

  @override
  State<FlightDetailView> createState() => _FlightDetailViewState();
}

class _FlightDetailViewState extends State<FlightDetailView> {
  final FlightController _flightController = Get.find<FlightController>();
  String? flightNumber;

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
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    // Implementation of _buildNoFlightSelected method
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildFlightDetails(Flight flight) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(flight),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlightHeader(flight),
                SizedBox(height: 16),
                _buildFlightStatusCard(flight),
                SizedBox(height: 16),
                _buildMapPreview(flight),
                SizedBox(height: 16),
                _buildAircraftDetails(flight),
                SizedBox(height: 16),
                _buildWeatherWidget(flight),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Flight flight) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Get.isDarkMode ? AppColors.darkBackground : AppColors.primary,
      title: Text(
        '${flight.airlineName} ${flight.flightNumber}',
        style: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Get.isDarkMode ? Colors.white : Colors.white),
          onPressed: () {
            Share.share(
              'Check out ${flight.airlineName} ${flight.flightNumber} flight from ${flight.departureCity} to ${flight.arrivalCity}!',
            );
          },
        ),
      ],
    );
  }

  Widget _buildFlightHeader(Flight flight) {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.black12 : Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withBlue(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/airline_logos/${flight.airline.toLowerCase()}.png',
                            width: 28,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  flight.airline.isNotEmpty ? flight.airline[0] : "?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.airlineName,
                              style: AppTextStyles.headline6.copyWith(color: Colors.white),
                            ),
                            Text(
                              flight.flightNumber,
                              style: AppTextStyles.subtitle2.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (flight.status.toLowerCase() != 'unknown')
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(flight).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(flight.status),
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                flight.status.toUpperCase(),
                                style: AppTextStyles.flightStatus.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.departureAirport,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          Text(
                            flight.departureCity,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Icon(
                              Icons.flight,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            flight.arrivalAirport,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          Text(
                            flight.arrivalCity,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEPARTS',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            flight.scheduledDeparture != null
                                ? DateFormat('h:mm a').format(flight.scheduledDeparture!)
                                : '--:--',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'DURATION',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              flight.flightDuration != null
                                  ? formatDuration(Duration(minutes: flight.flightDuration!))
                                  : '--:--',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ARRIVES',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            flight.scheduledArrival != null
                                ? DateFormat('h:mm a').format(flight.scheduledArrival!)
                                : '--:--',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.flight;
      case 'scheduled':
        return Icons.schedule;
      case 'delayed':
        return Icons.timer;
      case 'cancelled':
        return Icons.cancel;
      case 'landed':
      case 'arrived':
        return Icons.flight_land;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildWeatherWidget(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 500)), SlideEffect(delay: Duration(milliseconds: 500))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Weather', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: 170,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCityWeather(
                          city: flight.departureCity, temp: '24°C', condition: 'Sunny', humidity: '65%'),
                    ),
                    Container(
                      height: 100,
                      width: 1,
                      color: AppColors.lightDivider,
                    ),
                    Expanded(
                      child: _buildCityWeather(
                          city: flight.arrivalCity, temp: '18°C', condition: 'Cloudy', humidity: '72%'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityWeather({
    required String city,
    required String temp,
    required String condition,
    required String humidity,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            city,
            style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                condition.toLowerCase().contains('sun')
                    ? Icons.wb_sunny
                    : condition.toLowerCase().contains('cloud')
                        ? Icons.cloud
                        : condition.toLowerCase().contains('rain')
                            ? Icons.water_drop
                            : Icons.wb_cloudy,
                color: condition.toLowerCase().contains('sun')
                    ? Colors.orange
                    : condition.toLowerCase().contains('cloud')
                        ? Colors.grey
                        : condition.toLowerCase().contains('rain')
                            ? Colors.blue
                            : Colors.grey,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                temp,
                style: AppTextStyles.headline5,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            condition,
            style: AppTextStyles.bodyText2,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherDetail(Icons.water_drop, humidity),
              SizedBox(width: 16),
              _buildWeatherDetail(Icons.air, '10 km/h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.lightTextSecondary,
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildMapPreview(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 600)), SlideEffect(delay: Duration(milliseconds: 600))],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Row(
                children: [
                  Icon(Icons.map, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Flight Route', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Map background with subtle grid pattern
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: MapBackgroundPainter(),
                          ),
                        ),
                      ),

                      // Flight route visualization
                      Positioned.fill(
                        child: CustomPaint(
                          painter: FlightRoutePainter(
                            departureCode: flight.departureAirport,
                            arrivalCode: flight.arrivalAirport,
                            progress: _calculateProgress(flight),
                          ),
                        ),
                      ),

                      // Distance label in bottom right corner
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            flight.distance != null
                                ? '${flight.distance!.toStringAsFixed(0)} km'
                                : 'Distance unavailable',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Airport labels with dots
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  flight.departureAirport,
                                  style: TextStyle(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        right: 16,
                        top: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  flight.arrivalAirport,
                                  style: TextStyle(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildLocationInfo(
                      flight.departureAirport,
                      flight.departureCity,
                      flight.terminal ?? 'TBD',
                      flight.gate ?? 'TBD',
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  Container(
                    height: 80,
                    width: 1,
                    color: AppColors.lightDivider,
                  ),
                  Expanded(
                    child: _buildLocationInfo(
                      flight.arrivalAirport,
                      flight.arrivalCity,
                      flight.terminal ?? 'TBD',
                      flight.gate ?? 'TBD',
                      crossAxisAlignment: CrossAxisAlignment.end,
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

  Widget _buildLocationInfo(String airportCode, String city, String terminal, String gate,
      {required CrossAxisAlignment crossAxisAlignment}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            airportCode,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            city,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
            textAlign: crossAxisAlignment == CrossAxisAlignment.start ? TextAlign.left : TextAlign.right,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment:
                crossAxisAlignment == CrossAxisAlignment.start ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (crossAxisAlignment == CrossAxisAlignment.end)
                Text(
                  'T$terminal · G$gate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              if (crossAxisAlignment == CrossAxisAlignment.end) SizedBox(width: 4),
              if (crossAxisAlignment == CrossAxisAlignment.end)
                Icon(Icons.info_outline, size: 12, color: AppColors.primary),
              if (crossAxisAlignment == CrossAxisAlignment.start)
                Icon(Icons.info_outline, size: 12, color: AppColors.primary),
              if (crossAxisAlignment == CrossAxisAlignment.start) SizedBox(width: 4),
              if (crossAxisAlignment == CrossAxisAlignment.start)
                Text(
                  'T$terminal · G$gate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateProgress(Flight flight) {
    if (flight.status.toLowerCase() == 'cancelled') {
      return 0.0;
    }

    final now = DateTime.now();
    final departure = flight.actualDeparture ?? flight.scheduledDeparture;
    final arrival = flight.actualArrival ?? flight.scheduledArrival;

    if (departure == null || arrival == null) {
      return 0.0;
    }

    if (now.isBefore(departure)) {
      return 0.0;
    }

    if (now.isAfter(arrival)) {
      return 1.0;
    }

    final totalDuration = arrival.difference(departure).inMinutes;
    final elapsedDuration = now.difference(departure).inMinutes;

    return totalDuration > 0 ? min(1.0, max(0.0, elapsedDuration / totalDuration)) : 0.0;
  }

  Widget _buildFlightStatusCard(Flight flight) {
    final progress = _calculateProgress(flight);
    String statusDescription = '';
    IconData statusIcon = Icons.info_outline;
    Color statusColor = AppColors.primary;

    if (flight.isCancelled) {
      statusDescription = 'This flight has been cancelled';
      statusIcon = Icons.cancel_outlined;
      statusColor = AppColors.error;
    } else if (flight.isDelayed()) {
      statusDescription = 'Delayed by ${flight.departureDelayMinutes} minutes';
      statusIcon = Icons.timer;
      statusColor = AppColors.warning;
    } else if (progress >= 1.0) {
      statusDescription = 'Flight has arrived at destination';
      statusIcon = Icons.flight_land;
      statusColor = AppColors.success;
    } else if (progress > 0) {
      statusDescription = 'Flight is currently in the air';
      statusIcon = Icons.flight;
      statusColor = AppColors.primary;
    } else {
      final now = DateTime.now();
      final departure = flight.scheduledDeparture ?? now;
      final untilDeparture = departure.difference(now);

      if (untilDeparture.inHours >= 24) {
        statusDescription = 'Scheduled for ${DateFormat('E, MMM d').format(departure)}';
        statusIcon = Icons.calendar_today;
      } else if (untilDeparture.inHours >= 2) {
        statusDescription = 'Departing in ${untilDeparture.inHours} hours';
        statusIcon = Icons.schedule;
      } else if (untilDeparture.inMinutes > 0) {
        statusDescription = 'Departing in ${untilDeparture.inMinutes} minutes';
        statusIcon = Icons.schedule;
      } else {
        statusDescription = 'Preparing for departure';
        statusIcon = Icons.flight_takeoff;
      }
    }

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
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Flight Status', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            flight.status.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusDescription,
                          style: AppTextStyles.bodyText1,
                        ),
                        if (flight.isDelayed()) ...[
                          const SizedBox(height: 8),
                          Text(
                            'New departure time: ${flight.actualDeparture != null ? DateFormat('h:mm a').format(flight.actualDeparture!) : 'TBD'}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Flight progress timeline
              if (!flight.isCancelled) ...[
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLIGHT PROGRESS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.lightTextSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: [
                          // Timeline bar
                          Container(
                            height: 4,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.lightDivider,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Progress
                          Positioned(
                            left: 0,
                            width: MediaQuery.of(Get.context!).size.width * 0.8 * progress,
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Departure dot
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: progress > 0 ? AppColors.primary : AppColors.lightDivider,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Current time marker
                          if (progress > 0 && progress < 1.0)
                            Positioned(
                              left: MediaQuery.of(Get.context!).size.width * 0.8 * progress - 6,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Arrival dot
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: progress >= 1.0 ? AppColors.primary : AppColors.lightDivider,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEPARTED',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              flight.scheduledDeparture != null
                                  ? DateFormat('h:mm a').format(flight.scheduledDeparture!)
                                  : '--:--',
                              style: AppTextStyles.subtitle2,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ARRIVING',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              flight.scheduledArrival != null
                                  ? DateFormat('h:mm a').format(flight.scheduledArrival!)
                                  : '--:--',
                              style: AppTextStyles.subtitle2,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnTimeRatingCard(Flight flight) {
    final rating = flight.onTimePercentage ?? 0;
    final ratingColor = rating > 80
        ? AppColors.success
        : rating > 60
            ? AppColors.warning
            : AppColors.error;

    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 300)), SlideEffect(delay: Duration(milliseconds: 300))],
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
              Text('On-Time Performance', style: AppTextStyles.headline6),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This flight has a ${rating.toStringAsFixed(0)}% on-time arrival rate',
                          style: AppTextStyles.bodyText1,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: rating / 100,
                          backgroundColor: ratingColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ratingColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: ratingColor),
                    ),
                    child: Text(
                      '${rating.toStringAsFixed(0)}%',
                      style: AppTextStyles.headline5.copyWith(color: ratingColor),
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
                          flight.scheduledDeparture != null
                              ? DateFormat('h:mm a').format(flight.scheduledDeparture!)
                              : '--:--',
                          style: AppTextStyles.flightTime,
                        ),
                        if (flight.terminal != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Terminal ${flight.terminal}',
                            style: AppTextStyles.flightInfo,
                          ),
                        ],
                        if (flight.gate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gate ${flight.gate}',
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
                        flight.flightDuration != null
                            ? formatDuration(Duration(minutes: flight.flightDuration!))
                            : '--:--',
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.distance != null ? '${flight.distance} km' : '-- km',
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
                          flight.scheduledArrival != null
                              ? DateFormat('h:mm a').format(flight.scheduledArrival!)
                              : '--:--',
                          style: AppTextStyles.flightTime,
                        ),
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
    final progress = _calculateProgress(flight);

    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 700)), SlideEffect(delay: Duration(milliseconds: 700))],
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
                      Text(
                        flight.scheduledDeparture != null
                            ? DateFormat('h:mm a').format(flight.scheduledDeparture!)
                            : '--:--',
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(flight.arrivalAirport, style: AppTextStyles.subtitle2),
                      Text(
                        flight.scheduledArrival != null
                            ? DateFormat('h:mm a').format(flight.scheduledArrival!)
                            : '--:--',
                        style: AppTextStyles.bodyText2,
                      ),
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
      final arrival = flight.scheduledArrival ?? now.add(Duration(hours: 1));
      final remaining = arrival.difference(now);
      return Text(
        'In Flight - Arrives in ${formatDuration(remaining)}',
        style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary),
      );
    }

    final now = DateTime.now();
    final departure = flight.scheduledDeparture ?? now;
    final untilDeparture = departure.difference(now);
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
      effects: const [FadeEffect(), SlideEffect()],
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
              Text('Flight Information', style: AppTextStyles.headline6),
              const SizedBox(height: 16),
              _buildInfoRow('Flight', flight.flightNumber),
              const SizedBox(height: 8),
              _buildInfoRow('Aircraft', flight.aircraftType ?? 'Not available'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Distance', flight.distance != null ? '${flight.distance!.toStringAsFixed(0)} km' : 'Not available'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  'Duration',
                  flight.flightDuration != null
                      ? formatDuration(Duration(minutes: flight.flightDuration!))
                      : 'Not available'),
              const SizedBox(height: 8),
              _buildInfoRow('Terminal', flight.terminal ?? 'Not available'),
              const SizedBox(height: 8),
              _buildInfoRow('Gate', flight.gate ?? 'Not available'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _showTerminalMap(flight);
                },
                icon: Icon(Icons.map_outlined),
                label: Text('View Terminal Map'),
                style: OutlinedButton.styleFrom(
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

  void _showTerminalMap(Flight flight) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terminal ${flight.terminal ?? "Map"}',
                    style: AppTextStyles.headline6,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: AppColors.lightDivider.withOpacity(0.5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    size: 48,
                                    color: AppColors.primary.withOpacity(0.5),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Terminal Map',
                                    style: AppTextStyles.subtitle1,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Map loading...',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terminal Facilities',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildFacilityItem(Icons.restaurant, 'Restaurants', '5 near gate ${flight.gate ?? ""}'),
                          _buildFacilityItem(Icons.shopping_bag, 'Duty Free Shops', '3 stores available'),
                          _buildFacilityItem(Icons.wc, 'Restrooms', 'Near gates A3, B2, C1'),
                          _buildFacilityItem(Icons.wifi, 'Free Wi-Fi', 'Available throughout terminal'),
                          _buildFacilityItem(Icons.charging_station, 'Charging Stations', 'Available at seating areas'),
                          SizedBox(height: 16),
                          Text(
                            'Walking Distances',
                            style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDistanceItem('Security to Gate ${flight.gate ?? ""}', '8 min'),
                          _buildDistanceItem('Immigration to Gate ${flight.gate ?? ""}', '12 min'),
                          _buildDistanceItem('Nearest Restroom', '2 min'),
                          _buildDistanceItem('Nearest Restaurant', '3 min'),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFacilityItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle2,
              ),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceItem(String destination, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.directions_walk,
            size: 16,
            color: AppColors.primary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              destination,
              style: AppTextStyles.caption,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfoCard() {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 700)), SlideEffect(delay: Duration(milliseconds: 700))],
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
              Row(
                children: [
                  Icon(Icons.person, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Passenger Information', style: AppTextStyles.headline6),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: AppColors.lightDivider,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: AppTextStyles.subtitle1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Booking Reference: ABC123',
                                style: AppTextStyles.caption,
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Business Class',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPassengerInfoItem(Icons.chair, 'Seat', '12A'),
                        _buildPassengerInfoItem(Icons.luggage, 'Baggage', '2 x 23kg'),
                        _buildPassengerInfoItem(Icons.group, 'Group', 'Priority'),
                      ],
                    ),
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.upgrade),
                      label: Text('Upgrade Seat'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.lightTextSecondary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeRoutesCard(Flight flight) {
    return Animate(
      effects: const [FadeEffect(delay: Duration(milliseconds: 900)), SlideEffect(delay: Duration(milliseconds: 900))],
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
              Row(
                children: [
                  const Icon(Icons.alt_route, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Alternative Routes', style: AppTextStyles.headline6),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: flight.alternativeRoutes
                    .take(3) // Show only top 3 alternatives
                    .map((route) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${route.departureAirport} → ${route.arrivalAirport}',
                                  style: AppTextStyles.bodyText1,
                                ),
                              ),
                              if (route.reliability != null)
                                Text(
                                  '${route.reliability!.toStringAsFixed(0)}% reliable',
                                  style: AppTextStyles.caption,
                                ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDelayHistoryCard(Flight flight) {
    return Animate(
      effects: const [
        FadeEffect(delay: Duration(milliseconds: 1000)),
        SlideEffect(delay: Duration(milliseconds: 1000))
      ],
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
              Row(
                children: [
                  const Icon(Icons.history, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Delay History', style: AppTextStyles.headline6),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: flight.delayHistory
                    .take(3) // Show only top 3 delay records
                    .map((delay) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('MMM d').format(delay.date),
                                      style: AppTextStyles.bodyText1,
                                    ),
                                    Text(
                                      delay.reason,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Departure: ${delay.departureDelay} min',
                                    style: AppTextStyles.bodyText1,
                                  ),
                                  Text(
                                    'Arrival: ${delay.arrivalDelay} min',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Flight flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Animate(
          effects: const [
            FadeEffect(delay: Duration(milliseconds: 800)),
            SlideEffect(delay: Duration(milliseconds: 800))
          ],
          child: OutlinedButton.icon(
            onPressed: () => _showBoardingPass(flight),
            icon: Icon(Icons.confirmation_number),
            label: Text('View Boarding Pass'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Animate(
          effects: const [
            FadeEffect(delay: Duration(milliseconds: 800)),
            SlideEffect(delay: Duration(milliseconds: 800))
          ],
          child: CustomButton(
            text: 'Share Flight Details',
            onPressed: () {
              // shareFlightDetails(flight);
            },
            icon: Icons.share,
          ),
        ),
        const SizedBox(height: 16),
        if (flight.status.toLowerCase() != 'cancelled')
          Animate(
            effects: const [
              FadeEffect(delay: Duration(milliseconds: 900)),
              SlideEffect(delay: Duration(milliseconds: 900))
            ],
            child: CustomButton(
              text: 'Set Notification',
              onPressed: () {
                // _setFlightNotification(flight);
              },
              icon: Icons.notifications,
              buttonType: ButtonType.outlined,
            ),
          ),
      ],
    );
  }

  void _showBoardingPass(Flight flight) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Boarding Pass',
                    style: AppTextStyles.headline6,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _buildBoardingPassContent(flight),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBoardingPassContent(Flight flight) {
    // Calculate boarding time (usually 30-45 minutes before departure)
    final boardingTime =
        flight.scheduledDeparture != null ? flight.scheduledDeparture!.subtract(Duration(minutes: 40)) : DateTime.now();

    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOARDING PASS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/airline_logos/${flight.airline.toLowerCase()}.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          flight.airline.isNotEmpty ? flight.airline[0] : "?",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    flight.airlineName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            flight.flightNumber,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flight.departureAirport,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            Text(
                              flight.departureCity,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.flight,
                              color: Colors.white.withOpacity(0.8),
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                flight.flightDuration != null ? '${flight.flightDuration}m' : 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              flight.arrivalAirport,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            Text(
                              flight.arrivalCity,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildTearLine(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildPassengerBoardingItem(
                          'PASSENGER',
                          'John Doe',
                          alignment: CrossAxisAlignment.start,
                        ),
                        _buildPassengerBoardingItem(
                          'CLASS',
                          'Business',
                          alignment: CrossAxisAlignment.center,
                        ),
                        _buildPassengerBoardingItem(
                          'SEAT',
                          '12A',
                          alignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _buildPassengerBoardingItem(
                          'DATE',
                          flight.scheduledDeparture != null
                              ? DateFormat('dd MMM yyyy').format(flight.scheduledDeparture!)
                              : 'N/A',
                          alignment: CrossAxisAlignment.start,
                        ),
                        _buildPassengerBoardingItem(
                          'BOARDING TIME',
                          DateFormat('HH:mm').format(boardingTime),
                          alignment: CrossAxisAlignment.center,
                        ),
                        _buildPassengerBoardingItem(
                          'GATE',
                          flight.gate ?? 'TBD',
                          alignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _buildPassengerBoardingItem(
                          'DEPARTURE',
                          flight.scheduledDeparture != null
                              ? DateFormat('HH:mm').format(flight.scheduledDeparture!)
                              : 'N/A',
                          alignment: CrossAxisAlignment.start,
                        ),
                        _buildPassengerBoardingItem(
                          'TERMINAL',
                          flight.terminal ?? 'TBD',
                          alignment: CrossAxisAlignment.center,
                        ),
                        _buildPassengerBoardingItem(
                          'GROUP',
                          'Priority',
                          alignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.lightDivider,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.lightDivider,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.qr_code,
                                  size: 120,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Scan to board',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Text(
          'IMPORTANT INFORMATION',
          style: AppTextStyles.overline.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please arrive at the gate at least 30 minutes before departure. '
          'Gate closes 15 minutes before departure. Valid identification is required.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionIcon(Icons.download, 'Save'),
            _buildActionIcon(Icons.print, 'Print'),
            _buildActionIcon(Icons.share, 'Share'),
            _buildActionIcon(Icons.account_balance_wallet, 'Wallet'),
          ],
        ),
      ],
    );
  }

  Widget _buildTearLine() {
    return SizedBox(
      height: 30,
      child: Row(
        children: List.generate(
          50,
          (index) => Expanded(
            child: Container(
              color: index % 2 == 0 ? Colors.transparent : AppColors.lightDivider,
              height: 1,
              margin: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerBoardingItem(String label, String value, {required CrossAxisAlignment alignment}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Color _getStatusColor(Flight flight) {
    switch (flight.status.toLowerCase()) {
      case 'active':
      case 'scheduled':
        return AppColors.success;
      case 'delayed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      case 'landed':
      case 'arrived':
        return AppColors.secondary;
      default:
        return AppColors.lightDivider;
    }
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

  Widget _buildAircraftDetails(Flight flight) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.airplanemode_active, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text('Aircraft Details', style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem('Aircraft', flight.aircraftType),
                        SizedBox(height: 12),
                        _buildDetailItem('Registration', flight.aircraftRegistration),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailItem('Airline', flight.airline),
                        SizedBox(height: 12),
                        _buildDetailItem('Flight', flight.flightNumber),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: AppColors.lightDivider),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailLabel('DEPARTURE'),
                        SizedBox(height: 4),
                        _buildDateValue(flight.scheduledDeparture),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailLabel('ARRIVAL'),
                        SizedBox(height: 4),
                        _buildDateValue(flight.scheduledArrival),
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

  Widget _buildDetailLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: AppColors.secondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDateValue(DateTime? dateTime) {
    if (dateTime == null) {
      return Text(
        'Not scheduled',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      );
    }

    final formattedDate = DateFormat('HH:mm, dd MMM').format(dateTime);
    return Text(
      formattedDate,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return '${twoDigitHours}h ${twoDigitMinutes}m';
  }
}

class FlightRoutePainter extends CustomPainter {
  final String departureCode;
  final String arrivalCode;
  final double progress;

  FlightRoutePainter({
    required this.departureCode,
    required this.arrivalCode,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dashedPaint = Paint()
      ..color = AppColors.lightDivider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Offset startPoint = Offset(size.width * 0.15, size.height * 0.6);
    final Offset endPoint = Offset(size.width * 0.85, size.height * 0.4);
    final Offset midPoint = Offset(
      startPoint.dx + (endPoint.dx - startPoint.dx) * progress,
      startPoint.dy + (endPoint.dy - startPoint.dy) * progress,
    );

    // Draw completed path
    if (progress > 0) {
      final Path completedPath = Path()
        ..moveTo(startPoint.dx, startPoint.dy)
        ..quadraticBezierTo((startPoint.dx + endPoint.dx) / 2, startPoint.dy - 50, midPoint.dx, midPoint.dy);
      canvas.drawPath(completedPath, paint);
    }

    // Draw remaining path
    if (progress < 1.0) {
      final Path remainingPath = Path()
        ..moveTo(midPoint.dx, midPoint.dy)
        ..quadraticBezierTo((midPoint.dx + endPoint.dx) / 2, endPoint.dy - 50, endPoint.dx, endPoint.dy);
      canvas.drawPath(remainingPath, dashedPaint);
    }

    // Draw departure point
    _drawAirportPoint(canvas, startPoint, departureCode, size);

    // Draw arrival point
    _drawAirportPoint(canvas, endPoint, arrivalCode, size);

    // Draw airplane
    if (progress > 0 && progress < 1.0) {
      final double angle = _calculateAngle(midPoint, progress, startPoint, endPoint);
      _drawAirplane(canvas, midPoint, angle);
    }
  }

  void _drawAirportPoint(Canvas canvas, Offset point, String code, Size size) {
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, 6, pointPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: code,
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        point.dx - textPainter.width / 2,
        point.dy + 10,
      ),
    );
  }

  void _drawAirplane(Canvas canvas, Offset position, double angle) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    final planePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final Path planePath = Path()
      ..moveTo(0, -10) // nose
      ..lineTo(-5, 5) // left wing
      ..lineTo(0, 0) // body
      ..lineTo(5, 5) // right wing
      ..close();

    canvas.drawPath(planePath, planePaint);
    canvas.restore();
  }

  double _calculateAngle(Offset position, double progress, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    return math.atan2(dy, dx);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    final horizontalSpacing = size.height / 8;
    for (int i = 0; i <= 8; i++) {
      final y = i * horizontalSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    final verticalSpacing = size.width / 12;
    for (int i = 0; i <= 12; i++) {
      final x = i * verticalSpacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
