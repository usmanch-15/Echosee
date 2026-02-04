// lib/presentation/screens/transcript_list_screen.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/core/constants/app_styles.dart';
import 'package:echo_see_companion/data/models/transcript_model.dart';
import 'transcript_detail_screen.dart';

class TranscriptListScreen extends StatefulWidget {
  @override
  _TranscriptListScreenState createState() => _TranscriptListScreenState();
}

class _TranscriptListScreenState extends State<TranscriptListScreen> {
  List<Transcript> transcripts = [
    Transcript(
      id: '1',
      title: 'Team Meeting Discussion',
      content: 'We discussed the new project requirements and assigned tasks to team members.',
      date: DateTime.now().subtract(Duration(hours: 2)),
      duration: Duration(minutes: 25, seconds: 42),
      language: 'English',
      hasTranslation: true,
      speakerSegments: [
        SpeakerSegment(
          speakerId: 0,
          text: 'Hello team, welcome to today\'s meeting.',
          startTime: Duration(seconds: 0),
          endTime: Duration(seconds: 5),
        ),
        SpeakerSegment(
          speakerId: 1,
          text: 'Let\'s start with the project updates.',
          startTime: Duration(seconds: 6),
          endTime: Duration(seconds: 12),
        ),
      ],
      isStarred: true,
    ),
    Transcript(
      id: '2',
      title: 'Client Presentation',
      content: 'Presented the quarterly results to our major client.',
      date: DateTime.now().subtract(Duration(days: 1)),
      duration: Duration(minutes: 45, seconds: 18),
      language: 'Urdu',
      hasTranslation: false,
      speakerSegments: [],
      isStarred: false,
    ),
    Transcript(
      id: '3',
      title: 'Interview with Candidate',
      content: 'Technical interview for senior developer position.',
      date: DateTime.now().subtract(Duration(days: 2)),
      duration: Duration(minutes: 60, seconds: 32),
      language: 'English',
      hasTranslation: true,
      speakerSegments: [],
      isStarred: true,
    ),
    Transcript(
      id: '4',
      title: 'Lecture on AI Ethics',
      content: 'University lecture discussing ethical implications of artificial intelligence.',
      date: DateTime.now().subtract(Duration(days: 3)),
      duration: Duration(minutes: 90, seconds: 15),
      language: 'English',
      hasTranslation: false,
      speakerSegments: [],
      isStarred: false,
    ),
    Transcript(
      id: '5',
      title: 'Podcast Recording',
      content: 'Recorded episode 42 of our tech podcast.',
      date: DateTime.now().subtract(Duration(days: 5)),
      duration: Duration(minutes: 55, seconds: 27),
      language: 'English',
      hasTranslation: true,
      speakerSegments: [],
      isStarred: true,
    ),
  ];

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcript History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Storage Info Banner
          _buildStorageInfo(),

          // Filter Chips
          _buildFilterChips(),

          // Transcript List
          Expanded(
            child: _buildTranscriptList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new transcript
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                SizedBox(height: 4),
                Text(
                  '5 of 10 conversations stored',
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
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Starred', 'value': 'starred'},
      {'label': 'Translated', 'value': 'translated'},
      {'label': 'Today', 'value': 'today'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['label']!),
                selected: _selectedFilter == filter['value'],
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter['value']! : 'all';
                  });
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedFilter == filter['value']
                      ? AppColors.primary
                      : Colors.grey[700],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTranscriptList() {
    List<Transcript> filteredTranscripts = transcripts;

    // Apply filters
    if (_selectedFilter == 'starred') {
      filteredTranscripts = transcripts.where((t) => t.isStarred).toList();
    } else if (_selectedFilter == 'translated') {
      filteredTranscripts = transcripts.where((t) => t.hasTranslation).toList();
    } else if (_selectedFilter == 'today') {
      filteredTranscripts = transcripts
          .where((t) => t.date.day == DateTime.now().day)
          .toList();
    }

    if (filteredTranscripts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No transcripts found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start recording to create your first transcript',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredTranscripts.length,
      itemBuilder: (context, index) {
        return _buildTranscriptCard(filteredTranscripts[index]);
      },
    );
  }

  Widget _buildTranscriptCard(Transcript transcript) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _openTranscriptDetail(transcript);
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transcript Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Icon(
                    Icons.transcribe,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),

                SizedBox(width: 16),

                // Transcript Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              transcript.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Star Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle star
                              });
                            },
                            child: Icon(
                              transcript.isStarred
                                  ? Icons.star
                                  : Icons.star_border,
                              color: transcript.isStarred
                                  ? Colors.amber
                                  : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4),

                      // Preview Text
                      Text(
                        transcript.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      // Metadata Row
                      Row(
                        children: [
                          // Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                transcript.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 16),

                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                transcript.formattedDuration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 16),

                          // Language
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              transcript.language.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          if (transcript.hasTranslation) ...[
                            SizedBox(width: 8),
                            Icon(
                              Icons.translate,
                              size: 14,
                              color: Colors.green,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTranscriptDetail(Transcript transcript) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranscriptDetailScreen(transcript: transcript),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Search Transcripts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter keywords...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Perform search
                        Navigator.pop(context);
                      },
                      child: Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),

              // Sort Options
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text('Sort by Name'),
                trailing: Radio(
                  value: 'name',
                  groupValue: 'name',
                  onChanged: (value) {},
                ),
              ),

              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Sort by Date'),
                trailing: Radio(
                  value: 'date',
                  groupValue: 'date',
                  onChanged: (value) {},
                ),
              ),

              ListTile(
                leading: Icon(Icons.timer),
                title: Text('Sort by Duration'),
                trailing: Radio(
                  value: 'duration',
                  groupValue: 'duration',
                  onChanged: (value) {},
                ),
              ),

              SizedBox(height: 20),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}