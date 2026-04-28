import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'buy_property_card.dart';
import 'package:homebazaar/view/components/loaders.dart';

class BuyResultsSliver extends StatelessWidget {
  final VoidCallback onRetry;
  const BuyResultsSliver({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<PropertiesProvider>();

    if (provider.listLoading) return const SkeletonPropertyGrid();

    if (provider.listError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Icon(Icons.error_outline_rounded, color: cs.error, size: 32),
              const SizedBox(height: 12),
              Text(provider.listError!, textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 13)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(10)),
                  child: Text('Retry', style: TextStyle(color: cs.surface, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    if (provider.properties.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off_rounded, color: cs.onSurfaceVariant, size: 40),
              const SizedBox(height: 12),
              Text('No properties found',
                  style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Try adjusting your filters',
                  style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6), fontSize: 12)),
            ]),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            Text('${provider.properties.length}',
                style: GoogleFonts.notoSerif(fontSize: 16, fontWeight: FontWeight.w900, color: cs.onSurface)),
            const SizedBox(width: 6),
            Text('properties found', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 12, childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => BuyPropertyCard(property: provider.properties[i]),
            childCount: provider.properties.length,
          ),
        ),
      ),
    ]);
  }
}
