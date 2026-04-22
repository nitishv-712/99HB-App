import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/auth_provider.dart';
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
  final _pageController = PageController();
  int _selectedIndex = 0;

  // nav items excluding the centre FAB slot
  static const _unauthItems = [
    (
      icon: Icons.home_rounded,
      outline: Icons.home_outlined,
      label: 'Home',
      route: AppRoutes.home,
    ),
    (
      icon: Icons.search_rounded,
      outline: Icons.search_outlined,
      label: 'Browse',
      route: AppRoutes.buy,
    ),
    (
      icon: Icons.login_rounded,
      outline: Icons.login_outlined,
      label: 'Sign In',
      route: AppRoutes.signIn,
    ),
    (
      icon: Icons.settings_rounded,
      outline: Icons.settings_outlined,
      label: 'Settings',
      route: AppRoutes.settings,
    ),
  ];

  static const _authItems = [
    (
      icon: Icons.home_rounded,
      outline: Icons.home_outlined,
      label: 'Home',
      route: AppRoutes.home,
    ),
    (
      icon: Icons.search_rounded,
      outline: Icons.search_outlined,
      label: 'Browse',
      route: AppRoutes.buy,
    ),
    // index 2 is the FAB gap — no entry here
    (
      icon: Icons.person_rounded,
      outline: Icons.person_outline_rounded,
      label: 'Dashboard',
      route: AppRoutes.dashboard,
    ),
    (
      icon: Icons.settings_rounded,
      outline: Icons.settings_outlined,
      label: 'Settings',
      route: AppRoutes.settings,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final items = isAuthenticated ? _authItems : _unauthItems;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: cs.surface,
            title: Text(
              'Exit App?',
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
            ),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
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
                  'Yes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
        if (exit == true) SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: items
              .map(
                (item) => switch (item.route) {
                  AppRoutes.home => const HomeScreen(),
                  AppRoutes.buy => const BuyScreen(),
                  AppRoutes.signIn => const SignInScreen(),
                  AppRoutes.dashboard => const DashboardScreen(),
                  AppRoutes.settings => const SettingsScreen(),
                  _ => const HomeScreen(),
                },
              )
              .toList(),
        ),
        bottomNavigationBar: isAuthenticated
            ? _AuthBottomNav(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() {
                  _selectedIndex = i;
                  _pageController.jumpToPage(i);
                }),
                items: items,
              )
            : _SimpleBottomNav(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() {
                  _selectedIndex = i;
                  _pageController.jumpToPage(i);
                }),
                items: items,
              ),
      ),
    );
  }
}

// ── Authenticated nav — 4 items with a FAB gap in the centre ──────────────────

class _AuthBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, IconData outline, String label, String route})>
  items;

  const _AuthBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 72 + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bar background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.onSurface.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
            ),
          ),

          // 4 nav items split around the centre gap
          Positioned.fill(
            child: Row(
              children: [
                // Left 2 items
                ...List.generate(
                  2,
                  (i) => Expanded(
                    child: _NavItem(
                      icon: items[i].outline,
                      activeIcon: items[i].icon,
                      label: items[i].label,
                      active: selectedIndex == i,
                      onTap: () => onTap(i),
                    ),
                  ),
                ),
                // Centre gap for FAB
                const SizedBox(width: 72),
                // Right 2 items (logical index 2 & 3)
                ...List.generate(
                  2,
                  (i) => Expanded(
                    child: _NavItem(
                      icon: items[i + 2].outline,
                      activeIcon: items[i + 2].icon,
                      label: items[i + 2].label,
                      active: selectedIndex == i + 2,
                      onTap: () => onTap(i + 2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Centre FAB
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(child: _CreateFab()),
          ),
        ],
      ),
    );
  }
}

class _CreateFab extends StatefulWidget {
  @override
  State<_CreateFab> createState() => _CreateFabState();
}

class _CreateFabState extends State<_CreateFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        AppRouter.push(context, AppRoutes.createListing);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.onSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: cs.onSurface.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: cs.surface, size: 28),
        ),
      ),
    );
  }
}

// ── Unauthenticated nav — plain NavigationBar ─────────────────────────────────

class _SimpleBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, IconData outline, String label, String route})>
  items;

  const _SimpleBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      indicatorColor: cs.secondary,
      elevation: 10,
      backgroundColor: cs.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.outline),
              selectedIcon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

// ── Single nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: active
                  ? cs.secondary.withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
