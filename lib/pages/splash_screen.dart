import 'package:flutter/material.dart';
import 'package:tracknow/pages/signup_page.dart';
import 'dart:async';
// Ensure this import is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds and then navigate to LoginPage
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/bus-stop.PNG', width: 150,
                errorBuilder: (context, error, stackTrace) {
              return const Text("Image not found",
                  style: TextStyle(color: Colors.white));
            }), // App Logo with error handling
            const SizedBox(height: 20),
            const CircularProgressIndicator(
                color: Colors.white), // Loading animation
          ],
        ),
      ),
    );
  }
}
