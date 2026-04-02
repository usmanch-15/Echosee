// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Supabase import
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/app_theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/transcript_provider.dart';
import 'core/utils/navigation_service.dart';
import 'presentation/screens/ai_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Supabase initialize
  await Supabase.initialize(
    url: 'https://bzsqhbyotxouppzwyift.supabase.co', // tumhara Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6c3FoYnlvdHhvdXBwend5aWZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NTg0MDgsImV4cCI6MjA4NjIzNDQwOH0.XPzxS7isEC3jIRw58XfNVvr2qrtyw8F1E68y5D0OG7o',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
      ],
      child: Consumer2<AppThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: 'Echo See',
            debugShowCheckedModeBanner: false,

            // 🔥 VERY IMPORTANT
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: '/', // Splash se start
            onGenerateRoute: NavigationService.onGenerateRoute,

            theme: themeProvider.themeData,
          );
        },
      ),
    );
  }
}
