import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_config.dart';

import 'features/live_transcription/controllers/live_transcription_controller.dart';
import 'features/live_transcription/presentation/live_transcription_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/app_theme_provider.dart';
import 'providers/transcript_provider.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );
  runApp(const EchoseeApp());
}

class EchoseeApp extends StatelessWidget {
  const EchoseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
        ChangeNotifierProvider(
          create: (_) => LiveTranscriptionController()..initialize(),
        ),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Echosee',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00796B),
              ),
              scaffoldBackgroundColor: const Color(0xFFF2F5F7),
              useMaterial3: true,
              textTheme: TextTheme(
                bodyMedium: TextStyle(fontSize: themeProvider.fontSize),
              ),
            ),
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isAuthenticated) {
                  return const SplashScreen(
                    nextScreen: LiveTranscriptionScreen(),
                  );
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
