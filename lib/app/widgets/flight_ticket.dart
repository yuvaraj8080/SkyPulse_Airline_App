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
    Key? key,
    required this.ticket,
    required this.flight,
    this.onCheckinPressed,
  }) : super(key: key);

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
              widget.flight.airline,
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
    final departureTime = DateFormat('h:mm a').format(widget.flight.departureTime);
    final arrivalTime = DateFormat('h:mm a').format(widget.flight.arrivalTime);
    final flightDate = DateFormat('EEE, MMM d').format(widget.flight.departureTime);

    return Row(
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
            ],
          ),
        ),

        // Flight icon
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Icon(
                Icons.flight,
                color: Colors.white,
                size: isSmallScreen ? 24 : 30,
              ),
              const SizedBox(height: 4),
              Text(
                formatDuration(widget.flight.duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isSmallScreen ? 10 : 12,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerInfo(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PASSENGER',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.ticket.passengerName,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BOOKING REF',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }

  Widget _buildTicketDetails(bool isSmallScreen) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Row(
      children: [
        _buildDetailItem(
          'DATE',
          dateFormat.format(widget.flight.departureTime),
          isSmallScreen,
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          'FLIGHT',
          widget.flight.flightNumber,
          isSmallScreen,
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          'GATE',
          widget.flight.departureGate.isNotEmpty ? widget.flight.departureGate : 'TBA',
          isSmallScreen,
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          'SEAT',
          widget.ticket.seatNumber,
          isSmallScreen,
          emphasize: true,
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, bool isSmallScreen, {bool emphasize = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              color: emphasize ? AppColors.accent : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
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
    );
  }

  Widget _buildCheckinButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onCheckinPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'CHECK IN NOW',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTearLine() {
    return Container(
      height: 3,
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
    );
  }

  Widget _buildAdditionalInfo(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInfoItem(
              Icons.luggage,
              'Baggage',
              '${widget.ticket.baggageAllowance?.toStringAsFixed(0) ?? "0"} kg',
              isSmallScreen,
            ),
            const SizedBox(width: 16),
            _buildInfoItem(
              Icons.group,
              'Boarding',
              widget.ticket.boardingGroup,
              isSmallScreen,
            ),
            if (widget.ticket.hasPriorityBoarding) ...[
              const SizedBox(width: 16),
              _buildInfoItem(
                Icons.priority_high,
                'Priority',
                'Yes',
                isSmallScreen,
                iconColor: AppColors.accent,
              ),
            ],
          ],
        ),
        if (widget.ticket.services.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'ADDITIONAL SERVICES',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.ticket.services
                .map((service) => Chip(
                      label: Text(
                        service,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, bool isSmallScreen, {Color? iconColor}) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: isSmallScreen ? 16 : 20,
            color: iconColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
        ],
      ),
    );
  }
}
