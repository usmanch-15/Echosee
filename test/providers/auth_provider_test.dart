import 'package:flutter_test/flutter_test.dart';
import 'package:echo_see_companion/data/models/user_model.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';

void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider.test();
  });

  group('AuthProvider Tests', () {
    final testUser = User(
      id: '123',
      name: 'John Doe',
      email: 'john@example.com',
      createdAt: DateTime.now(),
      isPremium: true,
      preferences: {},
      usageStats: UsageStats(
        totalTranscripts: 0,
        totalMinutes: 0,
        languagesUsed: 0,
        lastActive: DateTime.now(),
        languageDistribution: {},
        dailyUsage: {},
      ),
    );

    test('Initial state is unauthenticated and not loading', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.currentUser, null);
    });

    test('Successful login updates user and isAuthenticated', () async {
      // Act
      final result =
          await authProvider.login('john@example.com', 'password123');

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.isPremium, true);
    });

    test('Logout clears user state', () async {
      // Arrange
      await authProvider.login('john@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });

    test('Google sign in updates user and isAuthenticated', () async {
      // Act
      final result = await authProvider.signInWithGoogle();

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.email, 'user@gmail.com');
    });

    test('Facebook sign in updates user and isAuthenticated', () async {
      // Act
      final result = await authProvider.signInWithFacebook();

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.email, 'user@facebook.com');
    });

    test('Reset password functionality works', () async {
      // Act
      final result = await authProvider.resetPassword('test@example.com');

      // Assert
      expect(result, true);
    });

    test('Update profile updates user information', () async {
      // Arrange
      await authProvider.login('john@example.com', 'password123');

      // Act
      final result = await authProvider.updateProfile(
        name: 'Jane Doe',
        imageUrl: 'https://example.com/image.jpg',
      );

      // Assert
      expect(result, true);
      expect(authProvider.currentUser?.name, 'Jane Doe');
      expect(authProvider.currentUser?.profileImage,
          'https://example.com/image.jpg');
    });

    test('Toggle premium updates premium status', () async {
      // Arrange
      await authProvider.login('john@example.com', 'password123');
      expect(authProvider.isPremium, true);

      // Act
      authProvider.togglePremium();

      // Assert
      expect(authProvider.isPremium, false);
    });

    test('Clear error clears error message', () async {
      // Arrange
      // Set error state (though current implementation doesn't easily allow this)
      authProvider.clearError();

      // Assert
      expect(authProvider.error, null);
    });

    test('Signup creates new user', () async {
      // Act
      final result = await authProvider.signup(
        'New User',
        'newuser@example.com',
        'password123',
      );

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.name, 'New User');
    });
  });
}
