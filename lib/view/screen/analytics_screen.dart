import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_shared.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AnalyticsProvider>().fetchOverview());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppStandardBar(title: 'Analytics'),
      body: Consumer<AnalyticsProvider>(
        builder: (_, prov, __) {
          if (prov.overviewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.overviewError != null) {
            return AppErrorRetry(
                message: prov.overviewError!,
                onRetry: prov.fetchOverview);
          }
          if (prov.overview == null) {
            return const AppEmptyState(
              icon: Icons.analytics_outlined,
              title: 'No data yet',
              subtitle: 'Analytics will appear once you have listings.',
            );
          }
          return _Body(data: prov.overview!);
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _Body extends StatelessWidget {
  final OwnerAnalytics data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        const AppSectionLabel('OVERVIEW'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _StatCard(
                  label: 'Total Views',
                  value: '${data.totalViews}',
                  icon: Icons.visibility_outlined)),
          const SizedBox(width: 12),
          Expanded(
              child: _StatCard(
                  label: 'Total Saves',
                  value: '${data.totalSaves}',
                  icon: Icons.bookmark_border_rounded)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _StatCard(
                  label: 'Inquiries',
                  value: '${data.totalInquiries}',
                  icon: Icons.chat_bubble_outline_rounded)),
          const SizedBox(width: 12),
          Expanded(
              child: _StatCard(
                  label: 'Conversion',
                  value: '${data.conversionRate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded)),
        ]),
        const SizedBox(height: 24),
        const AppSectionLabel('LISTING STATUS'),
        const SizedBox(height: 12),
        _StatusBreakdown(data: data),
        const SizedBox(height: 24),
        const AppSectionLabel('INQUIRY TREND (30 DAYS)'),
        const SizedBox(height: 12),
        _TrendChart(points: data.inquiryTrend),
        if (data.topByViews.isNotEmpty) ...[
          const SizedBox(height: 24),
          const AppSectionLabel('TOP BY VIEWS'),
          const SizedBox(height: 12),
          ...data.topByViews
              .take(5)
              .map((p) => _TopRow(title: p.title, metric: '${p.views} views')),
        ],
        if (data.topByInquiries.isNotEmpty) ...[
          const SizedBox(height: 24),
          const AppSectionLabel('TOP BY INQUIRIES'),
          const SizedBox(height: 12),
          ...data.topByInquiries
              .take(5)
              .map((p) => _TopRow(
                  title: p.title, metric: '${p.inquiries} inquiries')),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatusBreakdown extends StatelessWidget {
  final OwnerAnalytics data;
  const _StatusBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (label: 'Active', value: data.activeListings, color: Colors.green),
      (label: 'Pending', value: data.pendingListings, color: Colors.orange),
      (label: 'Sold', value: data.soldListings, color: cs.primary),
      (label: 'Rented', value: data.rentedListings, color: Colors.blue),
      (
        label: 'Archived',
        value: data.archivedListings,
        color: cs.onSurfaceVariant
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
        children: items.map((item) {
          final pct =
              data.totalListings > 0 ? item.value / data.totalListings : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(item.label,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(item.color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${item.value}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<TrendPoint> points;
  const _TrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (points.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
            child: Text('No trend data',
                style: TextStyle(color: cs.onSurfaceVariant))),
      );
    }
    final maxVal =
        points.map((p) => p.count).reduce((a, b) => a > b ? a : b);
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
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
                    color: cs.onSurface.withOpacity(0.7),
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

class _TopRow extends StatelessWidget {
  final String title;
  final String metric;
  const _TopRow({required this.title, required this.metric});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          Text(metric,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
