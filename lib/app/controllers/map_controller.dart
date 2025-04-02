import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/flight_model.dart';
import 'flight_controller.dart';

class MapController extends GetxController {
  final FlightController _flightController = Get.find<FlightController>();
  
  final Rx<GoogleMapController?> _mapController = Rx<GoogleMapController?>(null);
  final RxSet<Marker> _markers = <Marker>{}.obs;
  final RxSet<Polyline> _polylines = <Polyline>{}.obs;
  final RxDouble _zoom = 5.0.obs;
  final Rx<CameraPosition> _initialCameraPosition = Rx<CameraPosition>(
    const CameraPosition(
      target: LatLng(0, 0),
      zoom: 5.0,
    ),
  );
  
  GoogleMapController? get mapController => _mapController.value;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  double get zoom => _zoom.value;
  CameraPosition get initialCameraPosition => _initialCameraPosition.value;

  void onMapCreated(GoogleMapController controller) {
    _mapController.value = controller;
    
    // If we already have a selected flight, initialize the map with it
    if (_flightController.selectedFlight != null) {
      setupFlightMap(_flightController.selectedFlight!);
    }
  }
  
  @override
  void onClose() {
    _mapController.value?.dispose();
    super.onClose();
  }
  
  // Setup map with flight data
  void setupFlightMap(Flight flight) {
    // Clear previous markers and polylines
    _markers.clear();
    _polylines.clear();
    
    // Create departure and arrival airport markers
    _addDepartureMarker(flight);
    _addArrivalMarker(flight);
    
    // Add aircraft marker if flight is in progress and has position data
    if (flight.isInFlight() && flight.positions != null && flight.positions!.isNotEmpty) {
      _addAircraftMarker(flight);
    }
    
    // Create flight path polyline
    _addFlightPathPolyline(flight);
    
    // Move camera to show the entire flight path
    _fitMapToFlightPath(flight);
  }
  
  // Add marker for departure airport
  void _addDepartureMarker(Flight flight) {
    final departurePosition = _getAirportPosition(
      flight.departureAirport, 
      _getDummyPosition(true),
    );
    
    _markers.add(
      Marker(
        markerId: MarkerId('departure_${flight.flightNumber}'),
        position: departurePosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: flight.departureAirport,
          snippet: flight.departureCity,
        ),
      ),
    );
  }
  
  // Add marker for arrival airport
  void _addArrivalMarker(Flight flight) {
    final arrivalPosition = _getAirportPosition(
      flight.arrivalAirport, 
      _getDummyPosition(false),
    );
    
    _markers.add(
      Marker(
        markerId: MarkerId('arrival_${flight.flightNumber}'),
        position: arrivalPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: flight.arrivalAirport,
          snippet: flight.arrivalCity,
        ),
      ),
    );
  }
  
  // Add marker for aircraft
  void _addAircraftMarker(Flight flight) {
    if (flight.positions == null || flight.positions!.isEmpty) return;
    
    final latestPosition = flight.positions!.last;
    
    _markers.add(
      Marker(
        markerId: MarkerId('aircraft_${flight.flightNumber}'),
        position: LatLng(latestPosition.latitude, latestPosition.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: flight.flightNumber,
          snippet: '${flight.airline} - ${flight.aircraft}',
        ),
        rotation: latestPosition.heading ?? 0,
      ),
    );
  }
  
  // Add polyline for the flight path
  void _addFlightPathPolyline(Flight flight) {
    final departurePosition = _getAirportPosition(
      flight.departureAirport, 
      _getDummyPosition(true),
    );
    
    final arrivalPosition = _getAirportPosition(
      flight.arrivalAirport, 
      _getDummyPosition(false),
    );
    
    // Create a list of points for the polyline
    List<LatLng> points = [];
    
    // If we have position data, use it
    if (flight.positions != null && flight.positions!.isNotEmpty) {
      points = flight.positions!.map(
        (pos) => LatLng(pos.latitude, pos.longitude)
      ).toList();
    } else {
      // Otherwise, just use a direct line between departure and arrival
      points = [departurePosition, arrivalPosition];
    }
    
    // Create polyline
    _polylines.add(
      Polyline(
        polylineId: PolylineId('path_${flight.flightNumber}'),
        points: points,
        color: Colors.blue,
        width: 3,
      ),
    );
    
    // If the flight is in progress, add a second polyline for the remaining path
    if (flight.isInFlight() && flight.positions != null && flight.positions!.isNotEmpty) {
      final currentPosition = flight.positions!.last;
      final currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
      
      _polylines.add(
        Polyline(
          polylineId: PolylineId('remaining_${flight.flightNumber}'),
          points: [currentLatLng, arrivalPosition],
          color: Colors.grey,
          width: 3,
          patterns: [PatternItem.dash(10), PatternItem.gap(10)],
        ),
      );
    }
  }
  
  // Fit the map to show the entire flight path
  void _fitMapToFlightPath(Flight flight) {
    final departurePosition = _getAirportPosition(
      flight.departureAirport, 
      _getDummyPosition(true),
    );
    
    final arrivalPosition = _getAirportPosition(
      flight.arrivalAirport, 
      _getDummyPosition(false),
    );
    
    // Calculate bounds to include both airports
    final southwest = LatLng(
      min(departurePosition.latitude, arrivalPosition.latitude) - 1.0,
      min(departurePosition.longitude, arrivalPosition.longitude) - 1.0,
    );
    
    final northeast = LatLng(
      max(departurePosition.latitude, arrivalPosition.latitude) + 1.0,
      max(departurePosition.longitude, arrivalPosition.longitude) + 1.0,
    );
    
    final bounds = LatLngBounds(
      southwest: southwest,
      northeast: northeast,
    );
    
    // Animate camera to show the bounds
    _mapController.value?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }
  
  // Helper function to get min of two values
  double min(double a, double b) => a < b ? a : b;
  
  // Helper function to get max of two values
  double max(double a, double b) => a > b ? a : b;
  
  // In a real app, you would get actual airport coordinates from a database or API
  // For this example, we're using dummy coordinates if needed
  LatLng _getAirportPosition(String airportCode, LatLng fallbackPosition) {
    // In a real app, lookup the coordinates for this airport code
    // For now, return the fallback position
    return fallbackPosition;
  }
  
  // Generate dummy positions for departure and arrival
  LatLng _getDummyPosition(bool isDeparture) {
    if (isDeparture) {
      return const LatLng(40.6413, -73.7781); // JFK Airport approximate coordinates
    } else {
      return const LatLng(51.4700, -0.4543); // Heathrow Airport approximate coordinates
    }
  }
  
  // Zoom in
  void zoomIn() {
    _zoom.value += 1.0;
    _mapController.value?.animateCamera(CameraUpdate.zoomIn());
  }
  
  // Zoom out
  void zoomOut() {
    _zoom.value -= 1.0;
    _mapController.value?.animateCamera(CameraUpdate.zoomOut());
  }
  
  // Reset map view to show the entire flight path
  void resetMapView() {
    if (_flightController.selectedFlight != null) {
      _fitMapToFlightPath(_flightController.selectedFlight!);
    }
  }
  
  // Set map type (normal, satellite, etc.)
  void setMapType(MapType mapType) {
    // This would be handled by the map widget's mapType property
  }
}
