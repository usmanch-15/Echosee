// lib/core/providers/app_theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:echo_see_companion/data/models/user_settings_model.dart';
import 'package:echo_see_companion/data/repositories/settings_repository.dart';

class AppThemeProvider extends ChangeNotifier {
  static const String FONT_SIZE_KEY = 'font_size';
  static const String DARK_THEME_KEY = 'dark_theme';
  static const String SHOW_SPEAKER_KEY = 'show_speaker';
  static const String SPEAKER_COUNT_KEY = 'speaker_count';
  static const String NOTIFICATIONS_KEY = 'notifications_enabled';
  static const String AUTO_SAVE_KEY = 'auto_save';

  // Settings state with defaults
  double _fontSize = 16.0;
  bool _isDarkTheme = false;
  bool _showSpeakerSettings = true;
  int _numberOfSpeakers = 2;
  bool _notificationsEnabled = true;
  bool _autoSave = true;

  final SettingsRepository _settingsRepository = SettingsRepository();
  final _supabase = Supabase.instance.client;

  AppThemeProvider() {
    _loadPreferences();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn || data.event == AuthChangeEvent.signedOut) {
        _loadPreferences();
      }
    });
  }

  // Getters
  double get fontSize => _fontSize;
  bool get isDarkTheme => _isDarkTheme;
  bool get showSpeakerSettings => _showSpeakerSettings;
  int get numberOfSpeakers => _numberOfSpeakers;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSave => _autoSave;

  // Load preferences from storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _fontSize = prefs.getDouble(FONT_SIZE_KEY) ?? 16.0;
      _isDarkTheme = prefs.getBool(DARK_THEME_KEY) ?? false;
      _showSpeakerSettings = prefs.getBool(SHOW_SPEAKER_KEY) ?? true;
      _numberOfSpeakers = prefs.getInt(SPEAKER_COUNT_KEY) ?? 2;
      _notificationsEnabled = prefs.getBool(NOTIFICATIONS_KEY) ?? true;
      _autoSave = prefs.getBool(AUTO_SAVE_KEY) ?? true;

      notifyListeners();

      // Sync with Supabase if logged in
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final cloudSettings = await _settingsRepository.getSettings(userId);
        if (cloudSettings != null) {
          _isDarkTheme = cloudSettings.theme == 'dark';
          _notificationsEnabled = cloudSettings.notificationsEnabled;
          _autoSave = cloudSettings.autoSave;
          
          _fontSize = (cloudSettings.preferences['font_size'] ?? _fontSize).toDouble();
          _showSpeakerSettings = cloudSettings.preferences['show_speaker'] ?? _showSpeakerSettings;
          _numberOfSpeakers = cloudSettings.preferences['speaker_count'] ?? _numberOfSpeakers;
          
          // Save back to local to keep in sync
          await _saveLocalPreferences();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> _saveLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(FONT_SIZE_KEY, _fontSize);
    await prefs.setBool(DARK_THEME_KEY, _isDarkTheme);
    await prefs.setBool(SHOW_SPEAKER_KEY, _showSpeakerSettings);
    await prefs.setInt(SPEAKER_COUNT_KEY, _numberOfSpeakers);
    await prefs.setBool(NOTIFICATIONS_KEY, _notificationsEnabled);
    await prefs.setBool(AUTO_SAVE_KEY, _autoSave);
  }

  // Save preferences to storage
  Future<void> _savePreferences() async {
    try {
      await _saveLocalPreferences();

      // Sync to Supabase if logged in
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final settings = UserSettings(
          userId: user.id,
          theme: _isDarkTheme ? 'dark' : 'light',
          notificationsEnabled: _notificationsEnabled,
          autoSave: _autoSave,
          preferences: {
            'font_size': _fontSize,
            'show_speaker': _showSpeakerSettings,
            'speaker_count': _numberOfSpeakers,
          },
        );
        await _settingsRepository.saveSettings(settings);
      }
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  // Setters
  void setFontSize(double size) {
    _fontSize = size;
    _savePreferences();
    notifyListeners();
  }

  void setDarkTheme(bool value) {
    _isDarkTheme = value;
    _savePreferences();
    notifyListeners();
  }

  void setShowSpeakerSettings(bool value) {
    _showSpeakerSettings = value;
    _savePreferences();
    notifyListeners();
  }

  void setNumberOfSpeakers(int number) {
    _numberOfSpeakers = number;
    _savePreferences();
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _savePreferences();
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _autoSave = value;
    _savePreferences();
    notifyListeners();
  }

  void resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(FONT_SIZE_KEY);
      await prefs.remove(DARK_THEME_KEY);
      await prefs.remove(SHOW_SPEAKER_KEY);
      await prefs.remove(SPEAKER_COUNT_KEY);
      await prefs.remove(NOTIFICATIONS_KEY);
      await prefs.remove(AUTO_SAVE_KEY);

      _fontSize = 16.0;
      _isDarkTheme = false;
      _showSpeakerSettings = true;
      _numberOfSpeakers = 2;
      _notificationsEnabled = true;
      _autoSave = true;

      _savePreferences(); // Also syncs to cloud if online
      notifyListeners();
    } catch (e) {
      print('Error resetting preferences: $e');
    }
  }

  // Theme data getters
  ThemeData get themeData => isDarkTheme ? darkThemeData : lightThemeData;

  ThemeData get lightThemeData => ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: _fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: _fontSize + 12, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: _fontSize + 10, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: _fontSize + 8, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: _fontSize + 6, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: _fontSize + 2, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: _fontSize + 1, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: _fontSize),
      bodyMedium: TextStyle(fontSize: _fontSize - 1),
      bodySmall: TextStyle(fontSize: _fontSize - 2),
      labelLarge: TextStyle(fontSize: _fontSize),
      labelSmall: TextStyle(fontSize: _fontSize - 3),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  ThemeData get darkThemeData => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: _fontSize + 4,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: _fontSize + 12, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: _fontSize + 10, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: _fontSize + 8, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: _fontSize + 6, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: _fontSize + 2, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: _fontSize + 1, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: _fontSize),
      bodyMedium: TextStyle(fontSize: _fontSize - 1),
      bodySmall: TextStyle(fontSize: _fontSize - 2),
      labelLarge: TextStyle(fontSize: _fontSize),
      labelSmall: TextStyle(fontSize: _fontSize - 3),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.blue,
      ),
    ),
    dividerColor: Colors.grey[700], dialogTheme: DialogThemeData(backgroundColor: Colors.grey[800]),
  );
}