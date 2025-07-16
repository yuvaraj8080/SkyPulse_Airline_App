import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/flight_controller.dart';
import '../data/models/flight_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/helpers.dart';

class FlightCard extends StatefulWidget {
  final Flight flight;
  final VoidCallback onTap;
  final bool showFavoriteIcon;
  final bool isDetailed;

  const FlightCard({
    super.key,
    required this.flight,
    required this.onTap,
    this.showFavoriteIcon = false,
    this.isDetailed = false,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
  final FlightController _flightController = Get.find<FlightController>();
  Timer? _progressTimer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _progress = _calculateProgress();
    _startProgressTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  double _calculateProgress() {
    final now = DateTime.now();
    final departure = widget.flight.scheduledDeparture ?? now;
    final arrival = widget.flight.scheduledArrival ?? now.add(Duration(hours: 1));

    if (now.isBefore(departure)) return 0.0;
    if (now.isAfter(arrival)) return 1.0;

    final totalDuration = arrival.difference(departure).inMilliseconds;
    final elapsedDuration = now.difference(departure).inMilliseconds;

    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _progress = _calculateProgress();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFlightRoute(),
              if (widget.isDetailed) ...[
                const SizedBox(height: 16),
                _buildTimelineBar(),
                const SizedBox(height: 16),
                _buildFlightDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Airline info with logo
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/airline_logos/${widget.flight.airline.toLowerCase()}.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        widget.flight.airline.isNotEmpty ? widget.flight.airline[0] : "?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.flight.airlineName,
                      style: AppTextStyles.subtitle1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.flight.flightNumber,
                      style: AppTextStyles.flightNumber.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Status and favorite icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.flight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.flight.status.toUpperCase(),
                style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.showFavoriteIcon) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  _flightController.toggleFavoriteFlight(widget.flight);
                },
                child: Icon(
                  widget.flight.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.flight.isFavorite ? AppColors.accent : null,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFlightRoute() {
    final departureTime = widget.flight.scheduledDeparture != null
        ? DateFormat('h:mm a').format(widget.flight.scheduledDeparture!)
        : '--:--';
    final arrivalTime =
        widget.flight.scheduledArrival != null ? DateFormat('h:mm a').format(widget.flight.scheduledArrival!) : '--:--';
    final flightDate = widget.flight.scheduledDeparture != null
        ? DateFormat('EEE, MMM d').format(widget.flight.scheduledDeparture!)
        : '';

    return Column(
      children: [
        Row(
          children: [
            // Departure details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.flight.departureAirport,
                    style: AppTextStyles.airportCode.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    departureTime,
                    style: AppTextStyles.headline5,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.flight.departureCity,
                    style: AppTextStyles.airportName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Flight progress
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Flight path line
                        Container(
                          height: 2,
                          color: AppColors.lightDivider,
                        ),

                        // Progress line
                        Positioned(
                          left: 0,
                          right: null,
                          child: Container(
                            height: 2,
                            width: 100 * _progress,
                            color: AppColors.primary,
                          ),
                        ),

                        // Airplane icon
                        Transform.translate(
                          offset: Offset(100 * (_progress - 0.5), 0),
                          child: Transform.rotate(
                            angle: _progress * 0.5,
                            child: Icon(
                              Icons.flight,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.flight.flightDuration != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      formatDuration(Duration(minutes: widget.flight.flightDuration!)),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  if (flightDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      flightDate,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),

            // Arrival details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.flight.arrivalAirport,
                    style: AppTextStyles.airportCode.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arrivalTime,
                    style: AppTextStyles.headline5,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.flight.arrivalCity,
                    style: AppTextStyles.airportName,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Flight status
        if (widget.flight.isDelayed()) ...[
          _buildStatusBanner(
            'Delayed by ${widget.flight.departureDelayMinutes} minutes',
            AppColors.warning,
          ),
        ],
        if (widget.flight.isCancelled) ...[
          _buildStatusBanner(
            'Flight Cancelled',
            AppColors.error,
          ),
        ],
        if (!widget.flight.isDelayed() &&
            !widget.flight.isCancelled &&
            widget.flight.status.toLowerCase() == 'active') ...[
          _buildStatusBanner(
            'Flight In Progress',
            AppColors.primary,
          ),
        ],
        if (!widget.flight.isDelayed() &&
            !widget.flight.isCancelled &&
            widget.flight.status.toLowerCase() == 'landed') ...[
          _buildStatusBanner(
            'Flight Landed',
            AppColors.success,
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineBar() {
    final now = DateTime.now();
    final departure = widget.flight.scheduledDeparture ?? now;
    final arrival = widget.flight.scheduledArrival ?? now.add(Duration(hours: 1));

    // Calculate current time position
    double currentTimePosition = 0.0;
    if (now.isAfter(departure) && now.isBefore(arrival)) {
      final totalDuration = arrival.difference(departure).inMilliseconds;
      final elapsedDuration = now.difference(departure).inMilliseconds;
      currentTimePosition = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
    } else if (now.isAfter(arrival)) {
      currentTimePosition = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flight Timeline',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                width: 200 * currentTimePosition,
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
                    color: currentTimePosition > 0 ? AppColors.primary : AppColors.lightDivider,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Current time marker
              if (currentTimePosition > 0 && currentTimePosition < 1.0)
                Positioned(
                  left: 200 * currentTimePosition - 6,
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
                    color: currentTimePosition >= 1.0 ? AppColors.primary : AppColors.lightDivider,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              departure != null ? DateFormat('h:mm a').format(departure) : '--:--',
              style: AppTextStyles.caption,
            ),
            Text(
              arrival != null ? DateFormat('h:mm a').format(arrival) : '--:--',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBanner(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(text),
            size: 16,
            color: color,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightDetails() {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailItem(
              icon: Icons.airplanemode_active,
              label: 'Aircraft',
              value: widget.flight.aircraftType.isNotEmpty ? widget.flight.aircraftType : 'Unknown',
            ),
            _buildDetailItem(
              icon: Icons.confirmation_number,
              label: 'Gate',
              value: widget.flight.gate ?? 'TBA',
            ),
            _buildDetailItem(
              icon: Icons.directions,
              label: 'Terminal',
              value: widget.flight.terminal ?? 'TBA',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String statusText) {
    if (statusText.contains('Delayed')) return Icons.timer;
    if (statusText.contains('Cancelled')) return Icons.cancel;
    if (statusText.contains('In Progress')) return Icons.flight;
    if (statusText.contains('Landed')) return Icons.flight_land;
    return Icons.info_outline;
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
}
