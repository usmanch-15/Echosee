import 'dart:async';
import 'package:flutter/material.dart';
import 'package:echosee/presentation/screens/login_screen.dart'; // Path check karein

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds baad login screen par le jaye ga
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aapka purana design yahan rahega
    return Scaffold(
      body: Center(child: Text("ECHOSEE - by Areeba Ghafoor")),
    );
  }
}