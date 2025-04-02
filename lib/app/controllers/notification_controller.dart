// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;
// import '../data/models/flight_model.dart';
// import '../routes/app_routes.dart';
// import '../utils/constants.dart';

// class NotificationController extends GetxController {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
//       FlutterLocalNotificationsPlugin();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
//   final RxBool _initialized = false.obs;
//   final RxBool _permissionGranted = false.obs;
  
//   bool get initialized => _initialized.value;
//   bool get permissionGranted => _permissionGranted.value;
  
//   // Location for timezone operations
//   tz.Location? _location;
  
//   @override
//   void onInit() {
//     super.onInit();
//     _initTimeZone();
//     _initNotifications();
//   }
  
//   // Initialize timezone data
//   Future<void> _initTimeZone() async {
//     try {
//       tz_data.initializeTimeZones();
//       _location = tz.getLocation('America/New_York'); // Default to New York, can be changed later
//       tz.setLocalLocation(_location!);
//       print('Timezone initialized: ${_location?.name}');
//     } catch (e) {
//       print('Error initializing timezone: $e');
//       // Fallback to device local time
//       _location = tz.local;
//     }
//   }
  
//   // Initialize notifications
//   Future<void> _initNotifications() async {
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
        
//     final DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//       onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
//     );
    
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
    
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );
    
//     // Initialize Firebase Cloud Messaging
//     await _initFirebaseMessaging();
    
//     // Request permission
//     await requestPermission();
    
//     _initialized.value = true;
//   }
  
//   // Initialize Firebase Cloud Messaging
//   Future<void> _initFirebaseMessaging() async {
//     // Get FCM token
//     String? token = await _firebaseMessaging.getToken();
//     print('FCM Token: $token');
    
//     // Handle incoming messages when the app is in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');
      
//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
        
//         // Show a local notification
//         _showLocalNotification(
//           message.notification?.title ?? 'Flight Alert',
//           message.notification?.body ?? '',
//           message.data,
//         );
//       }
//     });
    
//     // Handle when the app is opened from a notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       _handleNotificationTap(message.data);
//     });
//   }
  
//   // Request permission for notifications
//   // Future<void> requestPermission() async {
//   //   // Request permission for local notifications
//   //   final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
//   //       _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//   //           AndroidFlutterLocalNotificationsPlugin>();
    
//   //   if (androidPlugin != null) {
//   //     await androidPlugin.requestPermission();
//   //   }
    
//   //   // Request permission for Firebase Cloud Messaging
//   //   NotificationSettings settings = await _firebaseMessaging.requestPermission(
//   //     alert: true,
//   //     announcement: false,
//   //     badge: true,
//   //     carPlay: false,
//   //     criticalAlert: true,
//   //     provisional: false,
//   //     sound: true,
//   //   );
    
//   //   _permissionGranted.value = 
//   //       settings.authorizationStatus == AuthorizationStatus.authorized ||
//   //       settings.authorizationStatus == AuthorizationStatus.provisional;
        
//   //   print('User granted permission: ${_permissionGranted.value}');
//   // }
  
//   // Subscribe to a flight topic for push notifications
//   Future<void> subscribeToFlight(String flightNumber) async {
//     final sanitizedFlightNumber = flightNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
//     await _firebaseMessaging.subscribeToTopic('flight_$sanitizedFlightNumber');
//     print('Subscribed to flight_$sanitizedFlightNumber');
//   }
  
//   // Unsubscribe from a flight topic
//   Future<void> unsubscribeFromFlight(String flightNumber) async {
//     final sanitizedFlightNumber = flightNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
//     await _firebaseMessaging.unsubscribeFromTopic('flight_$sanitizedFlightNumber');
//     print('Unsubscribed from flight_$sanitizedFlightNumber');
//   }
  
//   // Schedule a local notification for flight status
//   Future<void> scheduleFlightNotification(Flight flight, Duration timeBeforeDeparture) async {
//     final departureTime = flight.departureTime;
//     final notificationTime = departureTime.subtract(timeBeforeDeparture);
    
//     if (notificationTime.isBefore(DateTime.now())) {
//       // The notification time is in the past, don't schedule it
//       return;
//     }
    
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       Constants.flightAlertChannel,
//       'Flight Alerts',
//       channelDescription: 'Notifications about your flights',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
    
//     final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
    
//     final platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
    
//     final title = 'Flight ${flight.flightNumber} Reminder';
//     final body = 'Your flight from ${flight.departureAirport} to ${flight.arrivalAirport} departs in ${timeBeforeDeparture.inHours} hours.';
    
//     final scheduledDateTime = notificationTime.toLocal();
    
//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       flight.flightNumber.hashCode,
//       title,
//       body,
//       convertToTZDateTime(scheduledDateTime),
//       platformChannelSpecifics,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       payload: 'flight|${flight.flightNumber}',
//     );
    
//     print('Scheduled notification for flight ${flight.flightNumber} at $scheduledDateTime');
//   }
  
//   // Cancel a scheduled notification for a flight
//   Future<void> cancelFlightNotification(String flightNumber) async {
//     await _flutterLocalNotificationsPlugin.cancel(flightNumber.hashCode);
//     print('Cancelled notification for flight $flightNumber');
//   }
  
//   // Show a local notification
//   Future<void> _showLocalNotification(
//     String title, 
//     String body, 
//     Map<String, dynamic> payload,
//   ) async {
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       Constants.generalNotificationChannel,
//       'General Notifications',
//       channelDescription: 'General app notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );
    
//     final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
    
//     final platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );
    
//     await _flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload.toString(),
//     );
//   }
  
//   // Handle when a notification is tapped
//   void _handleNotificationTap(Map<String, dynamic> payload) {
//     if (payload.containsKey('flight_number')) {
//       final flightNumber = payload['flight_number'];
//       Get.toNamed(Routes.FLIGHT_DETAIL, arguments: {'flightNumber': flightNumber});
//     }
//   }
  
//   // Callback for iOS local notifications received
//   void _onDidReceiveLocalNotification(
//     int id, 
//     String? title, 
//     String? body, 
//     String? payload,
//   ) {
//     print('Received local notification: $id, $title, $body, $payload');
//   }
  
//   // Callback for notification response (tapped notification)
//   void _onDidReceiveNotificationResponse(NotificationResponse response) {
//     final payload = response.payload;
//     if (payload != null) {
//       final parts = payload.split('|');
//       if (parts.length >= 2 && parts[0] == 'flight') {
//         final flightNumber = parts[1];
//         Get.toNamed(Routes.FLIGHT_DETAIL, arguments: {'flightNumber': flightNumber});
//       }
//     }
//   }
  
//   // Get the user's local time zone
//   tz.TZDateTime get local {
//     if (_location == null) {
//       // Timezone not initialized yet, initialize it synchronously
//       try {
//         tz_data.initializeTimeZones();
//         _location = tz.getLocation('America/New_York');
//         tz.setLocalLocation(_location!);
//       } catch (e) {
//         print('Error getting location for TZDateTime: $e');
//         // Use UTC as fallback
//         _location = tz.UTC;
//       }
//     }
    
//     // Use the TZDateTime.now constructor which takes a Location parameter
//     final now = DateTime.now();
//     return tz.TZDateTime(
//       _location!,
//       now.year,
//       now.month,
//       now.day,
//       now.hour,
//       now.minute,
//       now.second,
//       now.millisecond,
//       now.microsecond,
//     );
//   }
  
//   // Convert DateTime to TZDateTime safely
//   tz.TZDateTime convertToTZDateTime(DateTime dateTime) {
//     // If location not initialized yet, use UTC as fallback
//     tz.Location location;
//     if (_location != null) {
//       location = _location!;
//     } else {
//       try {
//         location = tz.local;
//       } catch (e) {
//         print('Error getting local timezone: $e');
//         location = tz.UTC;
//       }
//     }
    
//     // Create a TZDateTime using the correct approach
//     return tz.TZDateTime(
//       location,
//       dateTime.year,
//       dateTime.month,
//       dateTime.day,
//       dateTime.hour,
//       dateTime.minute,
//       dateTime.second,
//       dateTime.millisecond,
//       dateTime.microsecond,
//     );
//   }
// }
