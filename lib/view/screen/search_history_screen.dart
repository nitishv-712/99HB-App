import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/search_history_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_shared.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SearchHistoryProvider>().fetchList());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Search History',
        actions: [
          Consumer<SearchHistoryProvider>(
            builder: (_, prov, __) {
              if (prov.history.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _confirmClear(context, cs),
                child: Text('Clear All',
                    style: TextStyle(
                        color: cs.error, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: Consumer<SearchHistoryProvider>(
        builder: (_, prov, __) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return AppErrorRetry(
                message: prov.error!, onRetry: prov.fetchList);
          }
          if (prov.history.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No search history',
              subtitle: 'Your recent searches will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = prov.history[i];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.query,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface)),
                          Text(
                            item.createdAt.length >= 10
                                ? item.createdAt.substring(0, 10)
                                : item.createdAt,
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    cs.onSurfaceVariant.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => prov.delete(item.id),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Future<void> _confirmClear(BuildContext context, ColorScheme cs) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text(
            'This will permanently delete all your search history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  Text('Clear', style: TextStyle(color: cs.error))),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<SearchHistoryProvider>().deleteAll();
    }
  }
}
