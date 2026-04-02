import 'dart:io';
import 'package:flutter/material.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({Key? key}) : super(key: key);

  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  String _statusMessage = "Ready to launch the AI System.";
  Process? _pythonProcess;
  bool _isRunning = false;

  Directory? _findProjectRoot() {
    Directory current = Directory.current;

    // Walk up from runtime cwd until project root (pubspec.yaml) is found.
    while (true) {
      final pubspec =
          File('${current.path}${Platform.pathSeparator}pubspec.yaml');
      if (pubspec.existsSync()) {
        return current;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        return null;
      }
      current = parent;
    }
  }

  String? _resolvePythonExecutable(String rootPath) {
    final sep = Platform.pathSeparator;
    final windowsVenv = '$rootPath${sep}stt_env${sep}Scripts${sep}python.exe';
    final unixVenv = '$rootPath${sep}stt_env${sep}bin${sep}python';

    if (File(windowsVenv).existsSync()) return windowsVenv;
    if (File(unixVenv).existsSync()) return unixVenv;

    // Fallback to system python available in PATH.
    return 'python';
  }

  Future<void> _launchSystem() async {
    setState(() {
      _statusMessage = "Launching AI System...";
      _isRunning = true;
    });

    try {
      final projectRoot = _findProjectRoot();
      if (projectRoot == null) {
        setState(() {
          _statusMessage = "Error: Project root not found.";
          _isRunning = false;
        });
        return;
      }

      final sep = Platform.pathSeparator;
      final scriptPath = '${projectRoot.path}${sep}ai_engine${sep}main.py';
      if (!File(scriptPath).existsSync()) {
        setState(() {
          _statusMessage = "Error: ai_engine/main.py not found.";
          _isRunning = false;
        });
        return;
      }

      final pythonExecutable = _resolvePythonExecutable(projectRoot.path);

      // Launch ai_engine main Python file.
      _pythonProcess = await Process.start(
        pythonExecutable!,
        [scriptPath],
        workingDirectory: projectRoot.path,
      );

      _pythonProcess!.stdout.listen((data) {
        debugPrint("Python System: ${String.fromCharCodes(data)}");
      });

      _pythonProcess!.stderr.listen((data) {
        debugPrint("Python System Error: ${String.fromCharCodes(data)}");
      });

      _pythonProcess!.exitCode.then((code) {
        if (mounted) {
          setState(() {
            _statusMessage = "AI System closed (exit code: $code).";
            _isRunning = false;
            _pythonProcess = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error: Make sure Python is installed. ($e)";
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Echo See - AI System')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isRunning ? null : _launchSystem,
                icon: const Icon(Icons.rocket_launch, color: Colors.white),
                label: const Text("Open AI Desktop App",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
