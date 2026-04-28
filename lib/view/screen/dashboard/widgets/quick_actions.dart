import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';

class DashQuickActions extends StatelessWidget {
  const DashQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _Action(
        icon: Icons.analytics_outlined,
        label: 'Analytics',
        desc: 'Performance insights',
        route: AppRoutes.analytics,
        colors: isDark
            ? [const Color(0xFF1E293B), const Color(0xFF334155)]
            : [const Color(0xFFE43636), const Color(0xFFFF6B6B)],
      ),
      _Action(
        icon: Icons.compare_arrows_rounded,
        label: 'Comparisons',
        desc: 'Compare properties',
        route: AppRoutes.comparisons,
        colors: isDark
            ? [const Color(0xFF1E3A5F), const Color(0xFF1E293B)]
            : [const Color(0xFF494836), const Color(0xFF6B6950)],
      ),
      _Action(
        icon: Icons.rate_review_outlined,
        label: 'My Reviews',
        desc: 'Reviews you wrote',
        route: AppRoutes.reviews,
        colors: isDark
            ? [const Color(0xFF2D1B1B), const Color(0xFF3D2020)]
            : [const Color(0xFFB5451B), const Color(0xFFE43636)],
      ),
      _Action(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Inquiries',
        desc: 'Property inquiries',
        route: AppRoutes.inquiries,
        colors: isDark
            ? [const Color(0xFF0F2A1E), const Color(0xFF1A3D2B)]
            : [const Color(0xFF2D6A4F), const Color(0xFF40916C)],
      ),
      _Action(
        icon: Icons.history_rounded,
        label: 'Search History',
        desc: 'Your recent searches',
        route: AppRoutes.searchHistory,
        colors: isDark
            ? [const Color(0xFF2A1F0F), const Color(0xFF3D2E12)]
            : [const Color(0xFF8B6914), const Color(0xFFB8860B)],
      ),
      _Action(
        icon: Icons.support_agent_outlined,
        label: 'Support',
        desc: 'Help & tickets',
        route: AppRoutes.support,
        colors: isDark
            ? [const Color(0xFF1A1A2E), const Color(0xFF2D2D4A)]
            : [const Color(0xFF3D3580), const Color(0xFF5C52B8)],
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: actions.length,
            itemBuilder: (_, i) => _ActionCard(
              action: actions[i],
              delay: Duration(milliseconds: i * 60),
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final String desc;
  final String route;
  final List<Color> colors;
  const _Action({
    required this.icon,
    required this.label,
    required this.desc,
    required this.route,
    required this.colors,
  });
}

class _ActionCard extends StatefulWidget {
  final _Action action;
  final Duration delay;
  const _ActionCard({required this.action, required this.delay});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            AppRouter.push(context, a.route);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: a.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: a.colors[0].withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background circle decoration
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: -16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.icon, size: 18, color: Colors.white),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: cs.surface.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
