import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/live_transcription/controllers/live_transcription_controller.dart';
import 'features/live_transcription/presentation/live_transcription_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoCApp());
}

class EcoCApp extends StatelessWidget {
  const EcoCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LiveTranscriptionController()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoC',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
          scaffoldBackgroundColor: const Color(0xFFF2F5F7),
          useMaterial3: true,
        ),
        home: const LiveTranscriptionScreen(),
      ),
    );
  }
}
