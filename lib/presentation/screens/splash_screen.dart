// lib/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _currentIndex = 0;
  bool _isSkipped = false;

  // Different splash screen themes
  final List<Map<String, dynamic>> _splashScreens = [
    {
      'title': 'Simple & Clean',
      'subtitle': 'Getting Started',
      'icon': Icons.hearing,
      'backgroundColor': Color(0xFF4CAF50),
      'textColor': Colors.white,
      'hasGlasses': false,
      'hasGreeting': false,
    },
    {
      'title': 'EchoSee',
      'subtitle': 'Voice to Text Companion',
      'icon': Icons.volume_up,
      'backgroundColor': Color(0xFF2196F3),
      'textColor': Colors.white,
      'hasGlasses': false,
      'hasGreeting': false,
    },
    {
      'title': 'EchoSee',
      'subtitle': 'See What You Hear',
      'icon': Icons.visibility,
      'backgroundColor': Color(0xFF9C27B0),
      'textColor': Colors.white,
      'hasGlasses': true,
      'hasGreeting': false,
    },
    {
      'title': 'EchoSee',
      'subtitle': 'Your Smart Assistant',
      'icon': Icons.visibility,
      'backgroundColor': Color(0xFFFF9800),
      'textColor': Colors.white,
      'hasGlasses': true,
      'hasGreeting': true,
    },
    {
      'title': 'ECHOSEE',
      'subtitle': 'Hello! How can I help you?',
      'icon': Icons.bolt,
      'backgroundColor': Colors.black,
      'textColor': Color(0xFF00FFFF),
      'glowColor': Color(0xFF00FF00),
      'hasGlasses': true,
      'hasGreeting': true,
      'isNeon': true,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Auto navigate to next splash screen every 2 seconds
    _startAutoNavigation();
  }

  void _startAutoNavigation() {
    Future.delayed(Duration(seconds: 2), () {
      if (_isSkipped) return;

      if (_currentIndex < _splashScreens.length - 1) {
        setState(() {
          _currentIndex++;
          _controller.reset();
          _controller.forward();
        });
        _startAutoNavigation();
      } else {
        // Last screen, navigate to login
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _skipToLogin() {
    setState(() {
      _isSkipped = true;
    });
    _navigateToLogin();
  }

  void _nextScreen() {
    if (_currentIndex < _splashScreens.length - 1) {
      setState(() {
        _currentIndex++;
        _controller.reset();
        _controller.forward();
      });
    } else {
      _navigateToLogin();
    }
  }

  void _previousScreen() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _splashScreens[_currentIndex];
    final bool isNeon = currentScreen['isNeon'] ?? false;

    return Scaffold(
      backgroundColor: currentScreen['backgroundColor'],
      body: Stack(
        children: [
          // Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _skipToLogin,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Progress Dots
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_splashScreens.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),

          // Navigation Buttons
          if (_currentIndex > 0)
            Positioned(
              left: 20,
              bottom: 100,
              child: FloatingActionButton.small(
                onPressed: _previousScreen,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),

          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _nextScreen,
              backgroundColor: Colors.white,
              child: Icon(
                _currentIndex == _splashScreens.length - 1
                    ? Icons.check
                    : Icons.arrow_forward,
                color: currentScreen['backgroundColor'],
              ),
            ),
          ),

          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon/Glasses
                    if (currentScreen['hasGlasses'])
                      _buildGlassesIcon(currentScreen, isNeon)
                    else
                      _buildSimpleIcon(currentScreen, isNeon),

                    SizedBox(height: 30),

                    // Title
                    if (isNeon)
                      _buildNeonText(
                        currentScreen['title'],
                        fontSize: 42,
                        color: currentScreen['textColor'],
                      )
                    else
                      Text(
                        currentScreen['title'],
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: currentScreen['textColor'],
                          letterSpacing: currentScreen['title'] == 'ECHOSEE' ? 3.0 : 1.5,
                          shadows: isNeon ? [
                            Shadow(
                              color: currentScreen['textColor']!,
                              blurRadius: 20.0,
                            ),
                          ] : [],
                        ),
                      ),

                    SizedBox(height: 10),

                    // Subtitle
                    if (currentScreen['subtitle'] != null)
                      if (isNeon)
                        _buildNeonText(
                          currentScreen['subtitle'],
                          fontSize: 18,
                          color: currentScreen['glowColor'],
                        )
                      else
                        Text(
                          currentScreen['subtitle'],
                          style: TextStyle(
                            fontSize: 18,
                            color: currentScreen['textColor'].withOpacity(0.9),
                            fontStyle: currentScreen['hasGreeting'] ? FontStyle.italic : FontStyle.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),

                    // Additional greeting for screen 4
                    if (currentScreen['hasGreeting'] && !isNeon)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'Hello! How can I help you?',
                          style: TextStyle(
                            fontSize: 16,
                            color: currentScreen['textColor'].withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Neon glow effect for neon theme
          if (isNeon)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        currentScreen['textColor']!.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: [0.1, 0.8],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleIcon(Map<String, dynamic> screen, bool isNeon) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isNeon ? Colors.transparent : Colors.white,
        shape: BoxShape.circle,
        boxShadow: isNeon ? [
          BoxShadow(
            color: screen['textColor']!.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        screen['icon'],
        size: 60,
        color: isNeon ? screen['textColor'] : screen['backgroundColor'],
      ),
    );
  }

  Widget _buildGlassesIcon(Map<String, dynamic> screen, bool isNeon) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: isNeon ? Colors.transparent : Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isNeon ? screen['textColor']!.withOpacity(0.5) : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isNeon ? [
          BoxShadow(
            color: screen['textColor']!.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ] : [],
      ),
      child: Icon(
        Icons.visibility,
        size: 70,
        color: isNeon ? screen['textColor'] : Colors.white,
      ),
    );
  }

  Widget _buildNeonText(String text, {required double fontSize, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15.0,
            spreadRadius: 3.0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 2.0,
          shadows: [
            Shadow(
              color: color,
              blurRadius: 20.0,
            ),
            Shadow(
              color: color.withOpacity(0.5),
              blurRadius: 40.0,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}