// lib/core/utils/navigation_service.dart
import 'package:flutter/material.dart';

import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/premium_features_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/transcript_list_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> navigateToWithReplacement(
      String routeName, {
        Object? arguments,
      }) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> navigateToAndRemoveUntil(
      String routeName, {
        Object? arguments,
        bool Function(Route<dynamic>)? predicate,
      }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      predicate ?? (_) => false,
      arguments: arguments,
    );
  }

  static void goBack({dynamic result}) {
    navigatorKey.currentState!.pop(result);
  }

  static void goBackToFirst() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Define your routes here
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return FadeSlideRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return FadeSlideRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/transcripts':
        return ScaleRoute(builder: (_) => const TranscriptListScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/premium':
        return MaterialPageRoute(builder: (_) => const PremiumFeaturesScreen());
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }

  static void showSnackBar(String message, {Color? backgroundColor}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<dynamic> showDialog({
    required WidgetBuilder builder,
    bool barrierDismissible = true, required BuildContext context,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<dynamic> showBottomSheet({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
  }) {
    return showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      isScrollControlled: true,
    );
  }
}

// Custom Page Routes
class FadeSlideRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  FadeSlideRoute({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

class ScaleRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  ScaleRoute({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

class SlideRightRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  SlideRightRoute({required this.builder})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}