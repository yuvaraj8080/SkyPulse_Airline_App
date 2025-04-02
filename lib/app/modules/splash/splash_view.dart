import 'package:flight_tracker/app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Trigger auth check when screen loads
    Future.delayed(Duration.zero, () async {
      await authController.checkAuthStatus();
      Get.offAllNamed(authController.isAuthenticated ? '/home' : '/login');
    });

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo with animation
            Hero(
              tag: 'app-logo',
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            // App name with nice typography
            const Text(
              'SkyPulse',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            const Text(
              'Track flights in real-time',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}