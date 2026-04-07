import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.search_rounded, Icons.search_outlined, 'Browse'),
    (Icons.login_rounded, Icons.login_outlined, 'Sign In'),
    (Icons.message_rounded, Icons.message_outlined, 'Inquiries'),
    (Icons.support_agent_rounded, Icons.support_agent_outlined, 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => AppRouter.navigateFromBottomNav(context, i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? _items[i].$1 : _items[i].$2,
                        color: selected
                            ? AppColors.primary
                            : cs.onSurface.withOpacity(0.4),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].$3,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          letterSpacing: 0.6,
                          color: selected
                              ? AppColors.primary
                              : cs.onSurface.withOpacity(0.4),
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
