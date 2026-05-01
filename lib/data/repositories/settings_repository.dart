// lib/data/repositories/settings_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:echosee/data/models/user_settings_model.dart';

class SettingsRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<UserSettings?> getSettings(String userId) async {
    try {
      final response = await _client
          .from('settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return UserSettings.fromSupabase(response);
    } catch (e) {
      print('Error fetching settings: $e');
      rethrow;
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      await _client
          .from('settings')
          .upsert(settings.toSupabase());
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }
}
