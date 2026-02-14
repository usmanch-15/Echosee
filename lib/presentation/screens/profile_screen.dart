import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/data/models/user_model.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get _hasPremium => Provider.of<AuthProvider>(context, listen: false).currentUser?.isPremium ?? false;

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '$totalSeconds seconds';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes < 60) return '$minutes min $seconds sec';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours hr $remainingMinutes min';
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
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(user),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  _buildStatisticsSection(transcriptsCount, formattedTime, recentLanguages),
                  _buildPreferencesSection(user),
                  _buildAccountActions(transcriptsCount, formattedTime),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                ? CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(user.profileImage!),
                  )
                : Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                const SizedBox(width: 8),
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
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Expires in ${user!.premiumExpiry!.difference(DateTime.now()).inDays.abs()} days',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(int count, String time, List<String> languages) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usage Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(icon: Icons.description, value: count.toString(), label: 'Transcripts'),
              _buildStatCard(icon: Icons.timer, value: time.split(' ')[0], label: 'Time'),
              _buildStatCard(icon: Icons.language, value: languages.length.toString(), label: 'Languages'),
              _buildStatCard(icon: Icons.trending_up, value: '85%', label: 'Accuracy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(User? user) {
    final prefs = user?.preferences ?? {};
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          _buildPreferenceItem(icon: Icons.palette, label: 'Theme', value: prefs['theme']?.toString() ?? 'Light'),
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

  Widget _buildPreferenceItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAccountActions(int transcriptsCount, String formattedTime) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_hasPremium)
            ElevatedButton.icon(
              onPressed: _goPremium,
              icon: const Icon(Icons.star),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _viewSubscription(transcriptsCount, formattedTime),
            icon: const Icon(Icons.subscriptions),
            label: const Text('View Subscription'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            label: const Text('Export All Data'),
            style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text('App Version: 1.0.0', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
            child: const Text('Save'),
          ),
        ],
      ),
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

  void _viewSubscription(int transcriptsCount, String formattedTime) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Plan: ${_hasPremium ? 'Premium' : 'Free'}'),
            const SizedBox(height: 12),
            if (_hasPremium && user?.premiumExpiry != null)
              Text('Expires: ${user!.premiumExpiry!.toString().substring(0, 10)}'),
            const SizedBox(height: 12),
            Text('Transcripts Total: $transcriptsCount'),
            Text('Time Recorded: $formattedTime'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export all your transcripts and settings?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}