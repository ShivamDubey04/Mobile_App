import 'dart:async';
import 'package:c_app/onBoard/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    /// Navigate after 2.5 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔹 Gradient Background (modern)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🔹 Logo (replace with your logo)
              Image.asset("assets/logo.png", height: 100),
              SizedBox(height: 20),

              /// 🔹 App Name
              Text(
                "Codolog",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              /// 🔹 Tagline
              Text(
                "Build. Learn. Grow.",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
