// lib/presentation/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/presentation/screens/settings_screen.dart';

import 'history_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> recentTranscripts = [
    {'id': '1', 'text': 'Team meeting about Q4 goals', 'time': '10:30 AM', 'date': 'Today', 'fullText': 'Team meeting about Q4 goals and objectives. We discussed the upcoming projects and deadlines.'},
    {'id': '2', 'text': 'Doctor appointment notes', 'time': 'Yesterday', 'date': '2:15 PM', 'fullText': 'Doctor appointment notes: Blood pressure normal, need to follow up in 3 months.'},
    {'id': '3', 'text': 'Grocery shopping list', 'time': 'Dec 10', 'date': '11:00 AM', 'fullText': 'Grocery shopping list: Milk, eggs, bread, vegetables, fruits, and snacks.'},
    {'id': '4', 'text': 'Project brainstorming session', 'time': 'Dec 8', 'date': '3:45 PM', 'fullText': 'Project brainstorming session for the new mobile application features and UI design.'},
  ];

  bool isRecording = false;
  String selectedLanguage = 'ENG';
  bool autoRecord = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30),
          onPressed: _showMenuDrawer,
        ),
        title: Text(
          'Echo See',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Box with greeting and controls
            _buildMainBox(),

            SizedBox(height: 25),

            // Recent Transcripts Section
            _buildRecentTranscripts(),

            SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainBox() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English Greeting
          Text(
            'Hello! How can I help you today?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 8),

          // Urdu Text (if language is Urdu)
          if (selectedLanguage == 'اردو')
            Text(
              'آپ کا کیا حال ہے؟ آپ کی کس طرح مدد کر سکتا ہوں؟',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.right,
            ),

          SizedBox(height: 24),

          // Language Toggle and Recording Status
          Row(
            children: [
              // Language Toggle Button
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'ENG';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'ENG'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'ENG',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selectedLanguage == 'ENG'
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.primary,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'اردو';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'اردو'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'اردو',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selectedLanguage == 'اردو'
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Recording Status
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecording ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRecording ? Icons.mic : Icons.mic_none,
                        color: isRecording ? Colors.red : Colors.green,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRecording ? 'Recording...' : 'Listening...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isRecording ? Colors.red : Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isRecording ? 'Tap to stop' : 'Tap to start',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Record/Stop Button
          GestureDetector(
            onTap: () {
              setState(() {
                isRecording = !isRecording;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    isRecording ? 'STOP RECORDING' : 'START RECORDING',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Auto Record Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Auto Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: autoRecord,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    autoRecord = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTranscripts() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transcripts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _viewAllTranscripts,
                child: Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...recentTranscripts.map((transcript) {
            return GestureDetector(
              onTap: () => _viewTranscript(transcript),
              child: Card(
                margin: EdgeInsets.only(bottom: 10),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.description, color: AppColors.primary),
                  ),
                  title: Text(
                    transcript['text'],
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${transcript['time']} • ${transcript['date']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteTranscript(transcript['id']),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomAppBar(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Icon
            _buildBottomNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: true,
              onTap: () {},
            ),
            // Settings Icon
            _buildBottomNavItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: false,
              onTap: _navigateToSettings,
            ),
            // Transcript Icon
            _buildBottomNavItem(
              icon: Icons.description,
              label: 'Transcript',
              isSelected: false,
              onTap: _viewAllTranscripts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDrawer() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Menu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              _buildMenuOption(
                icon: Icons.account_circle,
                title: 'Accounts',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to accounts screen
                },
              ),
              _buildMenuOption(
                icon: Icons.history,
                title: 'History',
                onTap: _viewAllTranscripts,
              ),
              _buildMenuOption(
                icon: Icons.featured_play_list,
                title: 'Features',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to features screen
                },
              ),
              _buildMenuOption(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSettings();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[800],
                ),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: AppColors.primary),
      title: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _viewAllTranscripts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen(transcripts: recentTranscripts)),
    ).then((value) {
      if (value != null && value is List) {
        setState(() {
          recentTranscripts = List<Map<String, dynamic>>.from(value);
        });
      }
    });
  }

  void _viewTranscript(Map<String, dynamic> transcript) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(
          transcripts: recentTranscripts,
          selectedTranscriptId: transcript['id'],
        ),
      ),
    ).then((value) {
      if (value != null && value is List) {
        setState(() {
          recentTranscripts = List<Map<String, dynamic>>.from(value);
        });
      }
    });
  }

  void _deleteTranscript(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Transcript'),
          content: Text('Are you sure you want to delete this transcript?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  recentTranscripts.removeWhere((item) => item['id'] == id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transcript deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}