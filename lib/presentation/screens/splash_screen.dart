import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextScreen,
    this.duration = const Duration(seconds: 3), 
  });

  final Widget? nextScreen;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.nextScreen != null) {
      _timer = Timer(widget.duration, () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => widget.nextScreen!,
            transitionDuration: const Duration(milliseconds: 800), // Smoother transition
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E82D5), // Aapka primary theme color
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _SplashContent(),
            ),
            // Niche loading indicator add kiya hai taake screen interactive lage
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentWidth = math.min(width - 32, 340).toDouble();
        final glassesWidth = contentWidth * 0.65; // Thora bada kiya logo ko

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            SizedBox(
              width: glassesWidth,
              height: glassesWidth * 0.45,
              child: const CustomPaint(
                painter: _GlassesPainter(),
              ),
            ),
            const SizedBox(height: 30), // Better spacing
            // App Name
            const Text(
              'Echosee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52, // Professional bold size
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            // Tagline
            Text(
              'Your Personal Task Assistant', // Professional tagline
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

