import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/screen/support/widget/support_tile.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/loaders.dart';

// ── Support List ──────────────────────────────────────────────────────────────

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SupportProvider>().fetchList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Support',
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: cs.onSurface),
            onPressed: () => _showCreateSheet(context),
          ),
        ],
      ),
      body: Consumer<SupportProvider>(
        builder: (_, prov, _) {
          if (prov.loading) {
            return SkeletonList(itemBuilder: () => const SkeletonChatTile());
          }
          if (prov.error != null) {
            return AppErrorRetry(message: prov.error!, onRetry: prov.fetchList);
          }
          if (prov.tickets.isEmpty) {
            return AppEmptyState(
              icon: Icons.support_agent_outlined,
              title: 'No tickets',
              subtitle: 'Create a support ticket if you need help.',
              action: 'New Ticket',
              onAction: () => _showCreateSheet(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: prov.tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => TicketTile(ticket: prov.tickets[i]),
          );
        },
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SupportProvider>(),
        child: const _CreateTicketSheet(),
      ),
    );
  }
}

// ── Create Ticket Sheet ───────────────────────────────────────────────────────

class _CreateTicketSheet extends StatefulWidget {
  const _CreateTicketSheet();

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _subjectCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  TicketCategory _category = TicketCategory.other;
  bool _loading = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Support Ticket',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _subjectCtrl,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Subject',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TicketCategory>(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
            ),
            items: TicketCategory.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            maxLines: 4,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Message',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const AppLoaderInline(size: 20, strokeWidth: 2)
                  : const Text('Submit Ticket'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty || _msgCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<SupportProvider>().create(
      subject: _subjectCtrl.text.trim(),
      category: _category,
      message: _msgCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (ok && mounted) Navigator.pop(context);
  }
}
