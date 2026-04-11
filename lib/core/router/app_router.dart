import 'package:flutter/material.dart';
import 'package:homebazaar/view/screen/analytics_screen.dart';
import 'package:homebazaar/view/screen/comparisons_screen.dart';
import 'package:homebazaar/view/screen/inquiries_screen.dart';
import 'package:homebazaar/view/screen/reviews_screen.dart';
import 'package:homebazaar/view/screen/search_history_screen.dart';
import 'package:homebazaar/view/screen/settings_screen.dart';
import 'package:homebazaar/view/screen/splash_screen.dart';
import 'package:homebazaar/view/screen/support_screen.dart';
import 'package:homebazaar/view/screen/buy_screen.dart';
import 'package:homebazaar/view/screen/dashboard_screen.dart';
import 'package:homebazaar/view/screen/forgot_password_screen.dart';
import 'package:homebazaar/view/screen/home_screen.dart';
import 'package:homebazaar/view/screen/property_detail_screen.dart';
import 'package:homebazaar/view/screen/sign_in_screen.dart';
import 'package:homebazaar/view/screen/sign_up_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const buy = '/buy';
  static const dashboard = '/dashboard';
  static const propertyDetail = '/property/:id';
  static const settings = '/settings';
  static const analytics = '/analytics';
  static const inquiries = '/inquiries';
  static const reviews = '/reviews';
  static const searchHistory = '/search-history';
  static const support = '/support';
  static const comparisons = '/comparisons';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _slide(const SplashScreen());
      case AppRoutes.home:
        return _slide(const HomeScreen());
      case AppRoutes.signIn:
        return _slide(const SignInScreen());
      case AppRoutes.signUp:
        return _slide(const SignUpScreen());
      case AppRoutes.forgotPassword:
        return _slide(const ForgotPasswordScreen());
      case AppRoutes.buy:
        return _slide(const BuyScreen());
      case AppRoutes.dashboard:
        return _slide(const DashboardScreen());
      case AppRoutes.propertyDetail:
        final id = settings.arguments as String?;
        return _slide(PropertyDetailScreen(propertyId: id));
      case AppRoutes.settings:
        return _slide(const SettingsScreen());
      case AppRoutes.analytics:
        return _slide(const AnalyticsScreen());
      case AppRoutes.inquiries:
        return _slide(const InquiriesScreen());
      case AppRoutes.reviews:
        return _slide(const ReviewsScreen());
      case AppRoutes.searchHistory:
        return _slide(const SearchHistoryScreen());
      case AppRoutes.support:
        return _slide(const SupportScreen());
      case AppRoutes.comparisons:
        return _slide(const ComparisonsScreen());
      default:
        return _slide(const HomeScreen());
    }
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  static void push(BuildContext context, String route, {Object? args}) =>
      Navigator.pushNamed(context, route, arguments: args);

  static void replace(BuildContext context, String route, {Object? args}) =>
      Navigator.pushReplacementNamed(context, route, arguments: args);

  static void pushAndClearStack(
    BuildContext context,
    String route, {
    Object? args,
  }) => Navigator.pushNamedAndRemoveUntil(
    context,
    route,
    (_) => false,
    arguments: args,
  );

  static void pop(BuildContext context) => Navigator.maybePop(context);

  // ── Bottom nav index → route ──────────────────────────────────────────────

  static void navigateFromBottomNav(BuildContext context, int index) {
    // Navigation is now handled directly in AppBottomNav per-item
  }

  // ── Slide transition ──────────────────────────────────────────────────────

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 280),
  );
}
