import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/core/constants/app_strings.dart';
import 'package:echo_see_companion/data/models/user_model.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get _hasPremium => Provider.of<AuthProvider>(context, listen: false).currentUser?.isPremium ?? false;
  
  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '$hours hours $minutes minutes';
    } else if (minutes > 0) {
      return '$minutes minutes $seconds seconds';
    } else {
      return '$seconds seconds';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Current user is already managed by AuthProvider
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transcriptProvider = Provider.of<TranscriptProvider>(context);
    final user = authProvider.currentUser;
    final transcripts = transcriptProvider.transcripts;
    
    final transcriptsCount = transcripts.length;
    final totalSeconds = transcripts.fold(0, (sum, t) => sum + t.duration.inSeconds);
    final formattedTime = _formatDuration(totalSeconds);
    
    final recentLanguages = transcripts.isEmpty 
        ? ['English'] 
        : transcripts.map((t) => t.language).toSet().toList().take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editProfile(user),
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),

            // Statistics Section
            _buildStatisticsSection(transcriptsCount, formattedTime, recentLanguages),

            // Preferences Section
            _buildPreferencesSection(user),

            // Account Actions
            _buildAccountActions(),
          ],
        ),
      ),
  Widget _buildProfileHeader(User? user) {
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
            child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                ? CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(user.profileImage!),
            )
                : Text(
              user?.initials ?? '?',
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
            user?.name ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 8),

          Text(
            user?.email ?? '',
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

          if (_hasPremium && user?.premiumExpiry != null)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Expires in ${user!.premiumExpiry!.difference(DateTime.now()).inDays.abs()} days',
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

  Widget _buildStatisticsSection(int count, String time, List<String> languages) {
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
                value: count.toString(),
                label: 'Transcripts',
              ),
              _buildStatCard(
                icon: Icons.timer,
                value: time.split(' ')[0], // Simple minutes display
                label: 'Time',
              ),
              _buildStatCard(
                icon: Icons.language,
                value: languages.length.toString(),
                label: 'Languages',
              ),
              _buildStatCard(
                icon: Icons.trending_up,
                value: '85%',
                label: 'Accuracy',
              ),
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
  Widget _buildPreferencesSection(User? user) {
    final prefs = user?.preferences ?? {};
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
          _buildPreferenceItem(
            icon: Icons.palette,
            label: 'Theme',
            value: prefs['theme']?.toString() ?? 'Light',
          ),
          _buildPreferenceItem(
            icon: Icons.person,
            label: 'Speaker Tags',
            value: (prefs['showSpeakerTags'] ?? true) ? 'On' : 'Off',
          ),
          _buildPreferenceItem(
            icon: Icons.notifications,
            label: 'Notifications',
            value: (prefs['notifications'] ?? true) ? 'On' : 'Off',
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

          SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            label: Text('Logout'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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

  void _editProfile(User? user) {
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final imageController = TextEditingController(text: user.profileImage);
    final emailController = TextEditingController(text: user.email);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'Profile Image URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await auth.updateProfile(
                  name: nameController.text.trim(),
                  imageUrl: imageController.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
              if (_hasPremium && _user?.premiumExpiry != null)
                Text('Expires: ${_user!.premiumExpiry!.toString().substring(0, 10)}'),
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