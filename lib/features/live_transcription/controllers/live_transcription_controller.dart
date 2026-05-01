import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/bluetooth_glasses_service.dart';
import '../services/realtime_transcription_service.dart';

class LiveTranscriptionController extends ChangeNotifier {
  final BluetoothGlassesService _bluetoothService = BluetoothGlassesService();
  final RealtimeTranscriptionService _transcriptionService =
      RealtimeTranscriptionService();

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  GlassesConnectionState _connectionState = GlassesConnectionState.idle;
  List<ScanResult> _scanResults = const [];
  String _connectionMessage = 'Initializing...';
  String _speechStatus = 'Idle';
  String _transcript = '';
  double _confidence = 0.0;
  bool _isListening = false;
  bool _isInitializing = true;

  GlassesConnectionState get connectionState => _connectionState;
  List<ScanResult> get scanResults => _scanResults;
  String get connectionMessage => _connectionMessage;
  String get speechStatus => _speechStatus;
  String get transcript => _transcript;
  double get confidence => _confidence;
  bool get isListening => _isListening;
  bool get isInitializing => _isInitializing;
  bool get isConnected => _connectionState == GlassesConnectionState.connected;

  Future<void> initialize() async {
    _subscriptions.add(
      _bluetoothService.stateStream.listen((state) {
        _connectionState = state;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _bluetoothService.scanResultsStream.listen((results) {
        _scanResults = results;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _bluetoothService.messageStream.listen((message) {
        _connectionMessage = message;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _transcriptionService.statusStream.listen((status) {
        _speechStatus = status;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _transcriptionService.transcriptStream.listen((text) {
        _transcript = text;
        notifyListeners();
      }),
    );

    _subscriptions.add(
      _transcriptionService.confidenceStream.listen((confidence) {
        _confidence = confidence;
        notifyListeners();
      }),
    );

    await _bluetoothService.initialize();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> refreshDevices() async {
    await _bluetoothService.startScan();
  }

  Future<void> connect(ScanResult result) async {
    await _bluetoothService.connectToDevice(result.device);
  }

  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
  }

  Future<void> forgetDevice() async {
    await _bluetoothService.forgetKnownDevice();
  }

  Future<void> autoConnect() async {
    await _bluetoothService.autoConnectKnownDevice();
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await _transcriptionService.stop();
      _isListening = false;
      notifyListeners();
      return;
    }

    if (isConnected) {
      _speechStatus =
          'Connected to glasses. Using Bluetooth audio route when available.';
    } else {
      _speechStatus =
          'Glasses not connected. Using phone microphone fallback.';
    }
    notifyListeners();

    final started = await _transcriptionService.start();
    _isListening = started;
    if (!started) {
      _speechStatus = 'Unable to start listening. Check permissions.';
    }
    notifyListeners();
  }

  void clearTranscript() {
    _transcriptionService.clearTranscript();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _bluetoothService.dispose();
    _transcriptionService.dispose();
    super.dispose();
  }
}
