import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/theme_provider.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/providers/saved_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/providers/search_history_provider.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:provider/single_child_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _providers,
      builder: (context, _) => Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: '99 HomeBazaar',
          debugShowCheckedModeBanner: false,
          theme: theme.currentTheme,
          themeMode: theme.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
  }
}

List<SingleChildWidget> get _providers => [
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => PropertiesProvider()),
  ChangeNotifierProvider(create: (_) => UserProvider()),
  ChangeNotifierProvider(create: (_) => SavedProvider()),
  ChangeNotifierProvider(create: (_) => InquiriesProvider()),
  ChangeNotifierProvider(create: (_) => ReviewsProvider()),
  ChangeNotifierProvider(create: (_) => ComparisonsProvider()),
  ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
  ChangeNotifierProvider(create: (_) => SearchHistoryProvider()),
  ChangeNotifierProvider(create: (_) => SupportProvider()),
];
