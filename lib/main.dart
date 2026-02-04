// lib/main.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/theme/theme_provider.dart';
import 'package:echo_see_companion/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoSee Companion',
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}