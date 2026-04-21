import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';

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
            return const Center(child: CircularProgressIndicator());
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
              subtitle: 'Reviews you write will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.myReviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final review = prov.myReviews[i];
              return _ReviewCard(
                review: review,
                onDelete: () async {
                  final ok = await context.read<ReviewsProvider>().delete(
                    review.id,
                  );
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review deleted')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ApiReview review;
  final VoidCallback onDelete;
  const _ReviewCard({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prop = review.property is ApiProperty
        ? review.property as ApiProperty
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prop?.title ?? 'Property',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppStarRow(rating: review.rating),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.title,
            style: GoogleFonts.notoSerif(
              fontSize: 15,
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
          const SizedBox(height: 8),
          Text(
            review.createdAt.length >= 10
                ? review.createdAt.substring(0, 10)
                : review.createdAt,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
