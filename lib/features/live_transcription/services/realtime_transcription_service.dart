import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RealtimeTranscriptionService {
  final SpeechToText _speech = SpeechToText();
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();
  final StreamController<double> _confidenceController =
      StreamController<double>.broadcast();

  Stream<String> get transcriptStream => _transcriptController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<double> get confidenceStream => _confidenceController.stream;

  bool _initialized = false;
  bool _keepListening = false;
  bool _startingSession = false;
  String _finalTranscript = '';
  String _partialTranscript = '';
  String _localeId = 'en_US';

  bool get isListening => _keepListening;

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    final available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: false,
    );
    _initialized = available;
    if (!available) {
      _statusController.add('Speech recognition is unavailable.');
    }
    return available;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _statusController.add('Microphone permission is required.');
      return false;
    }
    return true;
  }

  Future<bool> start({String localeId = 'en_US'}) async {
    _localeId = localeId;
    final available = await initialize();
    if (!available) {
      return false;
    }

    final permissionGranted = await requestMicrophonePermission();
    if (!permissionGranted) {
      return false;
    }

    _keepListening = true;
    _statusController.add('Listening...');
    return _startListeningSession();
  }

  Future<void> stop() async {
    _keepListening = false;
    _partialTranscript = '';
    if (_speech.isListening) {
      await _speech.stop();
    }
    _statusController.add('Listening stopped.');
    _emitTranscript();
  }

  void clearTranscript() {
    _finalTranscript = '';
    _partialTranscript = '';
    _emitTranscript();
  }

  Future<bool> _startListeningSession() async {
    if (!_keepListening || _startingSession) {
      return false;
    }

    _startingSession = true;
    try {
      final started = await _speech.listen(
        onResult: _onResult,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 4),
        localeId: _localeId,
        listenOptions: SpeechListenOptions(
          cancelOnError: false,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
      return started;
    } finally {
      _startingSession = false;
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isEmpty) {
      return;
    }

    _confidenceController.add(result.confidence);

    if (result.finalResult) {
      if (_finalTranscript.isEmpty) {
        _finalTranscript = words;
      } else {
        _finalTranscript = '$_finalTranscript $words';
      }
      _partialTranscript = '';
    } else {
      _partialTranscript = words;
    }

    _emitTranscript();
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _statusController.add('Listening...');
      return;
    }

    if (status == 'notListening' && _keepListening) {
      _statusController.add('Listening...');
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        _startListeningSession();
      });
      return;
    }

    if (!_keepListening) {
      _statusController.add('Listening stopped.');
    }
  }

  void _onError(SpeechRecognitionError error) {
    _statusController.add('Speech error: ${error.errorMsg}');
    if (_keepListening) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        _startListeningSession();
      });
    }
  }

  void _emitTranscript() {
    final combined = _partialTranscript.isEmpty
        ? _finalTranscript
        : (_finalTranscript.isEmpty
            ? _partialTranscript
            : '$_finalTranscript $_partialTranscript');
    _transcriptController.add(combined.trim());
  }

  void dispose() {
    _keepListening = false;
    _speech.stop();
    _transcriptController.close();
    _statusController.close();
    _confidenceController.close();
  }
}
