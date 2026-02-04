// lib/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/presentation/screens/premium_features_screen.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transcripts;
  final String? selectedTranscriptId;

  HistoryScreen({
    required this.transcripts,
    this.selectedTranscriptId,
  });

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Map<String, dynamic>> _transcripts;
  String? _selectedId;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _transcripts = List.from(widget.transcripts);
    _selectedId = widget.selectedTranscriptId;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTranscripts = _isSearching && _searchController.text.isNotEmpty
        ? _transcripts.where((transcript) =>
        transcript['text'].toLowerCase().contains(_searchController.text.toLowerCase()))
        : _transcripts;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _transcripts),
        ),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search transcripts...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
          },
        )
            : Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.star, color: Colors.amber),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumFeaturesScreen()),
                );
              },
              tooltip: 'Premium Features',
            ),
        ],
      ),
      body: Column(
        children: [
          // Premium Banner (only if user is not premium)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.amber[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Unlock unlimited history with Premium',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PremiumFeaturesScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'UPGRADE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transcript count
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filteredTranscripts.length} Transcript${filteredTranscripts.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (filteredTranscripts.isNotEmpty)
                      Text(
                        'Limited to 10 transcripts in free version',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                if (filteredTranscripts.isNotEmpty)
                  TextButton.icon(
                    onPressed: _exportAllTranscripts,
                    icon: Icon(Icons.download, size: 18),
                    label: Text('Export All'),
                  ),
              ],
            ),
          ),

          // Transcripts List
          Expanded(
            child: filteredTranscripts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _isSearching && _searchController.text.isNotEmpty
                        ? 'No matching transcripts found'
                        : 'No transcripts yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isSearching && _searchController.text.isNotEmpty
                        ? 'Try a different search term'
                        : 'Start recording to create transcripts',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.mic),
                    label: Text('Start Recording'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredTranscripts.length,
              itemBuilder: (context, index) {
                final transcript = filteredTranscripts.elementAt(index);
                return _buildTranscriptItem(transcript, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptItem(Map<String, dynamic> transcript, int index) {
    final isSelected = _selectedId == transcript['id'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.description,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              transcript['text'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  '${transcript['time']} • ${transcript['date']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show lock icon for transcripts beyond limit in free version
                if (index >= 10)
                  Icon(
                    Icons.lock_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                if (index < 10)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteTranscript(transcript['id']),
                  ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    isSelected ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    if (index >= 10) {
                      // Show premium upgrade dialog for locked transcripts
                      _showPremiumUpgradeDialog();
                    } else {
                      setState(() {
                        _selectedId = isSelected ? null : transcript['id'];
                      });
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              if (index >= 10) {
                // Show premium upgrade dialog for locked transcripts
                _showPremiumUpgradeDialog();
              } else {
                setState(() {
                  _selectedId = isSelected ? null : transcript['id'];
                });
              }
            },
          ),

          // Expanded content
          if (isSelected && index < 10)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Full Transcript:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    transcript['fullText'] ?? transcript['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyToClipboard(transcript['fullText'] ?? transcript['text']),
                        icon: Icon(Icons.copy, size: 18),
                        label: Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _shareTranscript(transcript),
                        icon: Icon(Icons.share, size: 18),
                        label: Text('Share'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _editTranscript(transcript),
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showPremiumUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 10),
              Text('Upgrade to Premium'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This transcript requires Premium subscription.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 10),
              Text(
                'With Premium you get:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              _buildFeatureList('✓ Unlimited transcript history'),
              _buildFeatureList('✓ No ads'),
              _buildFeatureList('✓ Export in multiple formats'),
              _buildFeatureList('✓ Priority support'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumFeaturesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: Text('View Plans'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureList(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        feature,
        style: TextStyle(fontSize: 12),
      ),
    );
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
                  _transcripts.removeWhere((item) => item['id'] == id);
                  if (_selectedId == id) {
                    _selectedId = null;
                  }
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

  void _deleteAllTranscripts() {
    if (_transcripts.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete All Transcripts'),
          content: Text('Are you sure you want to delete all ${_transcripts.length} transcripts? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _transcripts.clear();
                  _selectedId = null;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All transcripts deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    // In a real app, you would use: Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareTranscript(Map<String, dynamic> transcript) {
    // In a real app, you would use the share plugin
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Share Transcript'),
          content: Text('Share "${transcript['text']}"?'),
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
                    content: Text('Transcript shared'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _editTranscript(Map<String, dynamic> transcript) {
    TextEditingController controller = TextEditingController(text: transcript['fullText'] ?? transcript['text']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Transcript'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Transcript Text',
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
              onPressed: () {
                setState(() {
                  final int index = _transcripts.indexWhere((item) => item['id'] == transcript['id']);
                  if (index != -1) {
                    _transcripts[index]['fullText'] = controller.text;
                    if (_transcripts[index]['text'].length > 50) {
                      _transcripts[index]['text'] = controller.text.substring(0, 50) + '...';
                    } else {
                      _transcripts[index]['text'] = controller.text;
                    }
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transcript updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _exportAllTranscripts() {
    // Check if user can export (only first 10 in free version)
    final exportableTranscripts = _transcripts.take(10).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Export Transcripts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Export ${exportableTranscripts.length} transcripts as a file?'),
              if (_transcripts.length > 10)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Note: Free version limits export to first 10 transcripts. Upgrade to Premium for unlimited exports.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                    ),
                  ),
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
                  SnackBar(
                    content: Text('${exportableTranscripts.length} transcripts exported'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Export'),
            ),
            if (_transcripts.length > 10)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PremiumFeaturesScreen()),
                  );
                },
                child: Text(
                  'Upgrade',
                  style: TextStyle(color: Colors.amber[800]),
                ),
              ),
          ],
        );
      },
    );
  }
}