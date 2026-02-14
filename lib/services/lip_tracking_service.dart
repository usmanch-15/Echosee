import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LipTrackingService {
  late FaceDetector _faceDetector;

  LipTrackingService() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<List<Face>> processImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
    return await _faceDetector.processImage(inputImage);
  }

  // Helper to get mouth ROI coordinates
  Rect? getMouthROI(Face face) {
    final mouth = face.landmarks[FaceLandmarkType.bottomMouth];
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth];

    if (mouth != null && leftMouth != null && rightMouth != null) {
      final double width = (rightMouth.position.x - leftMouth.position.x).abs() * 1.5;
      final double height = width * 0.6;
      return Rect.fromCenter(
        center: Offset(mouth.position.x.toDouble(), mouth.position.y.toDouble()),
        width: width,
        height: height,
      );
    }
    return null;
  }

  void dispose() {
    _faceDetector.close();
  }
}
