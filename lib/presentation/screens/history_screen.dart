// lib/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';
import 'package:echo_see_companion/providers/auth_provider.dart';
import 'package:echo_see_companion/data/models/transcript_model.dart';
import 'package:echo_see_companion/providers/app_theme_provider.dart';
import 'package:echo_see_companion/presentation/screens/premium_features_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String? selectedTranscriptId;

  const HistoryScreen({super.key, this.selectedTranscriptId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedTranscriptId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TranscriptProvider>(context, listen: false).loadTranscripts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transcriptProvider = Provider.of<TranscriptProvider>(context);
    final isPremium = Provider.of<AuthProvider>(context).isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportAllTranscripts(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isPremium) _buildPremiumBanner(),
          Expanded(
            child: _buildTranscriptList(transcriptProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.amber[100],
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Free version stores only the last 5 transcripts. Upgrade for unlimited history.',
              style: TextStyle(fontSize: 12, color: Colors.amber[900]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen()),
              );
            },
            child: const Text('UPGRADE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptList(TranscriptProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.loadTranscripts(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.transcripts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No transcripts yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.transcripts.length,
      itemBuilder: (context, index) {
        final transcript = provider.transcripts[index];
        return _buildTranscriptItem(transcript, index);
      },
    );
  }

  Widget _buildTranscriptItem(Transcript transcript, int index) {
    final isSelected = _selectedId == transcript.id;

    final themeProvider = Provider.of<AppThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.description, color: AppColors.primary),
            ),
            title: Text(
              transcript.title.isNotEmpty ? transcript.title : transcript.content,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: themeProvider.fontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${transcript.formattedDate} • ${transcript.formattedDuration}',
              style: TextStyle(fontSize: themeProvider.fontSize - 3),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    transcript.isStarred ? Icons.star : Icons.star_border,
                    color: transcript.isStarred ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => Provider.of<TranscriptProvider>(context, listen: false).toggleStar(transcript.id),
                ),
                Icon(isSelected ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedId = isSelected ? null : transcript.id;
              });
            },
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    transcript.content,
                    style: TextStyle(
                      fontSize: themeProvider.fontSize - 1,
                      height: 1.5,
                    ),
                  ),
                  if (transcript.speakerSegments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Speakers (Tap to name):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _buildSpeakerList(transcript),
                  ],
                  if (transcript.hasTranslation) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.translate, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Translation (${transcript.translatedLanguage})',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            transcript.translatedContent ?? '',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.copy, 'Copy', () => _copyToClipboard(transcript.content)),
                      _buildActionButton(Icons.share, 'Share', () => _shareTranscript(transcript)),
                      _buildActionButton(
                        Icons.translate, 
                        transcript.hasTranslation ? 'Re-translate' : 'Translate', 
                        () {
                          final isPrem = Provider.of<AuthProvider>(context, listen: false).isPremium;
                          if (isPrem) {
                            _showTranslateDialog(transcript);
                          } else {
                            _showPremiumUpgradeDialog('Translation');
                          }
                        }
                      ),
                      _buildActionButton(Icons.delete_outline, 'Delete', () => _deleteTranscript(transcript.id), color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color ?? AppColors.primary),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(fontSize: 10, color: color ?? AppColors.primary)),
      ],
    );
  }

  Widget _buildSpeakerList(Transcript transcript) {
    final Map<int, String> speakerMap = {};
    for (var segment in transcript.speakerSegments) {
      if (!speakerMap.containsKey(segment.speakerId)) {
        speakerMap[segment.speakerId] = segment.speakerName ?? 'Speaker ${segment.speakerId}';
      }
    }

    return Wrap(
      spacing: 8,
      children: speakerMap.entries.map((entry) {
        return ActionChip(
          avatar: CircleAvatar(
            backgroundColor: AppColors.speakerColors[entry.key % AppColors.speakerColors.length],
            child: Text('${entry.key}', style: const TextStyle(fontSize: 10, color: Colors.white)),
          ),
          label: Text(entry.value),
          onPressed: () {
            final isPrem = Provider.of<AuthProvider>(context, listen: false).isPremium;
            if (isPrem) {
              _editSpeakerName(transcript.id, entry.key, entry.value);
            } else {
              _showPremiumUpgradeDialog('Speaker Labeling');
            }
          },
        );
      }).toList(),
    );
  }

  void _showPremiumUpgradeDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: Text('$feature is only available for Premium users. Upgrade now to unlock all features!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumFeaturesScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _editSpeakerName(String transcriptId, int speakerId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Name Speaker $speakerId'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Roman'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Provider.of<TranscriptProvider>(context, listen: false)
                  .updateSpeakerName(transcriptId, speakerId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTranslateDialog(Transcript transcript) {
    final languages = [
      {'name': 'Spanish', 'code': 'ES'},
      {'name': 'French', 'code': 'FR'},
      {'name': 'German', 'code': 'DE'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translate to...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(lang['name']!),
            onTap: () {
              Navigator.pop(context);
              Provider.of<TranscriptProvider>(context, listen: false)
                  .translateTranscript(transcript.id, lang['code']!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translating...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareTranscript(Transcript transcript) {
    // Implement share logic
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
  }

  void _deleteTranscript(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transcript'),
        content: const Text('Are you sure you want to delete this transcript?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Provider.of<TranscriptProvider>(context, listen: false).deleteTranscript(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportAllTranscripts() {
    // Implement export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}