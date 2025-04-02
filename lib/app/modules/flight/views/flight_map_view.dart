import 'package:flight_tracker/app/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../controllers/flight_controller.dart';
import '../../../controllers/map_controller.dart';
import '../../../data/models/flight_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class FlightMapView extends StatefulWidget {
  const FlightMapView({Key? key}) : super(key: key);

  @override
  State<FlightMapView> createState() => _FlightMapViewState();
}

class _FlightMapViewState extends State<FlightMapView> {
  final FlightController _flightController = Get.find<FlightController>();
  final MapController _mapController = Get.put(MapController());
  
  Flight? _flight;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _initFlight();
  }

  void _initFlight() {
    if (Get.arguments != null && Get.arguments['flight'] != null) {
      _flight = Get.arguments['flight'];
    } else if (_flightController.selectedFlight != null) {
      _flight = _flightController.selectedFlight;
    }
    
    if (_flight == null) {
      // If no flight is provided, go back
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_flight == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Flight Map', style: AppTextStyles.headline6),
        ),
        body: const Center(
          child: Text('No flight data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Map', style: AppTextStyles.headline6),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _toggleMapType,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildFlightInfoOverlay(),
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(
      () => GoogleMap(
        initialCameraPosition: _mapController.initialCameraPosition,
        markers: _mapController.markers,
        polylines: _mapController.polylines,
        mapType: _currentMapType,
        myLocationEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {
          _mapController.onMapCreated(controller);
          if (_flight != null) {
            _mapController.setupFlightMap(_flight!);
          }
        },
      ),
    );
  }

  Widget _buildFlightInfoOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_flight!.airline} ${_flight!.flightNumber}',
                    style: AppTextStyles.headline6,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getFlightStatusColor(_flight!.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _flight!.status.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _flight!.departureAirport,
                        style: AppTextStyles.subtitle1,
                      ),
                      Text(
                        _flight!.departureCity,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.flight,
                    color: AppColors.primary,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _flight!.arrivalAirport,
                        style: AppTextStyles.subtitle1,
                      ),
                      Text(
                        _flight!.arrivalCity,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _flight!.getProgressPercentage(),
                backgroundColor: AppColors.lightDivider,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 32,
      child: Column(
        children: [
          _buildMapControlButton(
            Icons.add,
            _mapController.zoomIn,
          ),
          const SizedBox(height: 8),
          _buildMapControlButton(
            Icons.remove,
            _mapController.zoomOut,
          ),
          const SizedBox(height: 8),
          _buildMapControlButton(
            Icons.center_focus_strong,
            _mapController.resetMapView,
          ),
          const SizedBox(height: 8),
          _buildMapControlButton(
            Icons.layers,
            _toggleMapType,
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }
}
