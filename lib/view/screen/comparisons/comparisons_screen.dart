import 'package:flutter/material.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:homebazaar/view/screen/comparisons/widget/comparison_tile.dart';
import 'package:provider/provider.dart';

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
        builder: (_, prov, _) {
          if (prov.loading) {
            return SkeletonList(itemBuilder: () => const SkeletonTile());
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
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => ComparisonTile(
              comparison: prov.comparisons[i],
              onDelete: () => prov.delete(prov.comparisons[i].id),
            ),
          );
        },
      ),
    );
  }
}
