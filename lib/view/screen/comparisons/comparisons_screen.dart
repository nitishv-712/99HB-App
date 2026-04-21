import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';

// ── Comparisons List ──────────────────────────────────────────────────────────

class ComparisonsScreen extends StatefulWidget {
  const ComparisonsScreen({super.key});

  @override
  State<ComparisonsScreen> createState() => _ComparisonsScreenState();
}

class _ComparisonsScreenState extends State<ComparisonsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ComparisonsProvider>().fetchList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppStandardBar(title: 'Comparisons'),
      body: Consumer<ComparisonsProvider>(
        builder: (_, prov, __) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return AppErrorRetry(message: prov.error!, onRetry: prov.fetchList);
          }
          if (prov.comparisons.isEmpty) {
            return const AppEmptyState(
              icon: Icons.compare_arrows_outlined,
              title: 'No comparisons',
              subtitle: 'Add properties to compare them side by side.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.comparisons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ComparisonTile(
              comparison: prov.comparisons[i],
              onDelete: () => prov.delete(prov.comparisons[i].id),
            ),
          );
        },
      ),
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  final ApiComparison comparison;
  final VoidCallback onDelete;
  const _ComparisonTile({required this.comparison, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = comparison.propertyIds.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComparisonDetailScreen(comparisonId: comparison.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.compare_arrows_outlined,
                size: 20,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comparison.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count propert${count == 1 ? 'y' : 'ies'}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}

// ── Comparison Detail ─────────────────────────────────────────────────────────

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
    print('Building ComparisonDetailScreen for ${widget.comparisonId}');
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title:
            context.watch<ComparisonsProvider>().detail?.name ?? 'Comparison',
      ),
      body: Consumer<ComparisonsProvider>(
        builder: (_, prov, __) {
          if (prov.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prov.analysis != null) ...[
                  const AppSectionLabel('ANALYSIS'),
                  const SizedBox(height: 12),
                  _AnalysisCard(analysis: prov.analysis!),
                  const SizedBox(height: 24),
                ],
                AppSectionLabel('PROPERTIES (${properties.length})'),
                const SizedBox(height: 12),
                if (properties.isEmpty)
                  Text(
                    'No populated properties',
                    style: TextStyle(color: cs.onSurfaceVariant),
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
        label: 'Price Range',
        value:
            '${_fmt(analysis.priceRange.min)} – ${_fmt(analysis.priceRange.max)}',
      ),
      (
        label: 'Bedrooms',
        value:
            '${analysis.bedroomRange.min.toInt()} – ${analysis.bedroomRange.max.toInt()}',
      ),
      (
        label: 'Sqft',
        value:
            '${analysis.sqftRange.min.toInt()} – ${analysis.sqftRange.max.toInt()}',
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        children: rows
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      r.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final ApiProperty property;
  const _PropertyRow({required this.property});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: property.primaryImageUrl != null
                  ? Image.network(
                      property.primaryImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: cs.surfaceContainerHigh),
                    )
                  : Container(color: cs.surfaceContainerHigh),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  property.priceLabel,
                  style: GoogleFonts.notoSerif(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${property.bedrooms} BHK · ${property.sqft.toInt()} sqft',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
