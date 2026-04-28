import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopBar extends StatelessWidget {
  final VoidCallback? onSearch;
  final VoidCallback? onNotification;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    this.onSearch,
    this.onNotification,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Brand
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '99',
                          style: GoogleFonts.notoSerif(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'HB',
                          style: GoogleFonts.notoSerif(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurfaceVariant,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  trailing ??
                      Row(
                        children: [
                          _IconBtn(
                            icon: Icons.search_rounded,
                            onTap: onSearch ?? () {},
                            cs: cs,
                          ),
                          const SizedBox(width: 8),
                          _IconBtn(
                            icon: Icons.notifications_none_rounded,
                            onTap: onNotification ?? () {},
                            cs: cs,
                          ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _IconBtn({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: cs.onSurface, size: 20),
      ),
    );
  }
}
