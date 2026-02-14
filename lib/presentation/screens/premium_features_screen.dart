import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';

class PremiumFeaturesScreen extends StatelessWidget {
  const PremiumFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isPremium = authProvider.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Features'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.star,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              isPremium ? 'You are a Premium User!' : 'Upgrade to Echo See Premium',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Unlock the full power of transcription and translation.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildFeatureRow(
              Icons.history,
              'Unlimited History',
              'Keep all your transcripts forever.',
            ),
            _buildFeatureRow(
              Icons.translate,
              'Voice Translation',
              'Translate transcripts into 50+ languages.',
            ),
            _buildFeatureRow(
              Icons.person_add,
              'Speaker Labeling',
              'Assign names to different speakers.',
            ),
            _buildFeatureRow(
              Icons.file_download,
              'Advanced Export',
              'Export to PDF, DOCX, and more.',
            ),
            const SizedBox(height: 50),
            if (authProvider.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () => authProvider.togglePremium(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPremium ? Colors.grey : Colors.amber,
                  foregroundColor: isPremium ? Colors.white : Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isPremium ? 'Downgrade (Mock)' : 'Upgrade Now - \$9.99/mo',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}