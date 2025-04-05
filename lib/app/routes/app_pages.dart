import 'package:flight_tracker/app/modules/splash/splash_view.dart';
import 'package:get/get.dart';

import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/profile_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/flight/views/flight_detail_view.dart';
import '../modules/flight/views/flight_map_view.dart';
import '../modules/flight/views/flight_search_view.dart';
import '../modules/flight/views/saved_flights_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/subscription/views/subscription_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.INITIAL;
  // Auth
  static const LOGIN = Routes.LOGIN;
  static const SIGNUP = Routes.SIGNUP;
  static const PROFILE = Routes.PROFILE;

  // Main
  static const HOME = Routes.HOME;
  static const FLIGHT_SEARCH = Routes.FLIGHT_SEARCH;
  static const FLIGHT_DETAIL = Routes.FLIGHT_DETAIL;
  static const FLIGHT_MAP = Routes.FLIGHT_MAP;
  static const SAVED_FLIGHTS = Routes.SAVED_FLIGHTS;
  static const SUBSCRIPTION = Routes.SUBSCRIPTION;

  static final routes = [
    // Initial Route
    GetPage(
      name: INITIAL,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    // Auth Routes
    GetPage(
      name: LOGIN,
      page: () => LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: SIGNUP,
      page: () => SignupView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: PROFILE,
      page: () => ProfileView(),
      transition: Transition.fadeIn,
    ),

    // Main Routes
    GetPage(
      name: HOME,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: FLIGHT_SEARCH,
      page: () => const FlightSearchView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: FLIGHT_DETAIL,
      page: () => const FlightDetailView(),
      transition: Transition.rightToLeft,
    ),
    // GetPage(
    //   name: FLIGHT_MAP,
    //   page: () => const FlightMapView(),
    //   transition: Transition.fadeIn,
    // ),
    GetPage(
      name: SAVED_FLIGHTS,
      page: () => SavedFlightsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: SUBSCRIPTION,
      page: () => SubscriptionView(),
      transition: Transition.fadeIn,
    ),
  ];
}
