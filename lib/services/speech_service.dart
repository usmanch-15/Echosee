// lib/services/speech_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

enum SpeechRecognitionState {
  notStarted,
  listening,
  processing,
  stopped,
  error,
}

class SpeechService {
  SpeechRecognitionState _state = SpeechRecognitionState.notStarted;
  StreamController<String> _textStream = StreamController<String>.broadcast();
  StreamController<SpeechRecognitionState> _stateStream =
  StreamController<SpeechRecognitionState>.broadcast();
  StreamController<double> _confidenceStream = StreamController<double>.broadcast();

  List<String> _recognizedText = [];
  Timer? _simulationTimer;
  List<String> _mockConversation = [
    "Hello, welcome to EchoSee Companion App!",
    "This is a demonstration of real-time speech recognition.",
    "You can see subtitles appearing as you speak.",
    "The app supports multiple languages including English and Urdu.",
    "Try speaking into your microphone to see live transcription.",
    "Premium users can access translation features.",
    "Speaker identification helps distinguish between multiple speakers.",
    "All transcripts are saved for future reference.",
    "You can export transcripts in various formats.",
    "Thank you for using EchoSee Companion!",
  ];
  int _mockIndex = 0;

  Stream<String> get textStream => _textStream.stream;
  Stream<SpeechRecognitionState> get stateStream => _stateStream.stream;
  Stream<double> get confidenceStream => _confidenceStream.stream;
  SpeechRecognitionState get currentState => _state;
  List<String> get recognizedText => List.from(_recognizedText);

  Future<void> initialize() async {
    await Future.delayed(Duration(milliseconds: 500));
    _updateState(SpeechRecognitionState.notStarted);
    return;
  }

  Future<void> startListening() async {
    if (_state == SpeechRecognitionState.listening) return;

    _updateState(SpeechRecognitionState.listening);
    _recognizedText.clear();

    // Simulate real-time speech recognition
    _simulationTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (_mockIndex < _mockConversation.length) {
        final text = _mockConversation[_mockIndex];
        _recognizedText.add(text);
        _textStream.add(text);
        _confidenceStream.add(0.85 + (_mockIndex % 5) * 0.03);
        _mockIndex++;
      } else {
        timer.cancel();
        stopListening();
      }
    });
  }

  Future<void> stopListening() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _mockIndex = 0;

    if (_state == SpeechRecognitionState.listening) {
      _updateState(SpeechRecognitionState.processing);

      await Future.delayed(Duration(seconds: 1));

      _updateState(SpeechRecognitionState.stopped);
    }
  }

  Future<void> pauseListening() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _updateState(SpeechRecognitionState.stopped);
  }

  Future<void> resumeListening() async {
    if (_state == SpeechRecognitionState.stopped) {
      await startListening();
    }
  }

  void clearText() {
    _recognizedText.clear();
    _textStream.add('');
  }

  Future<List<String>> getAvailableLanguages() async {
    await Future.delayed(Duration(milliseconds: 300));
    return [
      'English',
      'Urdu',
      'Arabic',
      'French',
      'Chinese',
      'Spanish',
      'German',
      'Japanese',
      'Korean',
      'Russian',
    ];
  }

  Future<void> setLanguage(String languageCode) async {
    await Future.delayed(Duration(milliseconds: 200));
    print('Language set to: $languageCode');
  }

  Future<bool> checkPermissions() async {
    await Future.delayed(Duration(milliseconds: 300));
    return true; // Mock permission granted
  }

  Future<void> requestPermissions() async {
    await Future.delayed(Duration(seconds: 1));
    // Mock permission request
  }

  // Speaker identification simulation
  List<Map<String, dynamic>> identifySpeakers(List<String> transcript) {
    final speakers = <Map<String, dynamic>>[];
    int currentSpeaker = 0;

    for (int i = 0; i < transcript.length; i++) {
      if (i > 0 && i % 3 == 0) {
        currentSpeaker = (currentSpeaker + 1) % 3;
      }

      speakers.add({
        'speakerId': currentSpeaker,
        'text': transcript[i],
        'confidence': 0.8 + (i % 5) * 0.04,
        'timestamp': DateTime.now().add(Duration(seconds: i * 2)),
      });
    }

    return speakers;
  }

  Future<List<String>> processOfflineAudio(String audioPath) async {
    await Future.delayed(Duration(seconds: 2));

    return [
      "This is offline speech recognition.",
      "Processing completed successfully.",
      "Transcript saved to local storage.",
    ];
  }

  Future<double> getAccuracyScore() async {
    await Future.delayed(Duration(milliseconds: 200));
    return 0.92; // Mock accuracy score
  }

  void _updateState(SpeechRecognitionState newState) {
    _state = newState;
    _stateStream.add(newState);
  }

  void dispose() {
    _simulationTimer?.cancel();
    _textStream.close();
    _stateStream.close();
    _confidenceStream.close();
  }
}

// Singleton instance
SpeechService speechService = SpeechService();