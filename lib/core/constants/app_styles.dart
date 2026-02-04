// lib/core/constants/app_styles.dart
import 'package:flutter/material.dart';

class AppTextStyles {
  // Headers
  static TextStyle header1(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    );
  }

  static TextStyle header2(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 24,
    );
  }

  // Body Text
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 18,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 16,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 14,
    );
  }

  // Subtitle Styles
  static TextStyle subtitleLarge(Color color) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: color,
      shadows: [
        Shadow(
          blurRadius: 4,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );
  }

  static TextStyle subtitleMedium(Color color) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: color,
      shadows: [
        Shadow(
          blurRadius: 3,
          color: Colors.black.withOpacity(0.4),
        ),
      ],
    );
  }
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double circle = 50.0;
}

class AppSizes {
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;
  static const double textFieldHeight = 56.0;
  static const double appBarHeight = 64.0;
}