import 'package:flutter/material.dart';
import 'package:echo_see_companion/services/yamnet_service.dart';

class SoundRecognitionScreen extends StatefulWidget {
  const SoundRecognitionScreen({super.key});

  @override
  _SoundRecognitionScreenState createState() => _SoundRecognitionScreenState();
}

class _SoundRecognitionScreenState extends State<SoundRecognitionScreen> {
  final _yamNet = YamNetService();
  Map<String, double> _results = {};

  @override
  void initState() {
    super.initState();
    _yamNet.soundStream.listen((results) {
      if (mounted) {
        setState(() {
          _results = results;
        });
      }
    });
    _yamNet.startListening();
  }

  @override
  void dispose() {
    _yamNet.stopListening();
    _yamNet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sound Recognition")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Environmental Sounds", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: _results.entries.map((e) => _buildSoundTile(e.key, e.value)).toList(),
              ),
            ),
            if (_results['Siren'] != null && _results['Siren']! > 0.5)
              _buildAlert("SIREN DETECTED!", Colors.red),
            if (_results['Alarm'] != null && _results['Alarm']! > 0.5)
              _buildAlert("ALARM DETECTED!", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundTile(String label, double confidence) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 18)),
            Text("${(confidence * 100).toStringAsFixed(1)}%"),
          ],
        ),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(confidence > 0.5 ? Colors.red : Colors.blue),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAlert(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }
}
