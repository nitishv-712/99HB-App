import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';

class ComparisonDetailScreen extends StatefulWidget {
  final String comparisonId;
  const ComparisonDetailScreen({super.key, required this.comparisonId});

  @override
  State<ComparisonDetailScreen> createState() => _ComparisonDetailScreenState();
}

class _ComparisonDetailScreenState extends State<ComparisonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          context.read<ComparisonsProvider>().fetchDetail(widget.comparisonId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title:
            context.watch<ComparisonsProvider>().detail?.name ?? 'Comparison',
      ),
      body: Consumer<ComparisonsProvider>(
        builder: (_, prov, _) {
          if (prov.detailLoading) return const SkeletonAnalytics();
          if (prov.detailError != null) {
            return AppErrorRetry(
              message: prov.detailError!,
              onRetry: () => prov.fetchDetail(widget.comparisonId),
            );
          }
          final detail = prov.detail;
          if (detail == null) return const SizedBox.shrink();

          final properties = detail.propertyIds
              .whereType<ApiProperty>()
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prov.analysis != null) ...[
                  const AppSectionLabel('ANALYSIS'),
                  const SizedBox(height: 10),
                  _AnalysisCard(analysis: prov.analysis!),
                  const SizedBox(height: 24),
                ],
                AppSectionLabel('PROPERTIES (${properties.length})'),
                const SizedBox(height: 10),
                if (properties.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No properties added yet.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...properties.map((p) => _PropertyRow(property: p)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Analysis Card ─────────────────────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  final ComparisonAnalysis analysis;
  const _AnalysisCard({required this.analysis});

  String _fmt(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final rows = [
      (
        icon: Icons.currency_rupee_rounded,
        label: 'Price range',
        value:
            '${_fmt(analysis.priceRange.min)} – ${_fmt(analysis.priceRange.max)}',
      ),
      (
        icon: Icons.bed_outlined,
        label: 'Bedrooms',
        value:
            '${analysis.bedroomRange.min.toInt()} – ${analysis.bedroomRange.max.toInt()} BHK',
      ),
      (
        icon: Icons.square_foot_rounded,
        label: 'Area range',
        value:
            '${analysis.sqftRange.min.toInt()} – ${analysis.sqftRange.max.toInt()} sqft',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          final r = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      r.icon,
                      size: 15,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      r.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Property Row ──────────────────────────────────────────────────────────────

class _PropertyRow extends StatelessWidget {
  final ApiProperty property;
  const _PropertyRow({required this.property});

  String _fmt(double v) {
    if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    return '₹${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accentColor = Color(0xFF378ADD);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(width: 4, color: accentColor),

            // Property image
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: property.primaryImageUrl != null
                      ? Image.network(
                          property.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: cs.surfaceContainerHighest,
                            child: Icon(
                              Icons.home_outlined,
                              size: 22,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.home_outlined,
                            size: 22,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _fmt(property.price),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Chips row
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        _Chip('${property.bedrooms} BHK'),
                        _Chip('${property.sqft.toInt()} sqft'),
                        if (property.listingType == ListingType.rent ||
                            property.listingType == ListingType.sale)
                          _Chip(
                            property.listingType == ListingType.rent
                                ? 'For Rent'
                                : 'For Sale',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
      ),
    );
  }
}
