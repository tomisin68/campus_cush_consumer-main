import 'dart:async';
import 'package:flutter/material.dart';
import 'package:campus_cush_consumer/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer to navigate to onboarding screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logo.jpg', // Make sure to add your logo in assets and update pubspec.yaml
              height: 150,
              width: 150,
            ),

            const SizedBox(height: 30),

            // Deep blue loading indicator
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D47A1)), // Deep blue color
                strokeWidth: 5,
              ),
            ),

            const SizedBox(height: 20),

            // App version
            const Text(
              'Version 1.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
