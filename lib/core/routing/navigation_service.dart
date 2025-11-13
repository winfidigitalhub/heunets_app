import 'package:flutter/material.dart';
import '../../features/jobs/data/model/job_model.dart';
import 'route_names.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<dynamic>? pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic>? pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic>? pushAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop([Object? result]) {
    navigatorKey.currentState?.pop(result);
  }

  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  static Future<dynamic>? navigateToHome() {
    return pushReplacementNamed(RouteNames.home);
  }

  static Future<dynamic>? navigateToLogin() {
    return pushReplacementNamed(RouteNames.login);
  }

  static Future<dynamic>? navigateToSignup() {
    return pushNamed(RouteNames.signup);
  }

  static Future<dynamic>? navigateToAppliedJob() {
    return pushNamed(RouteNames.appliedJob);
  }

  static Future<dynamic>? navigateToSavedJob() {
    return pushNamed(RouteNames.savedJob);
  }

  static Future<dynamic>? navigateToProfile() {
    return pushNamed(RouteNames.profile);
  }

  static Future<dynamic>? navigateToAddJob() {
    return pushNamed(RouteNames.addJob);
  }

  static Future<dynamic>? navigateToJobDetails({
    required Job job,
  }) {
    return pushNamed(
      RouteNames.jobDetails,
      arguments: {'job': job},
    );
  }

  static Future<dynamic>? navigateToCandidates() {
    return pushReplacementNamed(RouteNames.candidates);
  }
}

