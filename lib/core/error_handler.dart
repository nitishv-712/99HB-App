import 'package:flutter/material.dart';
import 'package:homebazaar/view/components/error_dialog.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };
  }

  static void handleUncaughtError(Object error, StackTrace stackTrace) {
    final message = _userMessage(error);
    _showSnackBar(message);
    debugPrint('Unhandled error: $error');
    debugPrint('$stackTrace');
  }

  static void showError(BuildContext context, String message) {
    AppErrorDialog.show(context, message);
  }

  static void showMessage(String message) {
    _showSnackBar(message);
  }

  static void _showSnackBar(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  static String _userMessage(Object error) {
    final text = error.toString();
    return text.isEmpty ? 'Something went wrong.' : text;
  }

  static BuildContext? get context => navigatorKey.currentContext;
}
