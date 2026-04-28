import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/loaders.dart';

class PropertyAnalyticsScreen extends StatefulWidget {
  final String propertyId;
  final String? propertyTitle;
  const PropertyAnalyticsScreen({
    super.key,
    required this.propertyId,
    this.propertyTitle,
  });

  @override
  State<PropertyAnalyticsScreen> createState() =>
      _PropertyAnalyticsScreenState();
}

class _PropertyAnalyticsScreenState extends State<PropertyAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AnalyticsProvider>().fetchPropertyAnalytics(
        widget.propertyId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: widget.propertyTitle ?? 'Property Analytics',
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (_, prov, _) {
          if (prov.propertyLoading) {
            return const SkeletonAnalytics();
          }
          if (prov.propertyError != null) {
            return AppErrorRetry(
              message: prov.propertyError!,
              onRetry: () => prov.fetchPropertyAnalytics(widget.propertyId),
            );
          }
          final data = prov.propertyAnalytics;
          if (data == null) return const SizedBox.shrink();
          return _Body(data: data);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PropertyAnalytics data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = data.property;
    final a = data.analytics;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // Property summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.onSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title,
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: cs.surface,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _PillDark(p.status.name.toUpperCase()),
                  const SizedBox(width: 8),
                  _PillDark(p.listingType.name.toUpperCase()),
                  const SizedBox(width: 8),
                  _PillDark('${p.daysListed} days listed'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const AppSectionLabel('PERFORMANCE'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Views',
                value: '${a.totalViews}',
                icon: Icons.visibility_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Saves',
                value: '${a.totalSaves}',
                icon: Icons.bookmark_border_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Inquiries',
                value: '${a.totalInquiries}',
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Conversion',
                value: '${a.conversionRate.toStringAsFixed(1)}%',
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Save Rate',
          value: '${a.saveRate.toStringAsFixed(1)}%',
          icon: Icons.favorite_border_rounded,
        ),

        const SizedBox(height: 24),
        const AppSectionLabel('INQUIRY STATUS'),
        const SizedBox(height: 12),
        _InquiryStatusCard(status: a.inquiryStatus),

        if (a.inquiryTrend.isNotEmpty) ...[
          const SizedBox(height: 24),
          const AppSectionLabel('INQUIRY TREND'),
          const SizedBox(height: 12),
          _TrendChart(points: a.inquiryTrend),
        ],

        if (a.inquiries.isNotEmpty) ...[
          const SizedBox(height: 24),
          const AppSectionLabel('RECENT INQUIRIES'),
          const SizedBox(height: 12),
          ...a.inquiries.take(10).map((inq) => _InquiryRow(inq: inq)),
        ],
      ],
    );
  }
}

class _PillDark extends StatelessWidget {
  final String label;
  const _PillDark(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: cs.surface,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InquiryStatusCard extends StatelessWidget {
  final InquiryStatusBreakdown status;
  const _InquiryStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = status.active + status.closed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatusItem(
              label: 'Active',
              value: status.active,
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatusItem(
              label: 'Closed',
              value: status.closed,
              color: cs.onSurfaceVariant,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatusItem(
              label: 'Total',
              value: total,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.notoSerif(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<TrendPoint> points;
  const _TrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = points.map((p) => p.count).reduce((a, b) => a > b ? a : b);
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final h = maxVal > 0 ? p.count / maxVal : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Tooltip(
                message: '${p.date}: ${p.count}',
                child: Container(
                  height: 76 * h,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InquiryRow extends StatelessWidget {
  final dynamic inq;
  const _InquiryRow({required this.inq});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = inq.status == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              inq.id as String,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            (inq.status as String).toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green.shade700 : cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
