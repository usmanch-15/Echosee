// lib/services/speech_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:sound_stream/sound_stream.dart';
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
  final StreamController<String> _textStream = StreamController<String>.broadcast();
  final StreamController<SpeechRecognitionState> _stateStream =
  StreamController<SpeechRecognitionState>.broadcast();
  final StreamController<double> _confidenceStream = StreamController<double>.broadcast();

  final List<String> _recognizedText = [];
  
  // Vosk & Audio Objects
  VoskFlutterPlugin? _vosk;
  Model? _model;
  Recognizer? _recognizer;
  final RecorderStream _recorder = RecorderStream();
  StreamSubscription? _audioSubscription;

  Stream<String> get textStream => _textStream.stream;
  Stream<SpeechRecognitionState> get stateStream => _stateStream.stream;
  Stream<double> get confidenceStream => _confidenceStream.stream;
  SpeechRecognitionState get currentState => _state;
  List<String> get recognizedText => List.from(_recognizedText);

  Future<void> initialize() async {
    try {
      _updateState(SpeechRecognitionState.processing);
      
      _vosk = VoskFlutterPlugin.instance();
      
      // Load model from assets
      // Note: This takes some time on first run as it unzips
      final modelLoader = ModelLoader();
      final modelPath = await modelLoader.loadFromAssets('assets/models/en.zip');
      
      _model = await _vosk!.createModel(modelPath);
      
      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );
      
      await _recorder.initialize();
      
      _updateState(SpeechRecognitionState.notStarted);
    } catch (e) {
      debugPrint("Vosk Initialization Error: $e");
      _updateState(SpeechRecognitionState.error);
    }
  }

  Future<void> startListening() async {
    if (_state == SpeechRecognitionState.listening) return;
    
    if (_recognizer == null) {
      await initialize();
    }

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

    // Start Recording
    await _recorder.start();
    
    _audioSubscription = _recorder.audioStream.listen((data) async {
      if (_recognizer != null) {
        final resultFound = await _recognizer!.acceptWaveformBytes(Uint8List.fromList(data));
        if (resultFound) {
          final result = await _recognizer!.getResult();
          final text = jsonDecode(result)['text'];
          if (text != null && text.isNotEmpty) {
            _recognizedText.add(text);
            _textStream.add(text);
            _confidenceStream.add(0.95); // Vosk doesn't always provide confidence in simple result
          }
        } else {
          final partialResult = await _recognizer!.getPartialResult();
          final partialText = jsonDecode(partialResult)['partial'];
          if (partialText != null && partialText.isNotEmpty) {
            // We can emit partial text too if we want a "live" feel
            _textStream.add(partialText);
          }
        }
      }
    });
  }

  Future<void> stopListening() async {
    if (_state != SpeechRecognitionState.listening) return;

    _updateState(SpeechRecognitionState.processing);
    
    await _audioSubscription?.cancel();
    await _recorder.stop();
    
    if (_recognizer != null) {
      final finalResult = await _recognizer!.getFinalResult();
      final text = jsonDecode(finalResult)['text'];
      if (text != null && text.isNotEmpty) {
        _recognizedText.add(text);
        _textStream.add(text);
      }
    }

    _updateState(SpeechRecognitionState.stopped);
  }

  Future<void> pauseListening() async {
    await stopListening();
  }

  Future<void> resumeListening() async {
    if (_state == SpeechRecognitionState.stopped || _state == SpeechRecognitionState.notStarted) {
      await startListening();
    }
  }

  void clearText() {
    _recognizedText.clear();
    _textStream.add('');
  }

  Future<List<String>> getAvailableLanguages() async {
    return [
      'English',
      'Urdu', // Note: Offline Urdu requires another model
    ];
  }

  Future<void> setLanguage(String languageCode) async {
    // For now we only have English model bundled
    debugPrint('Language set to: $languageCode');
  }

  Future<bool> checkPermissions() async {
    return await Permission.microphone.isGranted;
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<List<String>> processOfflineAudio(String audioPath) async {
    // This would involve reading a file and feeding it to the recognizer
    return ["Offline file processing not implemented via mic stream"];
  }

  Future<double> getAccuracyScore() async {
    return 0.95;
  }

  void _updateState(SpeechRecognitionState newState) {
    _state = newState;
    _stateStream.add(newState);
  }

  void dispose() {
    _audioSubscription?.cancel();
    _recorder.stop();
    _recognizer?.dispose();
    _model?.dispose();
    _textStream.close();
    _stateStream.close();
    _confidenceStream.close();
  }
}

// Singleton instance
SpeechService speechService = SpeechService();