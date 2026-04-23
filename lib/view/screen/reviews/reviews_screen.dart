import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/skeleton_loader.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReviewsProvider>().fetchMyReviews(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppStandardBar(title: 'My Reviews'),
      body: Consumer<ReviewsProvider>(
        builder: (_, prov, __) {
          if (prov.myLoading) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => SkeletonLoader(
                height: 140,
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }
          if (prov.myError != null) {
            return AppErrorRetry(
              message: prov.myError!,
              onRetry: prov.fetchMyReviews,
            );
          }
          if (prov.myReviews.isEmpty) {
            return const AppEmptyState(
              icon: Icons.star_border_rounded,
              title: 'No reviews yet',
              subtitle: 'Reviews you write on properties will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.myReviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ReviewCard(review: prov.myReviews[i]),
          );
        },
      ),
    );
  }
}

// ── Review Card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatefulWidget {
  final ApiReview review;
  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _deleting = false;

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete review?',
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _deleting = true);
    final ok = await context.read<ReviewsProvider>().delete(widget.review.id);
    if (mounted) {
      setState(() => _deleting = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final review = widget.review;
    final prop = review.property is ApiProperty
        ? review.property as ApiProperty
        : null;

    final isPublished = review.status == ReviewStatus.published;
    final statusBg = isPublished
        ? const Color(0xFF10B981).withOpacity(0.12)
        : const Color(0xFFF59E0B).withOpacity(0.12);
    final statusFg =
        isPublished ? const Color(0xFF34D399) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: stars + status + actions ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StarRow(rating: review.rating),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            review.status.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: statusFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit button (stub)
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit_outlined,
                    size: 16, color: cs.onSurfaceVariant),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Delete button
              _deleting
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: _delete,
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 16, color: cs.error),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Comment ────────────────────────────────────────────────────
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 10),

          // ── Footer: property name + date ───────────────────────────────
          Row(
            children: [
              if (prop != null) ...[
                Icon(Icons.home_outlined, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    prop.title,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              Text(
                review.createdAt.length >= 10
                    ? review.createdAt.substring(0, 10)
                    : review.createdAt,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurfaceVariant.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Star Row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final int rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: filled ? cs.onSurface : cs.onSurfaceVariant.withOpacity(0.4),
        );
      }),
    );
  }
}
