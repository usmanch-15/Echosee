import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/presentation/screens/signup_screen.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.error).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const SignupScreen(),
      ),
    );
  }

  group('SignupScreen Widget Tests', () {
    testWidgets('Renders all signup fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('Signup button is disabled if terms not accepted', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final signupButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('CREATE ACCOUNT'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(signupButton.onPressed, isNull);
    });

    testWidgets('Can toggle terms and conditions checkpoint', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find checkpoint - it's a Checkbox
      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      final buttonText = find.text('CREATE ACCOUNT');
      await tester.ensureVisible(buttonText);
      final signupButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: buttonText,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(signupButton.onPressed, isNotNull);
    });
  });
}
