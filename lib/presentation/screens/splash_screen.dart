import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextScreen,
    this.duration = const Duration(seconds: 2),
  });

  final Widget? nextScreen;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (widget.nextScreen != null) {
      _timer = Timer(widget.duration, () {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => widget.nextScreen!,
            transitionDuration: const Duration(milliseconds: 450),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0E82D5),
      body: SafeArea(
        child: Center(
          child: _SplashContent(),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentWidth = math.min(width - 32, 340).toDouble();
        final glassesWidth = contentWidth * 0.62;

        return Transform.translate(
          offset: Offset(0, -constraints.maxHeight * 0.045),
          child: SizedBox(
            width: contentWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: glassesWidth,
                  height: glassesWidth * 0.45,
                  child: const CustomPaint(
                    painter: _GlassesPainter(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Echosee',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Georgia',
                    fontFamilyFallback: ['Times New Roman', 'serif'],
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 34),
                const Text(
                  'Hello! how  can i help you today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassesPainter extends CustomPainter {
  const _GlassesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 210;
    final lensStroke = Paint()
      ..color = const Color(0xFF322B25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * scale;
    final frameStroke = Paint()
      ..color = const Color(0xFF3E2E23)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2 * scale;
    final fineFrameStroke = Paint()
      ..color = const Color(0xFF4A3526)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.15 * scale;
    final highlightStroke = Paint()
      ..color = Colors.white.withOpacity(0.34)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.8 * scale;

    final leftLens = Rect.fromCenter(
      center: Offset(60 * scale, 58 * scale),
      width: 50 * scale,
      height: 58 * scale,
    );
    final rightLens = Rect.fromCenter(
      center: Offset(137 * scale, 58 * scale),
      width: 58 * scale,
      height: 60 * scale,
    );

    _paintLens(canvas, leftLens, scale);
    _paintLens(canvas, rightLens, scale);

    canvas.drawOval(leftLens, lensStroke);
    canvas.drawOval(rightLens, lensStroke);

    final bridge = Path()
      ..moveTo(leftLens.right - 2 * scale, 56 * scale)
      ..cubicTo(
        84 * scale,
        49 * scale,
        101 * scale,
        49 * scale,
        rightLens.left + 2 * scale,
        56 * scale,
      );
    canvas.drawPath(bridge, frameStroke);

    final leftArm = Path()
      ..moveTo(leftLens.left + 2 * scale, 35 * scale)
      ..cubicTo(
        70 * scale,
        20 * scale,
        99 * scale,
        14 * scale,
        118 * scale,
        8 * scale,
      )
      ..cubicTo(
        132 * scale,
        12 * scale,
        141 * scale,
        21 * scale,
        151 * scale,
        25 * scale,
      );
    canvas.drawPath(leftArm, fineFrameStroke);

    final leftTip = Path()
      ..moveTo(151 * scale, 25 * scale)
      ..quadraticBezierTo(155 * scale, 30 * scale, 151 * scale, 33 * scale);
    canvas.drawPath(leftTip, frameStroke);

    final rightArm = Path()
      ..moveTo(rightLens.right - 3 * scale, 62 * scale)
      ..cubicTo(
        165 * scale,
        64 * scale,
        190 * scale,
        49 * scale,
        208 * scale,
        35 * scale,
      );
    canvas.drawPath(rightArm, fineFrameStroke);

    final rightTip = Path()
      ..moveTo(208 * scale, 35 * scale)
      ..quadraticBezierTo(214 * scale, 31 * scale, 211 * scale, 36 * scale);
    canvas.drawPath(rightTip, frameStroke);

    final leftNosePad = Path()
      ..moveTo(84 * scale, 63 * scale)
      ..quadraticBezierTo(79 * scale, 68 * scale, 76 * scale, 74 * scale);
    final rightNosePad = Path()
      ..moveTo(113 * scale, 63 * scale)
      ..quadraticBezierTo(118 * scale, 68 * scale, 121 * scale, 74 * scale);
    canvas.drawPath(leftNosePad, highlightStroke);
    canvas.drawPath(rightNosePad, highlightStroke);
  }

  void _paintLens(Canvas canvas, Rect rect, double scale) {
    final lensFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEAFFFF),
          Color(0xFFC9F5FF),
          Color(0xFFFFFFFF),
          Color(0xFFD8F3FF),
        ],
        stops: [0, 0.32, 0.58, 1],
      ).createShader(rect);
    final flarePaint = Paint()
      ..color = Colors.white.withOpacity(0.46)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.75 * scale;

    canvas.drawOval(rect, lensFill);

    final clipPath = Path()..addOval(rect);
    canvas.save();
    canvas.clipPath(clipPath);

    for (var i = 0; i < 12; i++) {
      final x = rect.left + (6 + i * 4) * scale;
      final startY = rect.top + (4 + (i % 3) * 5) * scale;
      final endY = rect.bottom - (4 + (i % 4) * 3) * scale;
      canvas.drawLine(
          Offset(x, startY), Offset(x + 10 * scale, endY), flarePaint);
    }

    final shine = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;
    canvas.drawArc(
      rect.deflate(8 * scale),
      math.pi * 0.85,
      math.pi * 0.65,
      false,
      shine,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
