import 'package:flutter/material.dart';
import 'sound_recognition_screen.dart';
import 'lip_tracking_screen.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Features'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFeatureCard(
              context,
              'Sound Recognition',
              'Identify sirens, alarms, and environmental sounds in real-time.',
              Icons.hearing,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoundRecognitionScreen())),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              'Lip Tracking',
              'Extract localized mouth ROI for visual speech recognition.',
              Icons.face,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LipTrackingScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}