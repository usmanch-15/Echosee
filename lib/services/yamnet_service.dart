import 'dart:async';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:sound_stream/sound_stream.dart';

class YamNetService {
  late Interpreter _interpreter;
  final _recorder = RecorderStream();
  final _controller = StreamController<Map<String, double>>.broadcast();
  
  bool _isInitialized = false;
  bool _isListening = false;
  
  Stream<Map<String, double>> get soundStream => _controller.stream;

  Future<void> init() async {
    try {
      // For actual implementation, download yamnet.tflite and its labels.
      // https://tfhub.dev/google/lite-model/yamnet/1/default/1
      _interpreter = await Interpreter.fromAsset('assets/models/yamnet.tflite');
      _isInitialized = true;
      print("YamNet Initialized");
    } catch (e) {
      print("Error initializing YamNet: $e");
      // Fallback or mock for demo/tests
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
    // Simplified mapping for common safety sounds
    // In production, use the actual YAMNet labels file
    return {
      'Speech': output[0] as double,
      'Siren': output[3] as double,
      'Dog': output[10] as double,
      'Alarm': output[25] as double,
    };
  }

  void dispose() {
    _controller.close();
    _interpreter.close();
  }
}
