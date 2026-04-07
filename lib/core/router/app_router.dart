import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/auth_provider.dart';
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
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _slide(const _SplashEntry());
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
    const routes = [
      AppRoutes.home,
      AppRoutes.buy,
      AppRoutes.signIn,
      AppRoutes.dashboard, // Inquiries — placeholder until screen is built
      AppRoutes.dashboard, // Support — placeholder until screen is built
    ];
    replace(context, routes[index]);
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

// ── Splash / Auth Gate ────────────────────────────────────────────────────────

class _SplashEntry extends StatefulWidget {
  const _SplashEntry();

  @override
  State<_SplashEntry> createState() => _SplashEntryState();
}

class _SplashEntryState extends State<_SplashEntry> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().init().then((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      AppRouter.replace(
        context,
        auth.isAuthenticated ? AppRoutes.home : AppRoutes.signIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
