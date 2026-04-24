import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AuthProvider? _authProvider;
  VoidCallback? _authListener;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForAuthAndNavigate();
    });
  }

  void _waitForAuthAndNavigate() {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    _authProvider = authProvider;

    if (!authProvider.isLoading) {
      _navigateToNextScreen(authProvider.isAuthenticated);
      return;
    }

    _authListener = () {
      if (!mounted || _hasNavigated) return;

      final updatedAuthProvider = context.read<AuthProvider>();
      if (!updatedAuthProvider.isLoading) {
        _navigateToNextScreen(updatedAuthProvider.isAuthenticated);
      }
    };

    authProvider.addListener(_authListener!);
  }

  Future<void> _navigateToNextScreen(bool isAuthenticated) async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      isAuthenticated ? '/home' : '/login',
      (route) => false,
    );
  }

  @override
  void dispose() {
    final authListener = _authListener;
    final authProvider = _authProvider;
    if (authListener != null && authProvider != null) {
      authProvider.removeListener(authListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Aik premium dark gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Agar logo nahi hai to icon use kar lein
                    Icon(Icons.auto_awesome, size: 80, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "ECHOSEE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
