import 'package:flutter/material.dart';
import 'package:homebazaar/view/screen/inquiries/widget/inquire_tile.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/loaders.dart';

// ── Inquiries List ────────────────────────────────────────────────────────────

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  InquiryStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InquiriesProvider>().fetchMyInquiries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'My Inquiries',
        actions: [
          PopupMenuButton<InquiryStatus?>(
            icon: Icon(Icons.filter_list_rounded, color: cs.onSurface),
            onSelected: (v) {
              setState(() => _filter = v);
              context.read<InquiriesProvider>().fetchMyInquiries(status: v);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(value: InquiryStatus.active, child: Text('Active')),
              PopupMenuItem(value: InquiryStatus.closed, child: Text('Closed')),
            ],
          ),
        ],
      ),
      body: Consumer<InquiriesProvider>(
        builder: (_, prov, _) {
          if (prov.loading) {
            return SkeletonList(itemBuilder: () => const SkeletonChatTile());
          }
          if (prov.error != null) {
            return AppErrorRetry(
              message: prov.error!,
              onRetry: () => prov.fetchMyInquiries(status: _filter),
            );
          }
          if (prov.inquiries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No inquiries',
              subtitle: 'Inquiries you send to properties will appear here.',
            );
          }
          final myId = context.read<AuthProvider>().user?.id;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: prov.inquiries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                InquiryTile(inquiry: prov.inquiries[i], myId: myId),
          );
        },
      ),
    );
  }
}
