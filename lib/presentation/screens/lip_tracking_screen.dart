import 'package:flutter/material.dart';

import 'package:echo_see_companion/services/lip_tracking_service.dart';

class LipTrackingScreen extends StatefulWidget {
  const LipTrackingScreen({super.key});

  @override
  _LipTrackingScreenState createState() => _LipTrackingScreenState();
}

class _LipTrackingScreenState extends State<LipTrackingScreen> {
  late CameraController _cameraController;
  final _lipService = LipTrackingService();
  bool _isBusy = false;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final frontCamera = (await availableCameras()).firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    
    _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController.initialize();
    
    _cameraController.startImageStream((image) {
      if (!_isBusy) {
        _isBusy = true;
        _processImage(image);
      }
    });
    
    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    final faces = await _lipService.processImage(image);
    if (mounted) {
      setState(() {
        _faces = faces;
      });
    }
    _isBusy = false;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _lipService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Visual Lip Tracking")),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          CustomPaint(
            painter: LipPainter(_faces, _cameraController.value.previewSize!),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black54,
              child: Text(
                _faces.isNotEmpty ? "Face Detected - Tracking Lips" : "Scanning for Face...",
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LipPainter extends CustomPainter {
  final List<Face> faces;
  final Size previewSize;

  LipPainter(this.faces, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var face in faces) {
      // Draw mouth ROI
      final mouth = face.landmarks[FaceLandmarkType.bottomMouth];
      if (mouth != null) {
        // Simple visualization: circle around mouth
        canvas.drawCircle(Offset(mouth.position.x.toDouble(), mouth.position.y.toDouble()), 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
