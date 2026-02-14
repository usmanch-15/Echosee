import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:provider/provider.dart';
import 'package:echo_see_companion/presentation/screens/login_screen.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';
import 'package:echo_see_companion/data/repositories/user_repository.dart';

class MockAuthProvider extends Mock implements AuthProvider {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    
    // Stub common properties
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
    when(() => mockAuthProvider.error).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all login components', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('Shows error message when login fails', (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthProvider.login(any(), any())).thenAnswer((_) async => false);
      when(() => mockAuthProvider.error).thenReturn('Invalid credentials');

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      
      final loginButton = find.text('LOGIN');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      
      await tester.pump(); // Start the login future
      await tester.pump(); // Handle the result and trigger SnackBar
      
      // SnackBar needs time to animate
      await tester.pump(const Duration(milliseconds: 750));

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Shows loading indicator when authenticating', (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Login button should be disabled (implementation check)
      final loginButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(loginButton.onPressed, isNull);
    });

    testWidgets('Can open Forgot Password dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final forgotPasswordButton = find.text('Forgot Password?');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Link'), findsOneWidget);
    });
    group('ForgotPassword flow -', () {
      testWidgets('Can open and close dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      });

    });
  });
}
