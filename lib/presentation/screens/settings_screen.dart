// lib/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  double _fontSize = 16.0; // Default font size
  bool _isDarkTheme = false;
  bool _showSpeakerSettings = true;
  int _numberOfSpeakers = 2;

  // Font size options
  final List<Map<String, dynamic>> _fontSizeOptions = [
    {'label': 'Small', 'size': 14.0},
    {'label': 'Medium', 'size': 16.0},
    {'label': 'Large', 'size': 18.0},
    {'label': 'Extra Large', 'size': 20.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Size Settings
            _buildSettingSection(
              title: 'Font Size',
              icon: Icons.text_fields,
              child: Column(
                children: [
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    label: _getFontSizeLabel(_fontSize),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _fontSizeOptions.map((option) {
                      return _buildFontSizeOption(
                        label: option['label'],
                        size: option['size'],
                        isSelected: _fontSize == option['size'],
                        onTap: () {
                          setState(() {
                            _fontSize = option['size'];
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hello! This is how your text will appear.',
                          style: TextStyle(
                            fontSize: _fontSize,
                            color: _isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Theme Settings
            _buildSettingSection(
              title: 'Theme',
              icon: Icons.palette,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      _isDarkTheme ? 'Dark theme enabled' : 'Light theme enabled',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    value: _isDarkTheme,
                    onChanged: (value) {
                      setState(() {
                        _isDarkTheme = value;
                      });
                    },
                    secondary: Icon(
                      _isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                      color: _isDarkTheme ? Colors.amber : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Bright interface for daytime use',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Theme',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Easy on eyes for nighttime use',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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

            SizedBox(height: 24),

            // Speaker Settings
            _buildSettingSection(
              title: 'Speaker Settings',
              icon: Icons.person,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Show Speaker Settings',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      _showSpeakerSettings ? 'Visible in app' : 'Hidden from app',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    value: _showSpeakerSettings,
                    onChanged: (value) {
                      setState(() {
                        _showSpeakerSettings = value;
                      });
                    },
                    secondary: Icon(
                      _showSpeakerSettings ? Icons.visibility : Icons.visibility_off,
                      color: _showSpeakerSettings ? Colors.green : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_showSpeakerSettings) ...[
                    Text(
                      'Number of Speakers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [1, 2, 3, 4].map((number) {
                        return _buildSpeakerOption(
                          number: number,
                          isSelected: _numberOfSpeakers == number,
                          onTap: () {
                            setState(() {
                              _numberOfSpeakers = number;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Speaker Configuration',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Currently set to $_numberOfSpeakers speaker${_numberOfSpeakers > 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: List.generate(_numberOfSpeakers, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.speakerColors[index % AppColors.speakerColors.length],
                                  child: Text(
                                    'S${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
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

            SizedBox(height: 32),

            // Save Preferences Button
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 22),
                    SizedBox(width: 12),
                    Text(
                      'Save Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Reset to Defaults
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: _resetToDefaults,
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Reset to Default Settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
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
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkTheme ? Colors.grey[800] : Colors.white,
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
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            SizedBox(height: 4),
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

  void _savePreferences() {
    // Here you would typically save to shared preferences or your state management
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preferences saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Apply settings globally
    _applyGlobalSettings();
  }

  void _applyGlobalSettings() {
    // This is where you would apply settings globally
    // For example, using Provider or another state management solution

    // Apply theme
    // You would typically use something like:
    // ThemeProvider.of(context).setTheme(_isDarkTheme ? ThemeMode.dark : ThemeMode.light);

    // Apply font size globally
    // You would typically pass this to your app's theme

    print('Settings applied:');
    print('- Font Size: $_fontSize');
    print('- Dark Theme: $_isDarkTheme');
    print('- Show Speaker Settings: $_showSpeakerSettings');
    print('- Number of Speakers: $_numberOfSpeakers');
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _fontSize = 16.0;
                _isDarkTheme = false;
                _showSpeakerSettings = true;
                _numberOfSpeakers = 2;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to default'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}