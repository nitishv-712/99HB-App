import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_bar.dart';
import 'package:homebazaar/view/screen/home/home_screen.dart';
import 'package:homebazaar/view/screen/home/buy_screen.dart';
import 'package:homebazaar/view/screen/dashboard/dashboard_screen.dart';
import 'package:homebazaar/view/screen/account/settings_screen.dart';
import 'package:homebazaar/view/screen/auth/sign_in_screen.dart';
import 'package:provider/provider.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  PageController pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final items = [
      (
        icon: Icons.home_rounded,
        outlinedIcon: Icons.home_outlined,
        label: 'Home',
        route: AppRoutes.home,
      ),
      (
        icon: Icons.search_rounded,
        outlinedIcon: Icons.search_outlined,
        label: 'Browse',
        route: AppRoutes.buy,
      ),
      if (!isAuthenticated)
        (
          icon: Icons.login_rounded,
          outlinedIcon: Icons.login_outlined,
          label: 'Sign In',
          route: AppRoutes.signIn,
        ),
      if (isAuthenticated)
        (
          icon: Icons.person_rounded,
          outlinedIcon: Icons.person_outline_rounded,
          label: 'Dashboard',
          route: AppRoutes.dashboard,
        ),
      (
        icon: Icons.settings_rounded,
        outlinedIcon: Icons.settings_outlined,
        label: 'Settings',
        route: AppRoutes.settings,
      ),
    ];
    return WillPopScope(
      onWillPop: () async {
        bool? exitApp = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cs.surface,
            title: Text(
              "Exit App?",
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            content: const Text("Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "No",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(cs.primary),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
        if (exitApp == true) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: null,
            bottomNavigationBar: NavigationBar(
              indicatorColor: cs.secondary,
              elevation: 10,
              backgroundColor: cs.surface,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  pageController.jumpToPage(index);
                });
              },
              destinations: items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.outlinedIcon),
                      selectedIcon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
            body: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: items.map((item) {
                switch (item.route) {
                  case AppRoutes.home:
                    return const HomeScreen();
                  case AppRoutes.buy:
                    return const BuyScreen();
                  case AppRoutes.signIn:
                    return const SignInScreen();
                  case AppRoutes.dashboard:
                    return const DashboardScreen();
                  case AppRoutes.settings:
                    return const SettingsScreen();
                  default:
                    return const HomeScreen();
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
