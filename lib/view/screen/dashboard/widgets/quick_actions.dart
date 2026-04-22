import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/analytics_provider.dart';

class DashQuickActions extends StatelessWidget {
  const DashQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final analytics = context.watch<AnalyticsProvider>().overview;

    final actions = [
      (
        icon: Icons.add_home_outlined,
        label: 'New\nListing',
        onTap: () => AppRouter.push(context, AppRoutes.createListing),
        primary: true,
      ),
      (
        icon: Icons.analytics_outlined,
        label: analytics != null
            ? '${analytics.totalViews}\nViews'
            : 'Analytics',
        onTap: () => AppRouter.push(context, AppRoutes.analytics),
        primary: false,
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Inquiries',
        onTap: () => AppRouter.push(context, AppRoutes.inquiries),
        primary: false,
      ),
      (
        icon: Icons.support_agent_outlined,
        label: 'Support',
        onTap: () => AppRouter.push(context, AppRoutes.support),
        primary: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(actions.length, (i) {
              final a = actions[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < actions.length - 1 ? 10 : 0,
                  ),
                  child: _PressableActionCard(
                    icon: a.icon,
                    label: a.label,
                    onTap: a.onTap,
                    isPrimary: a.primary,
                    cs: cs,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PressableActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final ColorScheme cs;

  const _PressableActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.cs,
  });

  @override
  State<_PressableActionCard> createState() => _PressableActionCardState();
}

class _PressableActionCardState extends State<_PressableActionCard>
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
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: 72,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isPrimary
                  ? cs.onSurface
                  : cs.surfaceContainerHighest.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isPrimary
                    ? cs.onSurface
                    : cs.outlineVariant.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isPrimary ? cs.surface : cs.onSurface,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label.replaceAll('\n', ' '),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: widget.isPrimary ? cs.surface : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
