import 'package:flight_tracker/app/widgets/flight_ticket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/flight_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/flight_card.dart';
import '../../../widgets/loading_widget.dart';

class FlightSearchView extends StatefulWidget {
  const FlightSearchView({Key? key}) : super(key: key);

  @override
  State<FlightSearchView> createState() => _FlightSearchViewState();
}

class _FlightSearchViewState extends State<FlightSearchView> with SingleTickerProviderStateMixin {
  final FlightController _flightController = Get.find<FlightController>();

  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _ticketController = TextEditingController(); // Added ticket controller

  final GlobalKey<FormState> _flightNumberFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _routeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _ticketFormKey = GlobalKey<FormState>(); // Added ticket form key

  late TabController _tabController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Increased tab length
    _departureDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flightNumberController.dispose();
    _departureDateController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    _ticketController.dispose(); // Added ticket controller dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Flights', style: AppTextStyles.headline6),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Flight Number'),
            Tab(text: 'Route'),
            Tab(text: 'Ticket'), // Added Ticket Tab
          ],
          labelStyle: AppTextStyles.tabLabel,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlightNumberSearch(),
          _buildRouteSearch(),
          _buildTicketSearch(), // Added Ticket Search Tab
        ],
      ),
    );
  }

  Widget _buildFlightNumberSearch() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchByFlightNumberForm(),
          const SizedBox(height: 24),
          _buildRecentSearches(),
          const SizedBox(height: 24),
          Obx(() {
            if (_flightController.isLoading) {
              return const LoadingWidget();
            }

            if (_flightController.selectedFlight != null) {
              return _buildFlightResult(_flightController.selectedFlight!);
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchByFlightNumberForm() {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _flightNumberFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search by Flight Number', style: AppTextStyles.headline5),
                const SizedBox(height: 8),
                Text(
                  'Enter the airline code and flight number (e.g., BA1326)',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _flightNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Flight Number',
                    hintText: 'e.g., BA1326, UA110',
                    prefixIcon: Icon(Icons.flight),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a flight number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departureDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Search',
                  onPressed: _searchByFlightNumber,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSearch() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchByRouteForm(),
          const SizedBox(height: 24),
          Obx(() {
            if (_flightController.isLoading) {
              return const LoadingWidget();
            }

            if (_flightController.flights.isNotEmpty) {
              return _buildFlightsList();
            }

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSearchByRouteForm() {
    return Animate(
      effects: const [FadeEffect(), SlideEffect()],
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _routeFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search by Route', style: AppTextStyles.headline5),
                const SizedBox(height: 8),
                Text(
                  'Enter departure and arrival airports',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departureController,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    hintText: 'Airport code (e.g., LHR)',
                    prefixIcon: Icon(Icons.flight_takeoff),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter departure airport';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _arrivalController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    hintText: 'Airport code (e.g., JFK)',
                    prefixIcon: Icon(Icons.flight_land),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter arrival airport';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departureDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Search',
                  onPressed: _searchByRoute,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (_flightController.recentSearches.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: AppTextStyles.headline6),
              TextButton(
                onPressed: _flightController.clearRecentSearches,
                child: Text(
                  'Clear',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _flightController.recentSearches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(_flightController.recentSearches[index]),
                    onPressed: () {
                      // Handle recent search tap
                      final search = _flightController.recentSearches[index];
                      if (search.contains(' to ')) {
                        // It's a route search
                        final parts = search.split(' to ');
                        if (parts.length == 2) {
                          _departureController.text = parts[0];
                          _arrivalController.text = parts[1];
                          _tabController.animateTo(1);
                        }
                      } else {
                        // It's a flight number search
                        _flightNumberController.text = search;
                        _tabController.animateTo(0);
                      }
                    },
                    backgroundColor: AppColors.lightSurface,
                    side: const BorderSide(color: AppColors.lightDivider),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFlightResult(dynamic flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search Result', style: AppTextStyles.headline6),
        const SizedBox(height: 16),
        Animate(
          effects: const [FadeEffect(), SlideEffect()],
          child: FlightCard(
            flight: flight,
            onTap: () => Get.toNamed(
              Routes.FLIGHT_DETAIL,
              arguments: {'flightNumber': flight.flightNumber},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlightsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${_flightController.flights.length} Flights',
          style: AppTextStyles.headline6,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _flightController.flights.length,
          itemBuilder: (context, index) {
            final flight = _flightController.flights[index];
            return Animate(
              effects: [
                FadeEffect(delay: Duration(milliseconds: 100 * index)),
                SlideEffect(delay: Duration(milliseconds: 100 * index)),
              ],
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
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: AppColors.lightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _departureDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _searchByFlightNumber() {
    if (_flightNumberFormKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      final flightNumber = _flightNumberController.text.trim().toUpperCase();
      _flightController.getFlightByNumber(flightNumber);
    }
  }

  void _searchByRoute() {
    if (_routeFormKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      final departure = _departureController.text.trim().toUpperCase();
      final arrival = _arrivalController.text.trim().toUpperCase();
      final date = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null;

      _flightController.searchFlights(
        departureAirport: departure,
        arrivalAirport: arrival,
        date: date,
      );
    }
  }

  Widget _buildTicketSearch() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Animate(
            effects: const [FadeEffect(), SlideEffect()],
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _ticketFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Search by Ticket', style: AppTextStyles.headline5),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your ticket number to check flight status',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ticketController,
                        decoration: const InputDecoration(
                          labelText: 'Ticket Number',
                          hintText: 'e.g., ABC123XYZ',
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a ticket number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Search',
                        onPressed: _searchByTicket,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
       Obx(() {
  if (_flightController.isLoading) {
    return const LoadingWidget();
  }
  if (_flightController.selectedFlight != null && _flightController.selectedTicket.isNotEmpty) {
   return FlightTicket(ticket: _flightController.selectedTicket.first, flight: _flightController.selectedFlight!);
  }

  return const SizedBox.shrink();
}),
        ],
      ),
    );
  }

  void _searchByTicket() {
    if (_ticketFormKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      final ticketNumber = _ticketController.text.trim().toUpperCase();
      _flightController.getFlightByTicket(ticketNumber); 
    }
  }
}
