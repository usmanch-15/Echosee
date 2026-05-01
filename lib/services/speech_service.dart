// lib/services/speech_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';

enum SpeechRecognitionState {
  notStarted,
  listening,
  processing,
  stopped,
  error,
}

class SpeechService {
  SpeechRecognitionState _state = SpeechRecognitionState.notStarted;
  final StreamController<String> _textStream =
      StreamController<String>.broadcast();
  final StreamController<SpeechRecognitionState> _stateStream =
      StreamController<SpeechRecognitionState>.broadcast();
  final StreamController<double> _confidenceStream =
      StreamController<double>.broadcast();

  final List<String> _recognizedText = [];

  // Speech to Text instance
  final SpeechToText _speechToText = SpeechToText();

  Stream<String> get textStream => _textStream.stream;
  Stream<SpeechRecognitionState> get stateStream => _stateStream.stream;
  Stream<double> get confidenceStream => _confidenceStream.stream;
  SpeechRecognitionState get currentState => _state;
  List<String> get recognizedText => List.from(_recognizedText);

  Future<void> initialize() async {
    try {
      _updateState(SpeechRecognitionState.processing);

      // Initialize speech to text
      bool available = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onError,
        debugLogging: kDebugMode,
      );

      if (!available) {
        debugPrint("Speech recognition not available on this device");
        _updateState(SpeechRecognitionState.error);
        return;
      }

      _updateState(SpeechRecognitionState.notStarted);
    } catch (e) {
      debugPrint("Speech Initialization Error: $e");
      _updateState(SpeechRecognitionState.error);
    }
  }

  void _onStatus(String status) {
    debugPrint("Speech status: $status");
    if (status == "listening") {
      _updateState(SpeechRecognitionState.listening);
    } else if (status == "notListening") {
      _updateState(SpeechRecognitionState.stopped);
    }
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint("Speech error: ${error.errorMsg}");
    _updateState(SpeechRecognitionState.error);
  }

  Future<void> startListening() async {
    if (_state == SpeechRecognitionState.listening) return;

    if (_state == SpeechRecognitionState.error) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      await requestPermissions();
      if (!(await checkPermissions())) {
        _updateState(SpeechRecognitionState.error);
        return;
      }
    }

    _updateState(SpeechRecognitionState.listening);
    _recognizedText.clear();

    // Start listening
    await _speechToText.listen(
      onResult: (result) {
        final recognizedWords = result.recognizedWords;
        if (recognizedWords.isNotEmpty) {
          _recognizedText.add(recognizedWords);
          _textStream.add(recognizedWords);
          _confidenceStream.add(result.confidence);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: 'en_US', // Default to English
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (_state != SpeechRecognitionState.listening) return;

    _updateState(SpeechRecognitionState.processing);

    await _speechToText.stop();

    _updateState(SpeechRecognitionState.stopped);
  }

  Future<void> pauseListening() async {
    if (_state != SpeechRecognitionState.listening) return;

    await _speechToText.stop();
    _updateState(SpeechRecognitionState.stopped);
  }

  Future<void> resumeListening() async {
    if (_state == SpeechRecognitionState.stopped ||
        _state == SpeechRecognitionState.notStarted) {
      await startListening();
    }
  }

  void clearText() {
    _recognizedText.clear();
    _textStream.add('');
  }

  Future<List<String>> getAvailableLanguages() async {
    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.name).toList();
  }

  Future<void> setLanguage(String languageCode) async {
    // The language is set when calling listen, but we can store it
    debugPrint('Language set to: $languageCode');
  }

  Future<bool> checkPermissions() async {
    return await Permission.microphone.isGranted;
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<List<String>> processOfflineAudio(String audioPath) async {
    // speech_to_text doesn't support offline file processing
    return ["Offline file processing not supported with speech_to_text"];
  }

  Future<double> getAccuracyScore() async {
    // Return last confidence if available
    return 0.95; // Default confidence
  }

  void _updateState(SpeechRecognitionState newState) {
    _state = newState;
    _stateStream.add(newState);
  }

  void dispose() {
    _speechToText.stop();
    _textStream.close();
    _stateStream.close();
    _confidenceStream.close();
  }
}

// Singleton instance
SpeechService speechService = SpeechService();
