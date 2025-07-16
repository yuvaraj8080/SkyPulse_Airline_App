import 'package:flight_tracker/app/data/providers/api_provider.dart';
import 'package:flight_tracker/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/flight_controller.dart';
import 'app/controllers/subscription_controller.dart';
import 'app/data/repositories/flight_repository.dart';
import 'app/data/repositories/user_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/constants.dart';

final logger = Logger();

Future<void> main() async {
  await _initializeApp();
  runApp(const FlightTrackerApp());
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load environment variables
    await dotenv.load(fileName: ".env");
    logger.i('Environment variables loaded');

    // 2. Initialize storage solutions
    await _initializeStorage();

    // 3. Set device orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 4. Initialize Supabase with proper session persistence
    await Supabase.initialize(
      url: Constants.supabaseUrl,
      anonKey: Constants.supabaseAnonKey,
      debug: true,
    );

    // 5. Initialize other dependencies
    await _initializeDependencies();

    logger.i('App initialization completed');
  } catch (e, stackTrace) {
    logger.e('App initialization failed', error: e, stackTrace: stackTrace);
  }
}

Future<void> _initializeStorage() async {
  await Hive.initFlutter();
  await Hive.openBox(Constants.flightBox);
  await SharedPreferences.getInstance();
}

Future<void> _initializeDependencies() async {
  // Initialize API Provider
  final apiProvider = FlightApiProvider();

  // Initialize Repositories
  final flightRepository = FlightRepository(
    apiProvider: apiProvider,
    flightBox: Hive.box(Constants.flightBox),
  );

  final userRepository = UserRepository();

  // Initialize Controllers with dependencies
  final authController =
      Get.put<AuthController>(AuthController(), permanent: true);

  // Wait for auth check to complete before proceeding
  await authController.checkAuthStatus();

  Get.put<FlightController>(
    FlightController(
      flightRepository: flightRepository,
      userRepository: userRepository,
      authController: authController,
    ),
    permanent: true,
  );

  Get.put<SubscriptionController>(SubscriptionController(), permanent: true);
}

class FlightTrackerApp extends StatelessWidget {
  const FlightTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyLine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }

  String _getInitialRoute() {
    try {
      final authController = Get.find<AuthController>();
      return authController.isAuthenticated ? Routes.HOME : Routes.LOGIN;
    } catch (e) {
      logger.e('Error getting auth status: $e');
      return Routes.LOGIN;
    }
  }
}
