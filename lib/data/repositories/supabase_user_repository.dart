// lib/data/repositories/supabase_user_repository.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:echo_see_companion/data/models/user_model.dart';

import 'package:echo_see_companion/core/constants/keys.dart';
import 'user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  @override
  Future<User?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final response = await _client
        .from('users')
        .select()
        .eq('id', session.user.id)
        .single();
    
    // Get preferences from settings table
    final settingsResponse = await _client
        .from('settings')
        .select()
        .eq('user_id', session.user.id)
        .single();

    // Map Supabase data to our User model
    return User(
      id: response['id'],
      name: response['name'] ?? '',
      email: response['email'] ?? '',
      profileImage: response['profile_image'],
      createdAt: DateTime.parse(response['created_at']),
      isPremium: response['is_premium'] ?? false,
      premiumExpiry: response['premium_expiry'] != null 
          ? DateTime.parse(response['premium_expiry']) 
          : null,
      preferences: settingsResponse['preferences'] ?? {},
      usageStats: UsageStats(
        totalTranscripts: 0,
        totalMinutes: 0,
        languagesUsed: 0,
        lastActive: DateTime.now(),
        languageDistribution: {},
        dailyUsage: {},
      ),
    );
  }

  @override
  Future<User> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    final user = await getCurrentUser();
    if (user == null) throw Exception('User data not found');
    return user;
  }

  @override
  Future<User> signup(String name, String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );

    if (response.user == null) {
      throw Exception('Signup failed');
    }

    // Wait for trigger to create user entry
    await Future.delayed(Duration(seconds: 1));

    final user = await getCurrentUser();
    if (user == null) throw Exception('User data not found after signup');
    return user;
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<User> updateProfile(User user) async {
    await _client.from('users').update({
      'name': user.name,
      'profile_image': user.profileImage,
    }).eq('id', user.id);

    return user;
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('settings').update({
      'preferences': preferences,
    }).eq('user_id', userId);
  }

  @override
  Future<void> subscribeToPremium() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('users').update({
      'is_premium': true,
      'premium_expiry': DateTime.now().add(Duration(days: 30)).toIso8601String(),
    }).eq('id', userId);
  }

  @override
  Future<void> restorePremium() async {
    // In real app, this would verify store purchase
    // For now, we'll just refresh user data
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    // Supabase doesn't have a direct check without signing in
    // Usually handled by signup failing if email exists
    return true;
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      print('DEBUG: Starting native Google Sign-In...');
      final googleSignIn = GoogleSignIn(
        serverClientId: AppKeys.googleWebClientId,
      );
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('DEBUG: Native Google Sign-In cancelled by user or failed (googleUser is null).');
        return;
      }

      print('DEBUG: Native Google Sign-In successful for user: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print('DEBUG: No ID Token found in native Google Sign-In.');
        throw Exception('No ID Token found.');
      }

      print('DEBUG: Signing in to Supabase with ID Token...');
      await _client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      print('DEBUG: Supabase login with ID Token successful!');
    } catch (e) {
      print('DEBUG: Native Google Sign-In failed with error: $e');
      print('DEBUG: Falling back to Supabase OAuth...');
      await _client.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
        redirectTo: 'io.supabase.echosee://login-callback',
      );
    }
  }

  @override
  Future<void> signInWithFacebook() async {
    await _client.auth.signInWithOAuth(
      supabase.OAuthProvider.facebook,
      redirectTo: 'io.supabase.echosee://login-callback',
    );
  }
}
