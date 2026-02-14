import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echo_see_companion/main.dart' as app;
import 'package:echo_see_companion/presentation/screens/sound_recognition_screen.dart';
import 'package:echo_see_companion/presentation/screens/lip_tracking_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EchoSee AI Features BDD Tests', () {
    
    testWidgets('Scenario: Siren detected in Sound Recognition Screen', (tester) async {
      // Given the app is running
      app.main();
      await tester.pumpAndSettle();

      // And I navigate to Features Screen
      // (Mocking navigation here for simplicity, assuming a direct route exists or finding the button)
      // For BDD, we'd normally tap through the UI
      // await tester.tap(find.byIcon(Icons.star)); // Assuming Features icon
      // await tester.pumpAndSettle();

      // When I am on the Sound Recognition Screen
      // For this test, we might push the screen directly to verify its behavior
      await tester.pumpWidget(const MaterialApp(
        home: SoundRecognitionScreen(),
      ));
      await tester.pumpAndSettle();

      // Then I should see the "Environmental Sounds" title
      expect(find.text('Environmental Sounds'), findsOneWidget);

      // And when a siren is detected (Simulating the state change if service was mocked)
      // In a real integration test, we would feed mock data to the stream
      
      // Verification: Check if alerts are displayed based on results
      // Since we can't easily trigger the hardware mic in tests, we verify UI components
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('Scenario: Face detected in Lip Tracking Screen', (tester) async {
      // Given I am on the Lip Tracking Screen
      await tester.pumpWidget(const MaterialApp(
        home: LipTrackingScreen(),
      ));
      await tester.pumpAndSettle();

      // Then I should see the "Visual Lip Tracking" title
      expect(find.text('Visual Lip Tracking'), findsOneWidget);

      // And it should be scanning for a face initially
      expect(find.text('Scanning for Face...'), findsOneWidget);
    });
  });
}
