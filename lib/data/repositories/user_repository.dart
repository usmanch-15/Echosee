// lib/data/repositories/user_repository.dart
import 'dart:async';
import 'package:echo_see_companion/data/models/user_model.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> login(String email, String password);
  Future<User> signup(String name, String email, String password);
  Future<void> logout();
  Future<User> updateProfile(User user);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
  Future<void> subscribeToPremium();
  Future<void> restorePremium();
  Future<void> resetPassword(String email);
  Future<bool> isEmailAvailable(String email);
}

class LocalUserRepository implements UserRepository {
  User? _currentUser;
  final List<User> _users = [];

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));

    // Simulate authentication
    final user = _users.firstWhere(
          (u) => u.email == email && password == '123456', // Demo password
      orElse: () => throw Exception('Invalid credentials'),
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    await Future.delayed(Duration(seconds: 1));

    // Check if email exists
    if (_users.any((u) => u.email == email)) {
      throw Exception('Email already exists');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
      isPremium: false,
      preferences: {
        'theme': 'light',
        'fontSize': 16.0,
        'subtitleColor': '#FFFFFF',
        'subtitlePosition': 'center',
        'autoSave': true,
        'showSpeakerTags': true,
        'soundEffects': true,
        'vibrationFeedback': true,
      },
      usageStats: UsageStats(
        totalTranscripts: 0,
        totalMinutes: 0,
        languagesUsed: 1,
        lastActive: DateTime.now(),
        languageDistribution: {'English': 100},
        dailyUsage: {},
      ),
    );

    _users.add(user);
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User> updateProfile(User user) async {
    await Future.delayed(Duration(seconds: 1));

    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      _currentUser = user;
    }

    return user;
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await Future.delayed(Duration(milliseconds: 200));

    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(preferences: preferences);
      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        _currentUser = updatedUser;
      }
    }
  }

  @override
  Future<void> subscribeToPremium() async {
    await Future.delayed(Duration(seconds: 2));

    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        isPremium: true,
        premiumExpiry: DateTime.now().add(Duration(days: 30)), // 30-day trial
      );

      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        _currentUser = updatedUser;
      }
    }
  }

  @override
  Future<void> restorePremium() async {
    await Future.delayed(Duration(seconds: 1));
    // Simulate restore purchase
    // In real app, this would connect to app store
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(Duration(seconds: 1));
    // Simulate password reset
    print('Password reset email sent to $email');
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    await Future.delayed(Duration(milliseconds: 300));
    return !_users.any((u) => u.email == email);
  }
}