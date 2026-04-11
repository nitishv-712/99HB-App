import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_shared.dart';

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
        (_) => context.read<SupportProvider>().fetchList());
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
        builder: (_, prov, __) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return AppErrorRetry(
                message: prov.error!, onRetry: prov.fetchList);
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TicketTile(ticket: prov.tickets[i]),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SupportProvider>(),
        child: const _CreateTicketSheet(),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final ApiSupportTicket ticket;
  const _TicketTile({required this.ticket});

  Color _statusColor(TicketStatus s, ColorScheme cs) {
    switch (s) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return cs.onSurfaceVariant;
    }
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:
        return 'OPEN';
      case TicketStatus.inProgress:
        return 'IN PROGRESS';
      case TicketStatus.resolved:
        return 'RESOLVED';
      case TicketStatus.closed:
        return 'CLOSED';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(ticket.status, cs);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticketId: ticket.id)),
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
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.support_agent_outlined,
                  size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    ticket.category.name[0].toUpperCase() +
                        ticket.category.name.substring(1),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(_statusLabel(ticket.status),
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.8)),
            ),
          ],
        ),
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
                  borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 20),
          Text('New Support Ticket',
              style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface)),
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
            value: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
            ),
            items: TicketCategory.values
                .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() +
                        c.name.substring(1))))
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
            child: GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.surface))
                      : Text('Submit Ticket',
                          style: GoogleFonts.inter(
                              color: cs.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                ),
              ),
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

// ── Ticket Detail ─────────────────────────────────────────────────────────────

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SupportProvider>().fetchDetail(widget.ticketId));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await context.read<SupportProvider>().addMessage(widget.ticketId, text);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Ticket',
        actions: [
          Consumer<SupportProvider>(
            builder: (_, prov, __) {
              final s = prov.detail?.ticket.status;
              final isOpen =
                  s == TicketStatus.open || s == TicketStatus.inProgress;
              if (!isOpen) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => prov.close(widget.ticketId),
                child: Text('Close',
                    style: TextStyle(
                        color: cs.error, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: Consumer<SupportProvider>(
        builder: (_, prov, __) {
          if (prov.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.detailError != null) {
            return AppErrorRetry(
                message: prov.detailError!,
                onRetry: () => prov.fetchDetail(widget.ticketId));
          }
          final detail = prov.detail;
          if (detail == null) return const SizedBox.shrink();

          final isOpen = detail.ticket.status == TicketStatus.open ||
              detail.ticket.status == TicketStatus.inProgress;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 12),
                color: cs.surfaceContainerHighest.withOpacity(0.3),
                child: Text(detail.ticket.subject,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface)),
              ),
              Expanded(
                child: detail.messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: detail.messages.length,
                        itemBuilder: (_, i) {
                          final msg = detail.messages[i];
                          final senderId = msg.sender is String
                              ? msg.sender as String
                              : (msg.sender as dynamic).id as String;
                          return _SupportBubble(
                            text: msg.text,
                            isMe: senderId == myId,
                            isAdmin: msg.isAdmin,
                          );
                        },
                      ),
              ),
              AppChatInput(
                controller: _msgCtrl,
                onSend: _send,
                enabled: isOpen,
                disabledHint: 'Ticket closed',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SupportBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isAdmin;
  const _SupportBubble(
      {required this.text, required this.isMe, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        decoration: BoxDecoration(
          color: isAdmin
              ? cs.primary.withOpacity(0.1)
              : isMe
                  ? cs.onSurface
                  : cs.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin)
              Text('Support',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: cs.primary)),
            Text(text,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isMe && !isAdmin ? cs.surface : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
