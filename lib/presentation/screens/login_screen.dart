

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echosee/core/constants/app_colors.dart';
import 'package:echosee/presentation/screens/signup_screen.dart';
import 'package:echosee/presentation/screens/main_screen.dart';
import 'package:echosee/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'usman@gmail.com';
    _passwordController.text = '123456';

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.hearing,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to Echosee',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // 1. Modern Input Fields
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15), // Munasib Gap
                
                _buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
                
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15), // Munasib Gap

                // 2. Bold and Modern Login Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55, // Size thora bada kiya
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, // Font size barhaya
                                  fontWeight: FontWeight.bold, // Text Bold kiya
                                ),
                              ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or Continue with',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.g_translate, 'Google', () {}),
                    const SizedBox(width: 16),
                    _buildSocialButton(Icons.facebook, 'Facebook', () {}),
                    const SizedBox(width: 16),
                    _buildSocialButton(Icons.apple, 'Apple', () {}),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Create account',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
  }) {
    // 3. Updated Decoration with OutlineInputBorder
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter your $label',
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12), 
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }
}