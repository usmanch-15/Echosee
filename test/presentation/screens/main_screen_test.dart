import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:echo_see_companion/presentation/screens/main_screen.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';
import 'package:echo_see_companion/providers/app_theme_provider.dart';
import 'package:echo_see_companion/data/models/transcript_model.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockTranscriptProvider extends Mock implements TranscriptProvider {}
class MockAppThemeProvider extends Mock implements AppThemeProvider {}

void main() {
  late MockAuthProvider mockAuth;
  late MockTranscriptProvider mockTranscript;
  late MockAppThemeProvider mockTheme;

  setUp(() {
    mockAuth = MockAuthProvider();
    mockTranscript = MockTranscriptProvider();
    mockTheme = MockAppThemeProvider();

    when(() => mockAuth.isPremium).thenReturn(false);
    when(() => mockAuth.isLoading).thenReturn(false);
    when(() => mockTheme.fontSize).thenReturn(16.0);
    when(() => mockTheme.isDarkTheme).thenReturn(false);
    
    // Stub TranscriptProvider methods
    when(() => mockTranscript.loadTranscripts(limit: any(named: 'limit'))).thenAnswer((_) async => {});
    when(() => mockTranscript.transcripts).thenReturn([]);
    when(() => mockTranscript.isLoading).thenReturn(false);
    
    // Default theme data for Provider
    when(() => mockTheme.themeData).thenReturn(ThemeData.light());
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuth),
        ChangeNotifierProvider<TranscriptProvider>.value(value: mockTranscript),
        ChangeNotifierProvider<AppThemeProvider>.value(value: mockTheme),
      ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  group('MainScreen BDD Tests -', () {
    testWidgets('Should show "Start Recording" initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('START RECORDING'), findsOneWidget);
      expect(find.text('LIVE TRANSCRIPT:'), findsNothing);
    });

    testWidgets('Should toggle to "Stop Recording" and show live transcript header on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.tap(find.text('START RECORDING'));
      await tester.pump(); // Start animation
      
      expect(find.text('STOP RECORDING'), findsOneWidget);
      expect(find.text('LIVE TRANSCRIPT:'), findsOneWidget);
    });

    testWidgets('Stopping recording should call saveTranscript', (WidgetTester tester) async {
      registerFallbackValue(FakeTranscript());
      when(() => mockTranscript.saveTranscript(any())).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Start
      await tester.tap(find.text('START RECORDING'));
      await tester.pump();
      
      // Stop
      await tester.tap(find.text('STOP RECORDING'));
      await tester.pump();
      
      verify(() => mockTranscript.saveTranscript(any())).called(1);
    });

    testWidgets('Should show red SnackBar if saveTranscript fails (Day 7 Scenario)', (WidgetTester tester) async {
      registerFallbackValue(FakeTranscript());
      when(() => mockTranscript.saveTranscript(any())).thenThrow(Exception('Network Error'));
      when(() => mockTranscript.error).thenReturn('No internet connection. Please check your network.');

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Start recording
      await tester.tap(find.text('START RECORDING'));
      await tester.pump();
      
      // Stop recording - this should trigger the save which fails
      await tester.tap(find.text('STOP RECORDING'));
      await tester.pump(); // Start the save process
      await tester.pump(const Duration(milliseconds: 500)); // Wait for snackbar to start showing
      
      expect(find.text('Failed to save transcript: No internet connection. Please check your network.'), findsOneWidget);
      
      // Verify SnackBar color
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });
  });
}

class FakeTranscript extends Fake implements Transcript {}
