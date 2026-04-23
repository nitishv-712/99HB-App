import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                cs.surfaceContainerHighest.withValues(alpha: 0.3),
                cs.surfaceContainerHighest.withValues(alpha: 0.5),
                cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

// Property card skeleton
class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SkeletonLoader(
            width: double.infinity,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 12),
        SkeletonLoader(
          width: double.infinity,
          height: 16,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        SkeletonLoader(
          width: 120,
          height: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SkeletonLoader(
              width: 60,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(width: 12),
            SkeletonLoader(
              width: 60,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ],
    );
  }
}

// Listing row skeleton
class ListingRowSkeleton extends StatelessWidget {
  const ListingRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 76,
            height: 76,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 100,
                  height: 11,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonLoader(
                      width: 80,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const Spacer(),
                    SkeletonLoader(
                      width: 60,
                      height: 20,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
