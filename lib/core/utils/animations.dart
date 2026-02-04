// lib/core/utils/animations.dart
import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve linear = Curves.linear;
  static const Curve ease = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;

  // Pre-built animations
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: easeIn),
    );
  }

  static Animation<Offset> createSlideAnimation(
      AnimationController controller, {
        Offset begin = const Offset(0, 0.1),
        Offset end = Offset.zero,
      }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: easeOut),
    );
  }

  static Animation<double> createScaleAnimation(
      AnimationController controller, {
        double begin = 0.8,
        double end = 1.0,
      }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: elastic),
    );
  }

  static Animation<double> createRotationAnimation(AnimationController controller) {
    return Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: controller, curve: linear),
    );
  }

  // Animation builders
  static Widget buildFadeTransition(
      Widget child,
      Animation<double> animation,
      ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget buildSlideTransition(
      Widget child,
      Animation<Offset> animation,
      ) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  static Widget buildScaleTransition(
      Widget child,
      Animation<double> animation,
      ) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }

  static Widget buildCombinedTransition({
    required Widget child,
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Animation<double> scaleAnimation,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }

  // Specific app animations
  static AnimationController createSubtitleController(TickerProvider vsync) {
    return AnimationController(
      duration: medium,
      vsync: vsync,
    );
  }

  static AnimationController createButtonController(TickerProvider vsync) {
    return AnimationController(
      duration: fast,
      vsync: vsync,
    );
  }

  static AnimationController createPageTransitionController(TickerProvider vsync) {
    return AnimationController(
      duration: slow,
      vsync: vsync,
    );
  }

  // Micro-interactions
  static Animation<double> createButtonPressAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.95), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.95, end: 1.0), weight: 50),
    ]).animate(controller);
  }

  static Animation<double> createPulseAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(controller);
  }
}