import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    Key? key,
    required this.flight,
    required this.onTap,
    this.showFavoriteIcon = false,
    this.isDetailed = false,
  }) : super(key: key);

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
    _progress = widget.flight.getProgressPercentage();
    _startProgressTimer();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startProgressTimer() {
    // Update progress every second
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _progress = widget.flight.getProgressPercentage();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmallScreen),
                  SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                  _buildFlightRoute(isSmallScreen),
                  if (widget.isDetailed) ...[
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    _buildFlightDetails(isSmallScreen),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First part with airline info
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.flight.airline,
                  style: isSmallScreen 
                      ? AppTextStyles.subtitle1.copyWith(fontSize: 14)
                      : AppTextStyles.subtitle1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: isSmallScreen ? 4 : 8),
              Text(
                widget.flight.flightNumber,
                style: isSmallScreen
                    ? AppTextStyles.flightNumber.copyWith(fontSize: 12)
                    : AppTextStyles.flightNumber,
              ),
            ],
          ),
        ),
        SizedBox(width: isSmallScreen ? 4 : 8),
        // Status and favorite icon
        Flexible(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8, 
                    vertical: isSmallScreen ? 2 : 4
                  ),
                  decoration: BoxDecoration(
                    color: getFlightStatusColor(widget.flight.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.flight.status.toUpperCase(),
                    style: (isSmallScreen 
                        ? AppTextStyles.caption.copyWith(fontSize: 10) 
                        : AppTextStyles.caption).copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (widget.showFavoriteIcon) ...[
                SizedBox(width: isSmallScreen ? 4 : 8),
                InkWell(
                  onTap: () {
                    _flightController.toggleFavoriteFlight(widget.flight);
                  },
                  child: Icon(
                    widget.flight.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.flight.isFavorite ? AppColors.accent : null,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightRoute(bool isSmallScreen) {
    final progress = _progress;
    final departureTime = DateFormat('h:mm a').format(widget.flight.departureTime);
    final arrivalTime = DateFormat('h:mm a').format(widget.flight.arrivalTime);
    final flightDate = DateFormat('EEE, MMM d').format(widget.flight.departureTime);
    
    // Calculate line width based on available space
    return LayoutBuilder(
      builder: (context, constraints) {
        final lineWidth = constraints.maxWidth * 0.25;
        final fontSize = isSmallScreen ? 0.85 : 1.0;
        
        return Column(
          children: [
            Row(
              children: [
                // Departure details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        departureTime,
                        style: AppTextStyles.headline5.copyWith(
                          fontSize: AppTextStyles.headline5.fontSize! * fontSize
                        ),
                      ),
                      Text(
                        widget.flight.departureAirport,
                        style: AppTextStyles.airportCode.copyWith(
                          fontSize: AppTextStyles.airportCode.fontSize! * fontSize
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        widget.flight.departureCity,
                        style: AppTextStyles.airportName.copyWith(
                          fontSize: AppTextStyles.airportName.fontSize! * fontSize
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Flight progress
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isSmallScreen ? 8 : 10,
                            height: isSmallScreen ? 8 : 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: 2,
                                  color: AppColors.lightDivider,
                                ),
                                Positioned(
                                  left: 0,
                                  right: null,
                                  child: Container(
                                    height: 2,
                                    width: lineWidth * progress,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.flight,
                                  size: isSmallScreen ? 16 : 20,
                                  color: AppColors.primary,
                                ).animate(target: progress > 0 ? 1 : 0).custom(
                                      duration: const Duration(milliseconds: 500),
                                      builder: (context, value, child) => Transform.translate(
                                        offset: Offset(lineWidth * (progress - 0.5), 0),
                                        child: child,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          Container(
                            width: isSmallScreen ? 8 : 10,
                            height: isSmallScreen ? 8 : 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        formatDuration(widget.flight.duration),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppTextStyles.caption.fontSize! * fontSize
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        flightDate,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppTextStyles.caption.fontSize! * fontSize
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrival details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        arrivalTime,
                        style: AppTextStyles.headline5.copyWith(
                          fontSize: AppTextStyles.headline5.fontSize! * fontSize
                        ),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        widget.flight.arrivalAirport,
                        style: AppTextStyles.airportCode.copyWith(
                          fontSize: AppTextStyles.airportCode.fontSize! * fontSize
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        widget.flight.arrivalCity,
                        style: AppTextStyles.airportName.copyWith(
                          fontSize: AppTextStyles.airportName.fontSize! * fontSize
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            if (widget.flight.isDelayed()) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 4 : 6, 
                  horizontal: isSmallScreen ? 8 : 12
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Text(
                  'Delayed by ${widget.flight.delayMinutes!.toInt()} minutes',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTextStyles.caption.fontSize! * fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFlightDetails(bool isSmallScreen) {
    return Column(
      children: [
        const Divider(),
        SizedBox(height: isSmallScreen ? 4 : 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // For very small screens, stack the detail items vertically
            if (constraints.maxWidth < 300) {
              return Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.flight,
                    label: 'Aircraft',
                    value: widget.flight.aircraft,
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildDetailItem(
                    icon: Icons.confirmation_number,
                    label: 'Gate',
                    value: widget.flight.departureGate.isNotEmpty ? widget.flight.departureGate : 'TBA',
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  _buildDetailItem(
                    icon: Icons.person,
                    label: 'Terminal',
                    value: widget.flight.departureTerminal.isNotEmpty ? widget.flight.departureTerminal : 'TBA',
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              );
            }
            
            // For larger screens, show items in a row
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.flight,
                    label: 'Aircraft',
                    value: widget.flight.aircraft,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.confirmation_number,
                    label: 'Gate',
                    value: widget.flight.departureGate.isNotEmpty ? widget.flight.departureGate : 'TBA',
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.person,
                    label: 'Terminal',
                    value: widget.flight.departureTerminal.isNotEmpty ? widget.flight.departureTerminal : 'TBA',
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    final fontSize = isSmallScreen ? 0.85 : 1.0;
    
    return Column(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 16 : 20,
          color: AppColors.primary,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: AppTextStyles.caption.fontSize! * fontSize,
          ),
        ),
        SizedBox(height: isSmallScreen ? 1 : 2),
        Text(
          value,
          style: AppTextStyles.subtitle2.copyWith(
            fontSize: AppTextStyles.subtitle2.fontSize! * fontSize,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}