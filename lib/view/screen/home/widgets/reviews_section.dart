import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/view/components/loaders.dart';

class DetailReviewsSection extends StatelessWidget {
  final String propertyId;
  const DetailReviewsSection({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<ReviewsProvider>(
      builder: (_, prov, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _showSubmitSheet(context, prov, propertyId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    prov.userReview != null ? 'Edit Review' : 'Write Review',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (prov.stats != null) ReviewRatingSummary(stats: prov.stats!),
          if (prov.loading)
            const _SkeletonReviews()
          else if (prov.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No reviews yet. Be the first!',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ),
            )
          else
            ...prov.reviews.map((r) => ReviewItemCard(review: r)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSubmitSheet(
    BuildContext context,
    ReviewsProvider prov,
    String propertyId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: prov,
        child: SubmitReviewSheet(
          propertyId: propertyId,
          existing: prov.userReview,
        ),
      ),
    );
  }
}

class ReviewRatingSummary extends StatelessWidget {
  final ReviewStats stats;
  const ReviewRatingSummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: GoogleFonts.notoSerif(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              ReviewStarRow(rating: stats.averageRating.round()),
              const SizedBox(height: 4),
              Text(
                '${stats.totalReviews} reviews',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = _countForStar(star, stats.ratingBreakdown);
                final pct = stats.totalReviews > 0
                    ? count / stats.totalReviews
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 10,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.amber,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _countForStar(int star, RatingBreakdown b) => switch (star) {
    5 => b.five,
    4 => b.four,
    3 => b.three,
    2 => b.two,
    _ => b.one,
  };
}

class ReviewItemCard extends StatelessWidget {
  final ApiReview review;
  const ReviewItemCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = review.user is ApiUser ? review.user as ApiUser : null;
    final name = user != null
        ? '${user.firstName} ${user.lastName}'
        : 'Anonymous';
    final avatar = user?.avatar;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child: avatar == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      review.createdAt.substring(0, 10),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              ReviewStarRow(rating: review.rating),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewStarRow extends StatelessWidget {
  final int rating;
  const ReviewStarRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (i) => Icon(
        i < rating ? Icons.star_rounded : Icons.star_border_rounded,
        size: 14,
        color: Colors.amber,
      ),
    ),
  );
}

class SubmitReviewSheet extends StatefulWidget {
  final String propertyId;
  final ApiReview? existing;
  const SubmitReviewSheet({
    super.key,
    required this.propertyId,
    required this.existing,
  });

  @override
  State<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends State<SubmitReviewSheet> {
  late int _rating;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _commentCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 5;
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _commentCtrl = TextEditingController(text: widget.existing?.comment ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? 'Edit Review' : 'Write a Review',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'RATING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 36,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Comment',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _loading
                  ? null
                  : () async {
                      if (_titleCtrl.text.trim().isEmpty ||
                          _commentCtrl.text.trim().isEmpty) {
                        return;
                      }
                      setState(() => _loading = true);
                      final ok = isEdit
                          ? await context.read<ReviewsProvider>().update(
                              widget.existing!.id,
                              rating: _rating,
                              title: _titleCtrl.text.trim(),
                              comment: _commentCtrl.text.trim(),
                            )
                          : await context.read<ReviewsProvider>().submit(
                              propertyId: widget.propertyId,
                              rating: _rating,
                              title: _titleCtrl.text.trim(),
                              comment: _commentCtrl.text.trim(),
                            );
                      setState(() => _loading = false);
                      if (ok && context.mounted) Navigator.pop(context);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _loading
                      ? const AppLoaderInline(
                          size: 20,
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : Text(
                          isEdit ? 'Update Review' : 'Submit Review',
                          style: GoogleFonts.inter(
                            color: cs.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SkeletonReviews extends StatelessWidget {
  const _SkeletonReviews();

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 36, height: 36, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 120, height: 12),
                          const SizedBox(height: 4),
                          SkeletonBox(width: 80, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SkeletonBox(width: double.infinity, height: 12),
                const SizedBox(height: 6),
                SkeletonBox(width: double.infinity, height: 10),
                const SizedBox(height: 4),
                SkeletonBox(width: 200, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) =>
        _ShimmerScope(progress: _ctrl.value, child: widget.child),
  );
}

class _ShimmerScope extends InheritedWidget {
  final double progress;
  const _ShimmerScope({required this.progress, required super.child});
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()!.progress;
  @override
  bool updateShouldNotify(_ShimmerScope old) => progress != old.progress;
}
