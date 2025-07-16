import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Supabase credentials
  static String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // AeroDataBox API from RapidAPI
  static const String aeroDataBoxBaseUrl = 'https://aerodatabox.p.rapidapi.com';
  static final String aeroDataBoxApiKey =
      dotenv.env['AERODATABOX_API_KEY']!; // Get from env in production

  // Map API Keys
  static const String googleMapsApiKey =
      'your-google-maps-api-key'; // Get from env in production

  // RevenueCat API Keys
  static const String revenueCatApiKey = '';
  // Subscription Plans
  static const Map<String, dynamic> subscriptionPlans = {
    'free': {
      'name': 'Free',
      'price': 0.0,
      'features': [
        'Basic flight tracking',
        'Limited search history',
        'Standard notifications',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price': 4.99,
      'features': [
        'Advanced flight tracking',
        'Unlimited search history',
        'Priority notifications',
        'Ad-free experience',
        'Detailed flight statistics',
      ],
    },
    'pro': {
      'name': 'Pro',
      'price': 9.99,
      'features': [
        'Premium features',
        'Detailed delay predictions',
        'Historical flight data',
        'Airport maps',
        'Priority support',
      ],
    },
  };

  // App Settings
  static const String appName = 'Flight Tracker';
  static const String appVersion = '1.0.0';

  // Local Storage Keys
  static const String userBox = 'userBox';
  static const String flightBox = 'flightBox';
  static const String settingsBox = 'settingsBox';

  // Notification Channels
  static const String flightAlertChannel = 'flight_alerts';
  static const String generalNotificationChannel = 'general_notifications';
}
