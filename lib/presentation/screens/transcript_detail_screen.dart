// lib/presentation/screens/transcript_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/core/constants/app_styles.dart';
import 'package:echo_see_companion/data/models/transcript_model.dart';

class TranscriptDetailScreen extends StatefulWidget {
  final Transcript transcript;

  const TranscriptDetailScreen({
    super.key,
    required this.transcript,
  });

  @override
  _TranscriptDetailScreenState createState() => _TranscriptDetailScreenState();
}

class _TranscriptDetailScreenState extends State<TranscriptDetailScreen> {
  bool _isExpanded = false;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTranscript,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),

            // Content Section
            _buildContentSection(),

            // Speaker Segments
            if (widget.transcript.speakerSegments.isNotEmpty)
              _buildSpeakerSegments(),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.transcript.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Star Button
              IconButton(
                icon: Icon(
                  widget.transcript.isStarred
                      ? Icons.star
                      : Icons.star_border,
                  color: widget.transcript.isStarred
                      ? Colors.amber
                      : Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    // Toggle star
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Metadata Row
          Row(
            children: [
              _buildMetadataItem(
                icon: Icons.calendar_today,
                text: widget.transcript.formattedDate,
              ),

              const SizedBox(width: 16),

              _buildMetadataItem(
                icon: Icons.timer,
                text: widget.transcript.formattedDuration,
              ),

              const SizedBox(width: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.transcript.language,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (widget.transcript.hasTranslation) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 14,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Translated',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transcript Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Content with Read More
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: Text(
              widget.transcript.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.transcript.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),

          if (widget.transcript.content.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Read Less' : 'Read More',
                style: const TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpeakerSegments() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Speaker Segments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.transcript.speakerSegments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final segment = widget.transcript.speakerSegments[index];
              return _buildSpeakerSegment(segment, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerSegment(SpeakerSegment segment, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.speakerColors[segment.speakerId % AppColors.speakerColors.length]
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border(
          left: BorderSide(
            color: AppColors.speakerColors[segment.speakerId % AppColors.speakerColors.length],
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.speakerColors[segment.speakerId % AppColors.speakerColors.length],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${segment.speakerId + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Speaker ${segment.speakerId + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                _formatDuration(segment.startTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            segment.text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Duration: ${_formatDuration(segment.endTime - segment.startTime)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Play Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(_isPlaying ? 'Pause' : 'Play Audio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Export Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _exportTranscript,
              icon: const Icon(Icons.download),
              label: const Text('Export'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareTranscript() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Transcript'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_snippet, color: AppColors.primary),
                title: const Text('Share as Text'),
                onTap: () {
                  Navigator.pop(context);
                  // Share as text
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPDF();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audio_file, color: Colors.green),
                title: const Text('Export Audio'),
                onTap: () {
                  Navigator.pop(context);
                  // Export audio
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Transcript'),
                onTap: () {
                  Navigator.pop(context);
                  // Edit transcript
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.green),
                title: const Text('Translate'),
                onTap: () {
                  Navigator.pop(context);
                  // Translate
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTranscript();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportTranscript() {
    // Show export options
    _shareTranscript();
  }

  void _exportAsPDF() {
    // PDF export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting as PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteTranscript() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transcript'),
          content: const Text('Are you sure you want to delete this transcript? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transcript deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}