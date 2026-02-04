// lib/presentation/widgets/common/loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:echo_see_companion/core/constants/app_colors.dart';

enum LoadingIndicatorType {
  circular,
  linear,
  dots,
  pulse,
  shimmer,
}

class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorType type;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final String? message;
  final bool showMessage;
  final EdgeInsetsGeometry padding;

  const LoadingIndicator({
    Key? key,
    this.type = LoadingIndicatorType.circular,
    this.color,
    this.backgroundColor,
    this.size = 32.0,
    this.strokeWidth = 3.0,
    this.message,
    this.showMessage = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicator(),
          if (showMessage) ...[
            SizedBox(height: 16),
            Text(
              message ?? 'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    switch (type) {
      case LoadingIndicatorType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
          ),
        );

      case LoadingIndicatorType.linear:
        return LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
          backgroundColor: backgroundColor,
          minHeight: strokeWidth,
        );

      case LoadingIndicatorType.dots:
        return _DotsLoadingIndicator(
          color: color ?? AppColors.primary,
          size: size,
        );

      case LoadingIndicatorType.pulse:
        return _PulseLoadingIndicator(
          color: color ?? AppColors.primary,
          size: size,
        );

      case LoadingIndicatorType.shimmer:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  __DotsLoadingIndicatorState createState() => __DotsLoadingIndicatorState();
}

class __DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: ScaleTransition(
            scale: TweenSequence([
              TweenSequenceItem(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                weight: 1,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.0, end: 0.5),
                weight: 1,
              ),
            ]).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.2,
                  1.0,
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            child: Container(
              width: widget.size / 3,
              height: widget.size / 3,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingIndicator({
    Key? key,
    required this.color,
    required this.size,
  }) : super(key: key);

  @override
  __PulseLoadingIndicatorState createState() => __PulseLoadingIndicatorState();
}

class __PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(
              0.5 + (_controller.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  0.2 + (_controller.value * 0.3),
                ),
                blurRadius: 10 + (_controller.value * 5),
                spreadRadius: _controller.value * 3,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
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

// Full screen loading overlay
class FullScreenLoader extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final bool showCloseButton;

  const FullScreenLoader({
    Key? key,
    this.message = 'Loading...',
    this.backgroundColor = Colors.black54,
    this.showCloseButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(
            type: LoadingIndicatorType.circular,
            size: 48,
            strokeWidth: 4,
            showMessage: true,
            message: message,
          ),
          if (showCloseButton) ...[
            SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Shimmer loading effect for list items
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = BorderRadius.zero,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

// List of shimmer loading items
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry itemPadding;

  const ShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemPadding = const EdgeInsets.symmetric(vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: itemPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle shimmer
              ShimmerLoading(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    ShimmerLoading(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: 8),
                    // Subtitle shimmer
                    ShimmerLoading(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}