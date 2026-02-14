// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import '../../providers/app_theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Font size options
  final List<Map<String, dynamic>> _fontSizeOptions = [
    {'label': 'Small', 'size': 14.0},
    {'label': 'Medium', 'size': 16.0},
    {'label': 'Large', 'size': 18.0},
    {'label': 'Extra Large', 'size': 20.0},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: themeProvider.fontSize + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Size Settings
            _buildSettingSection(
              themeProvider: themeProvider,
              title: 'Font Size',
              icon: Icons.text_fields,
              child: Column(
                children: [
                  Slider(
                    value: themeProvider.fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    label: _getFontSizeLabel(themeProvider.fontSize),
                    onChanged: (value) {
                      themeProvider.setFontSize(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _fontSizeOptions.map((option) {
                      return _buildFontSizeOption(
                        label: option['label'],
                        size: option['size'],
                        isSelected: themeProvider.fontSize == option['size'],
                        onTap: () {
                          themeProvider.setFontSize(option['size']);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkTheme ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: themeProvider.fontSize - 2,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hello! This is how your text will appear.',
                          style: TextStyle(
                            fontSize: themeProvider.fontSize,
                            color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Theme Settings
            _buildSettingSection(
              themeProvider: themeProvider,
              title: 'Theme',
              icon: Icons.palette,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: themeProvider.fontSize),
                    ),
                    subtitle: Text(
                      themeProvider.isDarkTheme ? 'Dark theme enabled' : 'Light theme enabled',
                      style: TextStyle(
                        fontSize: themeProvider.fontSize - 2,
                        color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    value: themeProvider.isDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(value);
                    },
                    secondary: Icon(
                      themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                      color: themeProvider.isDarkTheme ? Colors.amber : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkTheme ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeProvider.isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Light Theme',
                                style: TextStyle(
                                  fontSize: themeProvider.fontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bright interface for daytime use',
                                style: TextStyle(
                                  fontSize: themeProvider.fontSize - 4,
                                  color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Theme',
                                style: TextStyle(
                                  fontSize: themeProvider.fontSize - 2,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Easy on eyes for nighttime use',
                                style: TextStyle(
                                  fontSize: themeProvider.fontSize - 4,
                                  color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Speaker Settings
            _buildSettingSection(
              themeProvider: themeProvider,
              title: 'Speaker Settings',
              icon: Icons.person,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Show Speaker Settings',
                      style: TextStyle(fontSize: themeProvider.fontSize),
                    ),
                    subtitle: Text(
                      themeProvider.showSpeakerSettings ? 'Visible in app' : 'Hidden from app',
                      style: TextStyle(
                        fontSize: themeProvider.fontSize - 2,
                        color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    value: themeProvider.showSpeakerSettings,
                    onChanged: (value) {
                      themeProvider.setShowSpeakerSettings(value);
                    },
                    secondary: Icon(
                      themeProvider.showSpeakerSettings ? Icons.visibility : Icons.visibility_off,
                      color: themeProvider.showSpeakerSettings ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (themeProvider.showSpeakerSettings) ...[
                    Text(
                      'Number of Speakers',
                      style: TextStyle(
                        fontSize: themeProvider.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [1, 2, 3, 4].map((number) {
                        return _buildSpeakerOption(
                          number: number,
                          isSelected: themeProvider.numberOfSpeakers == number,
                          onTap: () {
                            themeProvider.setNumberOfSpeakers(number);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkTheme ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: themeProvider.isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Speaker Configuration',
                            style: TextStyle(
                              fontSize: themeProvider.fontSize - 2,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Currently set to ${themeProvider.numberOfSpeakers} speaker${themeProvider.numberOfSpeakers > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: themeProvider.fontSize - 2),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(themeProvider.numberOfSpeakers, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.speakerColors[index % AppColors.speakerColors.length],
                                  child: Text(
                                    'S${index + 1}',
                                    style: TextStyle(
                                      fontSize: themeProvider.fontSize - 6,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
 
            const SizedBox(height: 24),

            // Notification Settings
            _buildSettingSection(
              themeProvider: themeProvider,
              title: 'General Settings',
              icon: Icons.settings,
              child: Column(
                children: [
                   SwitchListTile(
                    title: Text(
                      'Notifications',
                      style: TextStyle(fontSize: themeProvider.fontSize),
                    ),
                    subtitle: Text(
                      'Receive important updates',
                      style: TextStyle(fontSize: themeProvider.fontSize - 2),
                    ),
                    value: themeProvider.notificationsEnabled,
                    onChanged: (value) {
                      themeProvider.setNotificationsEnabled(value);
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Auto-Save',
                      style: TextStyle(fontSize: themeProvider.fontSize),
                    ),
                    subtitle: Text(
                      'Automatically save transcripts',
                      style: TextStyle(fontSize: themeProvider.fontSize - 2),
                    ),
                    value: themeProvider.autoSave,
                    onChanged: (value) {
                      themeProvider.setAutoSave(value);
                    },
                    secondary: const Icon(Icons.save_outlined),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Preferences Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => _savePreferences(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: themeProvider.fontSize),
                    const SizedBox(width: 12),
                    Text(
                      'Sync Settings to Cloud',
                      style: TextStyle(
                        fontSize: themeProvider.fontSize + 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Reset to Defaults
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: () => _resetToDefaults(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Reset to Default Settings',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required AppThemeProvider themeProvider,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkTheme ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: themeProvider.fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption({
    required String label,
    required double size,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${size.toInt()}pt',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerOption({
    required int number,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 14) return 'Small';
    if (size <= 16) return 'Medium';
    if (size <= 18) return 'Large';
    return 'Extra Large';
  }

  void _savePreferences(BuildContext context) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefaults(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}