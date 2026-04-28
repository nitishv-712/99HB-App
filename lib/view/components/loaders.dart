import 'package:flutter/material.dart';

// ── Full-screen overlay loader ────────────────────────────────────────────────

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black26,
      child: Center(child: _LoaderCard()),
    );
  }
}

class _LoaderCard extends StatelessWidget {
  const _LoaderCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: cs.onSurface.withValues(alpha: 0.08), blurRadius: 24),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(cs.onSurface),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait...',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline button spinner ─────────────────────────────────────────────────────

class AppLoaderInline extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  const AppLoaderInline({super.key, this.size = 20, this.color, this.strokeWidth = 2.5});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── Center spinner (for empty states / pagination) ────────────────────────────

class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ── Shimmer base ──────────────────────────────────────────────────────────────

/// Public wrapper — use this when you need [SkeletonBox] children to animate.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  const SkeletonShimmer({super.key, required this.child});
  @override
  Widget build(BuildContext context) => _Shimmer(child: child);
}

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => _ShimmerScope(progress: _ctrl.value, child: widget.child),
    );
  }
}

class _ShimmerScope extends InheritedWidget {
  final double progress;
  const _ShimmerScope({required this.progress, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()!.progress;

  @override
  bool updateShouldNotify(_ShimmerScope old) => progress != old.progress;
}

// ── Skeleton box ──────────────────────────────────────────────────────────────

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = _ShimmerScope.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            cs.surfaceContainerHighest,
            cs.surfaceContainerHigh,
            cs.surfaceContainerHighest,
          ],
          stops: [(p - 0.3).clamp(0, 1), p.clamp(0, 1), (p + 0.3).clamp(0, 1)],
        ),
      ),
    );
  }
}

// ── Property card skeleton ────────────────────────────────────────────────────

class SkeletonPropertyCard extends StatelessWidget {
  const SkeletonPropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 18)),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 14),
          const SizedBox(height: 6),
          SkeletonBox(width: 100, height: 10),
          const SizedBox(height: 8),
          Row(children: [
            SkeletonBox(width: 56, height: 10),
            const SizedBox(width: 8),
            SkeletonBox(width: 56, height: 10),
          ]),
        ],
      ),
    );
  }
}

// ── 2-col property grid skeleton ──────────────────────────────────────────────

class SkeletonPropertyGrid extends StatelessWidget {
  final int count;
  const SkeletonPropertyGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => const SkeletonPropertyCard(),
          childCount: count,
        ),
      ),
    );
  }
}

// ── List row skeleton ─────────────────────────────────────────────────────────

class SkeletonListRow extends StatelessWidget {
  const SkeletonListRow({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 76, height: 76, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 10),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Generic list skeleton ─────────────────────────────────────────────────────

class SkeletonList extends StatelessWidget {
  final int count;
  final Widget Function() itemBuilder;
  const SkeletonList({super.key, this.count = 5, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => itemBuilder(),
      ),
    );
  }
}

// ── Tile skeleton ─────────────────────────────────────────────────────────────

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SkeletonBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  SkeletonBox(width: 100, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat bubble skeleton ─────────────────────────────────────────────────────

/// Full chat screen skeleton — header bar + bubbles + input bar.
/// Drop this directly as the loading state inside a [Scaffold] body.
class SkeletonChatScreen extends StatelessWidget {
  const SkeletonChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        // header
        Container(
          color: cs.surface,
          child: SafeArea(
            bottom: false,
            child: _Shimmer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
                child: Row(
                  children: [
                    const SizedBox(width: 48), // back button space
                    SkeletonBox(width: 36, height: 36, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 120, height: 13),
                          const SizedBox(height: 5),
                          SkeletonBox(width: 80, height: 10),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 52, height: 22, radius: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.2)),
        // bubbles
        Expanded(
          child: ColoredBox(
            color: cs.surfaceContainerLowest,
            child: _Shimmer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _SkeletonBubble(isMe: false, width: w * 0.60),
                      _SkeletonBubble(isMe: false, width: w * 0.42),
                      _SkeletonBubble(isMe: true,  width: w * 0.52),
                      _SkeletonBubble(isMe: true,  width: w * 0.68),
                      _SkeletonBubble(isMe: false, width: w * 0.48),
                      _SkeletonBubble(isMe: true,  width: w * 0.38),
                      _SkeletonBubble(isMe: false, width: w * 0.70),
                      _SkeletonBubble(isMe: true,  width: w * 0.55),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // input bar
        Container(
          padding: EdgeInsets.fromLTRB(
            12, 8, 12, 8 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
            ),
          ),
          child: _Shimmer(
            child: Row(
              children: [
                Expanded(
                  child: SkeletonBox(
                    width: double.infinity, height: 44, radius: 24),
                ),
                const SizedBox(width: 8),
                SkeletonBox(width: 44, height: 44, radius: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBubble extends StatelessWidget {
  final bool isMe;
  final double width;
  const _SkeletonBubble({required this.isMe, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 56 : 8,
        right: isMe ? 8 : 56,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: SkeletonBox(width: width, height: 44, radius: 18),
      ),
    );
  }
}

// ── Chat tile skeleton ────────────────────────────────────────────────────────

class SkeletonChatTile extends StatelessWidget {
  const SkeletonChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 46, height: 46, radius: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: SkeletonBox(width: double.infinity, height: 13)),
                    const SizedBox(width: 16),
                    SkeletonBox(width: 36, height: 10),
                  ],
                ),
                const SizedBox(height: 8),
                SkeletonBox(width: 90, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Analytics skeleton ────────────────────────────────────────────────────────

class SkeletonAnalytics extends StatelessWidget {
  const SkeletonAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          SkeletonBox(width: 80, height: 10),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
          ]),
          const SizedBox(height: 24),
          SkeletonBox(width: 120, height: 10),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 120, radius: 16),
          const SizedBox(height: 24),
          SkeletonBox(width: 160, height: 10),
          const SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 100, radius: 16),
        ],
      ),
    );
  }
}

// ── Property detail skeleton ──────────────────────────────────────────────────

class SkeletonPropertyDetail extends StatelessWidget {
  const SkeletonPropertyDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SkeletonBox(width: double.infinity, height: 280, radius: 0),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SkeletonBox(width: 200, height: 22),
                const SizedBox(height: 10),
                SkeletonBox(width: 140, height: 14),
                const SizedBox(height: 16),
                Row(children: [
                  SkeletonBox(width: 80, height: 12),
                  const SizedBox(width: 12),
                  SkeletonBox(width: 80, height: 12),
                  const SizedBox(width: 12),
                  SkeletonBox(width: 80, height: 12),
                ]),
                const SizedBox(height: 24),
                SkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                SkeletonBox(width: 220, height: 12),
                const SizedBox(height: 24),
                SkeletonBox(width: double.infinity, height: 120, radius: 16),
                const SizedBox(height: 24),
                SkeletonBox(width: double.infinity, height: 80, radius: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured listings skeleton ────────────────────────────────────────────────

class SkeletonFeaturedListings extends StatelessWidget {
  const SkeletonFeaturedListings({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: SizedBox(
        height: 300,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, _) => SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SkeletonBox(width: 220, height: double.infinity, radius: 18)),
                const SizedBox(height: 10),
                SkeletonBox(width: 180, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: 120, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
