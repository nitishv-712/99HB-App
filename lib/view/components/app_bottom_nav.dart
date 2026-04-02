import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

/// Shared bottom navigation bar used across all main screens.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.search_rounded, Icons.search_outlined, 'Browse'),
    (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    (Icons.message_rounded, Icons.message_outlined, 'Inquiries'),
    (Icons.support_agent_rounded, Icons.support_agent_outlined, 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => AppRouter.navigateFromBottomNav(context, i),
                behavior: HitTestBehavior.opaque,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    selected ? _items[i].$1 : _items[i].$2,
                    color: selected ? AppColors.primary : cs.onSurface.withOpacity(0.4),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _items[i].$3,
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.8,
                      color: selected ? AppColors.primary : cs.onSurface.withOpacity(0.4),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ),
      ),
    );
  }
}
