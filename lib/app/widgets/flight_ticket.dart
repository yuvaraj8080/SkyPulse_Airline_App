import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/flight_controller.dart';
import '../data/models/flight_model.dart';
import '../data/models/ticket_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/helpers.dart';

class FlightTicket extends StatefulWidget {
  final Ticket ticket;
  final Flight flight;
  final VoidCallback? onCheckinPressed;

  const FlightTicket({
    super.key,
    required this.ticket,
    required this.flight,
    this.onCheckinPressed,
  });

  @override
  State<FlightTicket> createState() => _FlightTicketState();
}

class _FlightTicketState extends State<FlightTicket> {
  final FlightController _flightController = Get.find<FlightController>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 350;
      final padding = isSmallScreen ? 12.0 : 16.0;
      final spacing = isSmallScreen ? 8.0 : 16.0;

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upper part - Flight info
            Container(
              padding: EdgeInsets.all(padding),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  _buildAirlineHeader(isSmallScreen),
                  SizedBox(height: spacing),
                  _buildFlightRoute(isSmallScreen),
                ],
              ),
            ),

            // Middle part - Ticket details
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  _buildPassengerInfo(isSmallScreen),
                  SizedBox(height: spacing),
                  _buildTicketDetails(isSmallScreen),
                  SizedBox(height: spacing),
                  _buildBarcode(isSmallScreen),
                  SizedBox(height: spacing),
                  if (!widget.ticket.isCheckedIn) _buildCheckinButton(),
                ],
              ),
            ),

            // Bottom part - Tear line
            _buildTearLine(),

            // Extra info - Baggage, etc
            Padding(
              padding: EdgeInsets.all(padding),
              child: _buildAdditionalInfo(isSmallScreen),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAirlineHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.flight.airlineName,
              style: AppTextStyles.subtitle1.copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.flight.flightNumber,
              style: AppTextStyles.flightNumber.copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: isSmallScreen ? 2 : 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.ticket.travelClass.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightRoute(bool isSmallScreen) {
    final departureTime = widget.flight.scheduledDeparture != null
        ? DateFormat('h:mm a').format(widget.flight.scheduledDeparture!)
        : '--:--';
    final arrivalTime =
        widget.flight.scheduledArrival != null ? DateFormat('h:mm a').format(widget.flight.scheduledArrival!) : '--:--';
    final flightDate = widget.flight.scheduledDeparture != null
        ? DateFormat('EEE, MMM d').format(widget.flight.scheduledDeparture!)
        : '--';

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
                    departureTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.flight.departureAirport,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    widget.flight.departureCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Row(
                    children: [
                      Icon(Icons.thermostat_outlined, size: 12, color: Colors.white.withOpacity(0.8)),
                      SizedBox(width: 2),
                      Text(
                        '24°C',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.wb_sunny, size: 12, color: Colors.white.withOpacity(0.8)),
                    ],
                  ),
                ],
              ),
            ),

            // Flight icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flight,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.flight.flightDuration != null
                          ? formatDuration(Duration(minutes: widget.flight.flightDuration!))
                          : '--:--',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrival details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    arrivalTime,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    widget.flight.arrivalAirport,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    widget.flight.arrivalCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.thermostat_outlined, size: 12, color: Colors.white.withOpacity(0.8)),
                      SizedBox(width: 2),
                      Text(
                        '18°C',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.cloud, size: 12, color: Colors.white.withOpacity(0.8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (widget.flight.isDelayed() || widget.flight.isCancelled)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.flight.isCancelled ? Icons.cancel : Icons.warning_amber,
                  size: 14,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  widget.flight.isCancelled
                      ? 'Flight Cancelled'
                      : 'Delayed by ${widget.flight.departureDelayMinutes} min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPassengerInfo(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: isSmallScreen ? 16 : 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'PASSENGER',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.ticket.passengerName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.ticket.travelClass.toUpperCase(),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.ticket.hasPriorityBoarding) ...[
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PRIORITY',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 9 : 10,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOOKING REF',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 10,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.ticket.bookingReference,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetails(bool isSmallScreen) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.airplane_ticket,
                size: isSmallScreen ? 16 : 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'FLIGHT DETAILS',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildDetailItem(
                'DATE',
                widget.flight.scheduledDeparture != null ? dateFormat.format(widget.flight.scheduledDeparture!) : '--',
                isSmallScreen,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'FLIGHT',
                widget.flight.flightNumber,
                isSmallScreen,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'GATE',
                widget.flight.gate ?? 'TBA',
                isSmallScreen,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'SEAT',
                widget.ticket.seatNumber,
                isSmallScreen,
                emphasize: true,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildDetailItem(
                'BOARDING',
                widget.flight.scheduledDeparture != null
                    ? DateFormat('HH:mm').format(widget.flight.scheduledDeparture!.subtract(Duration(minutes: 30)))
                    : '--:--',
                isSmallScreen,
                iconData: Icons.time_to_leave,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'GROUP',
                widget.ticket.boardingGroup,
                isSmallScreen,
                iconData: Icons.group,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'LUGGAGE',
                '${widget.ticket.baggageAllowance?.toStringAsFixed(0) ?? "0"} kg',
                isSmallScreen,
                iconData: Icons.luggage,
              ),
              _buildDetailDivider(),
              _buildDetailItem(
                'TERMINAL',
                widget.flight.terminal ?? 'TBA',
                isSmallScreen,
                iconData: Icons.business,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider() {
    return Container(
      height: 30,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 6),
      color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }

  Widget _buildDetailItem(String label, String value, bool isSmallScreen,
      {bool emphasize = false, IconData? iconData}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 10,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              if (iconData != null) ...[
                Icon(
                  iconData,
                  size: 12,
                  color: emphasize ? AppColors.accent : AppColors.lightTextSecondary,
                ),
                SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
                    color: emphasize ? AppColors.accent : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Row(
        children: [
          // Left side - Barcode
          Expanded(
            flex: 3,
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: widget.ticket.ticketNumber,
                  width: double.infinity,
                  height: isSmallScreen ? 60 : 80,
                  color: AppColors.darkText,
                  drawText: false,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.ticket.ticketNumber,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Right side - QR Code
          Expanded(
            flex: 2,
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: 'BP/${widget.ticket.ticketNumber}/${widget.flight.flightNumber}',
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 80 : 100,
                  color: AppColors.darkText,
                ),
                const SizedBox(height: 4),
                Text(
                  'Boarding Pass',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onCheckinPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              const Text(
                'CHECK IN NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTearLine() {
    return Stack(
      children: [
        Container(
          height: 20,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(
              40,
              (index) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.transparent : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 10,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            child: Text(
              'TEAR HERE',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoItem(
              Icons.luggage,
              'Baggage',
              '${widget.ticket.baggageAllowance?.toStringAsFixed(0) ?? "0"} kg',
              isSmallScreen,
            ),
            _buildInfoItem(
              Icons.group,
              'Boarding',
              widget.ticket.boardingGroup,
              isSmallScreen,
            ),
            if (widget.ticket.hasPriorityBoarding)
              _buildInfoItem(
                Icons.priority_high,
                'Priority',
                'Yes',
                isSmallScreen,
                iconColor: AppColors.accent,
              ),
            _buildInfoItem(
              Icons.timelapse,
              'Check-in',
              widget.flight.scheduledDeparture != null
                  ? DateFormat('HH:mm').format(widget.flight.scheduledDeparture!.subtract(Duration(hours: 2)))
                  : '--:--',
              isSmallScreen,
            ),
          ],
        ),
        if (widget.ticket.services.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.stars,
                size: isSmallScreen ? 16 : 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'ADDITIONAL SERVICES',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.ticket.services
                .map((service) => Chip(
                      label: Text(
                        service,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: AppColors.primary,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        // Add the flight info disclaimer section
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColors.darkSurface.withOpacity(0.5) : AppColors.lightSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Important Information',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Please arrive at the airport at least 2 hours before the scheduled departure. Have your ID and this boarding pass ready for security check.',
                style: TextStyle(
                  fontSize: 10,
                  color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, bool isSmallScreen, {Color? iconColor}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 16 : 20,
            color: iconColor ?? AppColors.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
