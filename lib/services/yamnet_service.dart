import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:sound_stream/sound_stream.dart';

class YamNetService {
  late Interpreter _interpreter;
  final _recorder = RecorderStream();
  final _controller = StreamController<Map<String, double>>.broadcast();
  late List<String> _classLabels;

  bool _isInitialized = false;
  bool _isListening = false;

  Stream<Map<String, double>> get soundStream => _controller.stream;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/yamnet.tflite');
      await _loadClassLabels();
      _isInitialized = true;
      print("YamNet Initialized with ${_classLabels.length} labels");
    } catch (e) {
      print("Error initializing YamNet: $e");
    }
  }

  Future<void> _loadClassLabels() async {
    try {
      final csvContent = await rootBundle.loadString('assets/models/yamnet_class_map.csv');
      final lines = csvContent.split('\n');
      _classLabels = [];

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        // CSV format: "index","display_name"
        // e.g., "0","Speech"
        final parts = line.split('"');
        if (parts.length >= 4) {
          final label = parts[3];
          _classLabels.add(label);
        }
      }
      print("Loaded ${_classLabels.length} class labels");
    } catch (e) {
      print("Error loading class labels: $e");
      // Fallback to empty list
      _classLabels = [];
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized) await init();
    if (_isListening) return;

    _isListening = true;
    _recorder.audioStream.listen((data) {
      _processAudioFrame(data);
    });
    await _recorder.start();
  }

  Future<void> stopListening() async {
    await _recorder.stop();
    _isListening = false;
  }

  void _processAudioFrame(Uint8List data) {
    if (!_isInitialized) return;

    // YAMNet expects a Float32 array of shape [15600] for 0.975s of audio at 16kHz.
    // This is a simplified implementation. In a real app, you'd buffer the audio.
    var input = _convertUint8ListToFloat32List(data);
    if (input.length < 15600) return; // Need enough data

    var output = List<double>.filled(521, 0).reshape([1, 521]);
    _interpreter.run(input.sublist(0, 15600), output);
    
    // Map output to labels and emit
    _controller.add(_getTopResults(output[0]));
  }

  Float32List _convertUint8ListToFloat32List(Uint8List data) {
    var floatData = Float32List(data.length ~/ 2);
    for (var i = 0; i < floatData.length; i++) {
      int low = data[i * 2];
      int high = data[i * 2 + 1];
      int val = (high << 8) | low;
      if (val > 32767) val -= 65536;
      floatData[i] = val / 32768.0;
    }
    return floatData;
  }

  Map<String, double> _getTopResults(List<dynamic> output) {
    if (_classLabels.isEmpty) {
      // Fallback if labels didn't load
      return {
        'Speech': output[0] as double,
        'Siren': (output.length > 3 ? output[3] : 0.0) as double,
        'Dog': (output.length > 10 ? output[10] : 0.0) as double,
        'Alarm': (output.length > 25 ? output[25] : 0.0) as double,
      };
    }

    final results = <String, double>{};

    // Get top 5 predictions with confidence > 0.3
    for (int i = 0; i < output.length && i < _classLabels.length; i++) {
      final confidence = output[i] as double;
      if (confidence > 0.3) {
        results[_classLabels[i]] = confidence;
      }
    }

    // If no confident predictions, return empty
    if (results.isEmpty) {
      return {};
    }

    return results;
  }

  void dispose() {
    _controller.close();
    _interpreter.close();
  }
}
