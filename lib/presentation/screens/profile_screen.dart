// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/core/constants/app_strings.dart';
import 'package:echo_see_companion/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _user;
  bool _isLoading = false;

  // Add computed properties to handle the missing fields
  int get _transcriptsCount => 42;
  int get _totalRecordingTime => 86400; // 24 hours
  bool get _hasPremium => _user.isPremium;
  List<String> get _recentLanguages => ['English', 'Urdu'];
  String get _formattedTotalRecordingTime {
    final hours = _totalRecordingTime ~/ 3600;
    final minutes = (_totalRecordingTime % 3600) ~/ 60;
    return '$hours hours $minutes minutes';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: 500));

    // Mock user data - adjust according to your actual User model
    // _user = User(
    //   id: 'user_123',
    //   name: 'Usman Saeed',
    //   email: 'usman@gmail.com',
    //   profileImage: null,
    //   createdAt: DateTime.now().subtract(Duration(days: 60)),
    //   isPremium: true,
    //   premiumExpiry: DateTime.now().add(Duration(days: 15)),
    //   preferences: {
    //     'theme': 'Dark',
    //     'fontSize': 20.0,
    //     'autoSave': true,
    //     'showSpeakerTags': true,
    //     'soundEffects': true,
    //   },
    // );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Statistics Section
            _buildStatisticsSection(),

            // Preferences Section
            _buildPreferencesSection(),

            // Account Actions
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: _user.profileImage != null
                ? CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(_user.profileImage!),
            )
                : Text(
              _getInitials(_user.name),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: 20),

          // User Info
          Text(
            _user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 8),

          Text(
            _user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),

          SizedBox(height: 16),

          // Premium Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _hasPremium ? Colors.amber : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasPremium ? Icons.star : Icons.star_border,
                  color: _hasPremium ? Colors.black : AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  _hasPremium ? 'PREMIUM USER' : 'FREE USER',
                  style: TextStyle(
                    color: _hasPremium ? Colors.black : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (_hasPremium && _user.premiumExpiry != null)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Expires in ${DateTime.now().difference(_user.premiumExpiry!).inDays.abs()} days',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    // Create mock usage stats
    final stats = {
      'totalTranscripts': _transcriptsCount,
      'totalMinutes': _totalRecordingTime ~/ 60,
      'languagesUsed': _recentLanguages.length,
      'averageDailyMinutes': (_totalRecordingTime / 60) / 60, // Assuming 60 days
    };

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: 20),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                icon: Icons.description,
                value: stats['totalTranscripts'].toString(),
                label: 'Transcripts',
              ),
              _buildStatCard(
                icon: Icons.timer,
                value: stats['totalMinutes'].toString(),
                label: 'Minutes',
              ),
              _buildStatCard(
                icon: Icons.language,
                value: stats['languagesUsed'].toString(),
                label: 'Languages',
              ),
              _buildStatCard(
                icon: Icons.trending_up,
                value: stats['averageDailyMinutes']!.toStringAsFixed(1),
                label: 'Avg Daily (min)',
              ),
            ],
          ),

          SizedBox(height: 20),

          // Language Distribution
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language Usage',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),
              ..._recentLanguages.asMap().entries.map((entry) {
                final index = entry.key;
                final language = entry.value;
                final percentage = [50, 30, 20][index % 3]; // Mock percentages

                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          language,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    final prefs = _user.preferences ?? {};

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: 16),

          // Preferences List
          Column(
            children: [
              _buildPreferenceItem(
                icon: Icons.palette,
                label: 'Theme',
                value: prefs['theme']?.toString() ?? 'Light',
              ),
              _buildPreferenceItem(
                icon: Icons.text_fields,
                label: 'Font Size',
                value: '${prefs['fontSize']?.toString() ?? '16'}pt',
              ),
              _buildPreferenceItem(
                icon: Icons.auto_awesome,
                label: 'Auto Save',
                value: (prefs['autoSave'] ?? true) ? 'On' : 'Off',
              ),
              _buildPreferenceItem(
                icon: Icons.person,
                label: 'Speaker Tags',
                value: (prefs['showSpeakerTags'] ?? true) ? 'On' : 'Off',
              ),
              _buildPreferenceItem(
                icon: Icons.notifications,
                label: 'Notifications',
                value: (prefs['soundEffects'] ?? true) ? 'On' : 'Off',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_hasPremium)
            ElevatedButton.icon(
              onPressed: _goPremium,
              icon: Icon(Icons.star),
              label: Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),

          SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _viewSubscription,
            icon: Icon(Icons.subscriptions),
            label: Text('View Subscription'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: AppColors.primary),
            ),
          ),

          SizedBox(height: 12),

          TextButton.icon(
            onPressed: _exportData,
            icon: Icon(Icons.download),
            label: Text('Export All Data'),
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),

          SizedBox(height: 20),

          // App Version
          Text(
            'App Version: 1.0.0',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  _getInitials(_user.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _user.name),
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _user.email),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated')),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _goPremium() {
    Navigator.pushNamed(context, '/premium');
  }

  void _viewSubscription() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Subscription Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Plan: ${_hasPremium ? 'Premium' : 'Free'}'),
              SizedBox(height: 12),
              if (_hasPremium && _user.premiumExpiry != null)
                Text('Expires: ${_user.premiumExpiry!.toString().substring(0, 10)}'),
              SizedBox(height: 12),
              Text('Transcripts: $_transcriptsCount'),
              Text('Recording Time: $_formattedTotalRecordingTime'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Export Data'),
          content: Text('Export all your transcripts and settings?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data exported successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Export'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}