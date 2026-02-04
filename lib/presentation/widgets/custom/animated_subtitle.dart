// lib/presentation/widgets/custom/animated_subtitle.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';


class AnimatedSubtitle extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  final int? speakerIndex;

  const AnimatedSubtitle({
    Key? key,
    required this.text,
    required this.color,
    required this.fontSize,
    this.speakerIndex,
  }) : super(key: key);

  @override
  _AnimatedSubtitleState createState() => _AnimatedSubtitleState();
}

class _AnimatedSubtitleState extends State<AnimatedSubtitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaker Indicator
                if (widget.speakerIndex != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(right: 12, top: 8),
                    decoration: BoxDecoration(
                      color: AppColors.speakerColors[widget.speakerIndex! % AppColors.speakerColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],

                // Subtitle Text
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.color,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}