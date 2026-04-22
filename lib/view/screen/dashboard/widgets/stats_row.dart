import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';

class DashStatsRow extends StatelessWidget {
  const DashStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final saved = context.watch<UserProvider>().saved.length;
    final listings = context.watch<UserProvider>().myListings.length;
    final inquiries = context.watch<InquiriesProvider>().inquiries.length;
    final h = MediaQuery.of(context).size.width * 0.48;
    final cardH = (h - 10) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: h,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: cardH,
                    child: AnimatedStatCard(
                      label: 'Saved', value: '$saved',
                      icon: Icons.favorite_border_rounded,
                      trend: '+3', positive: true, delay: Duration.zero, cs: cs,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: cardH,
                    child: AnimatedStatCard(
                      label: 'Listings', value: '$listings',
                      icon: Icons.home_work_outlined,
                      trend: 'active', positive: true,
                      delay: const Duration(milliseconds: 80), cs: cs,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: h,
                child: AnimatedStatCard(
                  label: 'Inquiries', value: '$inquiries',
                  icon: Icons.chat_bubble_outline_rounded,
                  trend: '5 new', positive: false,
                  delay: const Duration(milliseconds: 160), cs: cs, large: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final bool positive;
  final Duration delay;
  final ColorScheme cs;
  final bool large;

  const AnimatedStatCard({
    super.key,
    required this.label, required this.value, required this.icon,
    required this.trend, required this.positive, required this.delay,
    required this.cs, this.large = false,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              vertical: widget.large ? 16 : 12, horizontal: widget.large ? 8 : 0),
          decoration: BoxDecoration(
            color: widget.large ? cs.onSurface : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.large ? Colors.transparent : cs.outlineVariant.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: cs.onSurface.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: widget.large ? _LargeContent(widget: widget, cs: cs) : _SmallContent(widget: widget, cs: cs),
        ),
      ),
    );
  }
}

class _LargeContent extends StatelessWidget {
  final AnimatedStatCard widget;
  final ColorScheme cs;
  const _LargeContent({required this.widget, required this.cs});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: cs.surface.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
        child: Icon(widget.icon, size: 20, color: cs.surface),
      ),
      const SizedBox(height: 10),
      Text(widget.value, style: GoogleFonts.notoSerif(fontSize: 30, fontWeight: FontWeight.w900, color: cs.surface, height: 1)),
      const SizedBox(height: 3),
      Text(widget.label, style: GoogleFonts.inter(fontSize: 10, color: cs.surface.withOpacity(0.6), fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: cs.surface.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
        child: Text(widget.trend, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: cs.surface, letterSpacing: 0.4)),
      ),
    ],
  );
}

class _SmallContent extends StatelessWidget {
  final AnimatedStatCard widget;
  final ColorScheme cs;
  const _SmallContent({required this.widget, required this.cs});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: cs.surfaceContainerHighest.withOpacity(0.6), borderRadius: BorderRadius.circular(11)),
          child: Icon(widget.icon, size: 17, color: cs.onSurface),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.value, style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1)),
              const SizedBox(height: 3),
              Text(widget.label, style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  );
}
