import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isPremium => _currentUser?.isPremium ?? false;

  AuthProvider() {
    // Initialize as not authenticated
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
  }

  AuthProvider.test() {
    // Test constructor
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate login - always succeed for now
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Test User',
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
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate signup - always succeed for now
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: 'signup_1',
        email: email,
        name: name,
        createdAt: DateTime.now(),
        isPremium: false,
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
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _isAuthenticated = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: 'google_1',
        email: 'user@gmail.com',
        name: 'Google User',
        createdAt: DateTime.now(),
        isPremium: false,
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
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: 'facebook_1',
        email: 'user@facebook.com',
        name: 'Facebook User',
        createdAt: DateTime.now(),
        isPremium: false,
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
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate password reset
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({required String name, String? imageUrl}) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate profile update
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = User(
        id: _currentUser!.id,
        name: name,
        email: _currentUser!.email,
        profileImage: imageUrl,
        createdAt: _currentUser!.createdAt,
        isPremium: _currentUser!.isPremium,
        premiumExpiry: _currentUser!.premiumExpiry,
        preferences: _currentUser!.preferences,
        usageStats: _currentUser!.usageStats,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void togglePremium() {
    if (_currentUser == null) return;

    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      email: _currentUser!.email,
      profileImage: _currentUser!.profileImage,
      createdAt: _currentUser!.createdAt,
      isPremium: !_currentUser!.isPremium,
      premiumExpiry: _currentUser!.isPremium
          ? null
          : DateTime.now().add(const Duration(days: 30)),
      preferences: _currentUser!.preferences,
      usageStats: _currentUser!.usageStats,
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
