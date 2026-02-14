import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';
import 'package:echo_see_companion/presentation/screens/settings_screen.dart';
import 'package:echo_see_companion/presentation/screens/history_screen.dart';
import 'package:echo_see_companion/presentation/screens/profile_screen.dart';
import 'package:echo_see_companion/presentation/screens/features_screen.dart';
import 'package:echo_see_companion/providers/transcript_provider.dart';
import 'package:echo_see_companion/providers/app_theme_provider.dart';
import 'package:echo_see_companion/data/models/transcript_model.dart';
import 'package:echo_see_companion/services/speech_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isRecording = false;
  String selectedLanguage = 'ENG';
  bool autoRecord = true;
  DateTime? _recordingStartTime;
  String _liveText = '';
  Timer? _liveTimer;
  StreamSubscription<String>? _liveSub;

  @override
  void dispose() {
    _liveSub?.cancel();
    _liveTimer?.cancel();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    // Load transcripts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TranscriptProvider>(context, listen: false).loadTranscripts();
      speechService.initialize();
    });

    _liveSub = speechService.textStream.listen((text) {
      if (isRecording) {
        setState(() {
          _liveText = text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: _showMenuDrawer,
        ),
        title: const Text(
          'Echo See',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Box with greeting and controls
            _buildMainBox(),

            const SizedBox(height: 25),

            // Recent Transcripts Section
            _buildRecentTranscripts(),

            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMainBox() {
    final themeProvider = Provider.of<AppThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English Greeting / Live Subtitles
          Text(
            isRecording ? 'LIVE TRANSCRIPT:' : 'Hello! How can I help you today?',
            style: TextStyle(
              fontSize: themeProvider.fontSize + (isRecording ? 0 : 6),
              fontWeight: FontWeight.bold,
              color: isRecording ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
            ),
          ),

          if (isRecording) ...[
            const SizedBox(height: 12),
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _liveText,
                  style: TextStyle(
                    fontSize: themeProvider.fontSize + 2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],

          if (!isRecording) const SizedBox(height: 8),

          // Urdu Text (if language is Urdu)
          if (selectedLanguage == 'اردو' && !isRecording)
            Text(
              'آپ کی مدد کیسے کر سکتا ہوں؟',
              style: TextStyle(
                fontSize: themeProvider.fontSize + 8,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

          const SizedBox(height: 25),

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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'ENG'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedLanguage == 'اردو'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
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

              const SizedBox(width: 16),

              // Recording Status
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRecording ? 'Recording...' : 'Listening...',
                              style: TextStyle(
                                fontSize: themeProvider.fontSize - 2,
                                fontWeight: FontWeight.w600,
                                color: isRecording ? Colors.red : Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isRecording ? 'Tap to stop' : 'Tap to start',
                              style: TextStyle(
                                fontSize: themeProvider.fontSize - 5,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
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

          const SizedBox(height: 20),

          // Record/Stop Button
          GestureDetector(
            onTap: () {
              if (isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
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
                  const SizedBox(width: 12),
                  Text(
                    isRecording ? 'STOP RECORDING' : 'START RECORDING',
                    style: TextStyle(
                      fontSize: themeProvider.fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Auto Record Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
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
                activeThumbColor: AppColors.primary,
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
    final transcriptProvider = Provider.of<TranscriptProvider>(context);
    final recentTranscripts = transcriptProvider.transcripts.take(4).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transcripts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (transcriptProvider.isLoading && recentTranscripts.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (recentTranscripts.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mic_none_outlined, 
                      size: 64, 
                      color: AppColors.primary.withOpacity(0.2)
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transcripts yet', 
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the record button to start your first live transcription session.', 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600])
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentTranscripts.map((t) => _buildTranscriptCard(t)),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard(Transcript transcript) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.description, color: AppColors.primary),
        ),
        title: Text(
          transcript.title.isNotEmpty ? transcript.title : transcript.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${transcript.formattedDate} • ${transcript.formattedDuration}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryScreen(selectedTranscriptId: transcript.id),
            ),
          );
        },
      ),
    );
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      _recordingStartTime = DateTime.now();
      _liveText = '';
    });
    
    speechService.startListening();
  }

  void _stopRecording() async {
    final duration = DateTime.now().difference(_recordingStartTime ?? DateTime.now());
    
    await speechService.stopListening();
    
    setState(() {
      isRecording = false;
    });

    // Mock transcript content creation
    final newTranscript = Transcript(
      id: 'new', // Supabase will generate UUID
      title: 'Recording ${DateTime.now().hour}:${DateTime.now().minute}',
      content: _liveText.trim(),
      date: DateTime.now(),
      duration: duration,
      language: selectedLanguage,
      speakerSegments: [
        SpeakerSegment(
          speakerId: 1,
          text: _liveText.trim(),
          startTime: Duration.zero,
          endTime: duration,
        ),
      ],
    );

    try {
      final provider = Provider.of<TranscriptProvider>(context, listen: false);
      await provider.saveTranscript(newTranscript);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcript saved!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      final provider = Provider.of<TranscriptProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save transcript: ${provider.error ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMenuDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDrawerItem(Icons.history, 'History', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            }),
            _buildDrawerItem(Icons.star, 'Features', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FeaturesScreen()));
            }),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            }),
            _buildDrawerItem(Icons.person, 'Account', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.history, 'History', false, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
          }),
          _buildNavItem(Icons.person, 'Profile', false, () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}