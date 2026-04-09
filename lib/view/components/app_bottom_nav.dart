import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/auth_provider.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

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
      (
        icon: Icons.message_rounded,
        outlinedIcon: Icons.message_outlined,
        label: 'Inquiries',
        route: AppRoutes.dashboard,
      ),
      if (isAuthenticated)
        (
          icon: Icons.person_rounded,
          outlinedIcon: Icons.person_outline_rounded,
          label: 'Dashboard',
          route: AppRoutes.dashboard,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () => AppRouter.replace(context, item.route),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.onSurface.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.icon : item.outlinedIcon,
                        size: 22,
                        color: selected
                            ? cs.onSurface
                            : cs.onSurface.withOpacity(0.35),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.5,
                          color: selected
                              ? cs.onSurface
                              : cs.onSurface.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
