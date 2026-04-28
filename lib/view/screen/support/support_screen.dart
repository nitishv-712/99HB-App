import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/chat_widgets.dart';
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
            return SkeletonList(
              itemBuilder: () => const SkeletonChatTile(),
            );
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: prov.tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TicketTile(ticket: prov.tickets[i]),
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

// ── Ticket Tile ───────────────────────────────────────────────────────────────

class _TicketTile extends StatelessWidget {
  final ApiSupportTicket ticket;
  const _TicketTile({required this.ticket});

  static const _statusMeta = {
    TicketStatus.open: (
      color: Color(0xFF6366F1),
      label: 'OPEN',
    ),
    TicketStatus.inProgress: (
      color: Color(0xFFF59E0B),
      label: 'IN PROGRESS',
    ),
    TicketStatus.resolved: (
      color: Color(0xFF10B981),
      label: 'RESOLVED',
    ),
    TicketStatus.closed: (
      color: Color(0xFF94A3B8),
      label: 'CLOSED',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final meta = _statusMeta[ticket.status]!;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketChatScreen(ticketId: ticket.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent_outlined,
                  size: 20, color: meta.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.subject,
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
                color: meta.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                meta.label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: meta.color,
                  letterSpacing: 0.8,
                ),
              ),
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
                    child: Text(
                        c.name[0].toUpperCase() + c.name.substring(1)),
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

// ── Ticket Chat Screen ────────────────────────────────────────────────────────

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
  const TicketChatScreen({super.key, required this.ticketId});

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _msgCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SupportProvider>().fetchDetail(widget.ticketId),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    await context.read<SupportProvider>().addMessage(widget.ticketId, text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  Future<void> _close() async {
    setState(() => _closing = true);
    await context.read<SupportProvider>().close(widget.ticketId);
    setState(() => _closing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Consumer<SupportProvider>(
        builder: (_, prov, _) {
          if (prov.detailLoading && prov.detail == null) {
            return const SkeletonChatScreen();
          }
          if (prov.detailError != null) {
            return Scaffold(
              appBar: AppStandardBar(title: 'Support'),
              body: AppErrorRetry(
                message: prov.detailError!,
                onRetry: () => prov.fetchDetail(widget.ticketId),
              ),
            );
          }
          final detail = prov.detail;
          if (detail == null) return const SizedBox.shrink();

          final ticket = detail.ticket;
          final messages = detail.messages;
          final isClosed = ticket.status == TicketStatus.closed ||
              ticket.status == TicketStatus.resolved;

          _scrollToBottom();

          return Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              _TicketChatHeader(
                ticket: ticket,
                closing: _closing,
                onClose: isClosed ? null : _close,
                onBack: () => Navigator.maybePop(context),
              ),

              // ── Messages ──────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final senderId = msg.sender is String
                              ? msg.sender as String
                              : (msg.sender as dynamic).id as String;
                          final showDate = i == 0 ||
                              !chatSameDay(
                                messages[i - 1].createdAt,
                                msg.createdAt,
                              );
                          return Column(
                            children: [
                              if (showDate)
                                ChatDateSeparator(iso: msg.createdAt),
                              ChatBubble(
                                message: ChatMessage(
                                  text: msg.text,
                                  isMe: senderId == myId,
                                  isAdmin: msg.isAdmin,
                                  adminLabel: 'SUPPORT',
                                  timestamp: msg.createdAt,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // ── Input ─────────────────────────────────────────────────
              ChatReplyInput(
                controller: _msgCtrl,
                sending: _sending,
                enabled: !isClosed,
                disabledHint:
                    'Ticket ${ticket.status == TicketStatus.closed ? 'closed' : 'resolved'} — no further replies.',
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Ticket Chat Header ────────────────────────────────────────────────────────

class _TicketChatHeader extends StatelessWidget {
  final ApiSupportTicket ticket;
  final bool closing;
  final VoidCallback? onClose;
  final VoidCallback onBack;

  const _TicketChatHeader({
    required this.ticket,
    required this.closing,
    required this.onClose,
    required this.onBack,
  });

  static const _priorityColors = {
    TicketPriority.low: (bg: Color(0x1F10B981), fg: Color(0xFF34D399)),
    TicketPriority.medium: (bg: Color(0x1FFBBF24), fg: Color(0xFFF59E0B)),
    TicketPriority.high: (bg: Color(0x1FEF4444), fg: Color(0xFFF87171)),
  };

  static const _statusColors = {
    TicketStatus.open: (bg: Color(0x266366F1), fg: Color(0xFF818CF8)),
    TicketStatus.inProgress: (bg: Color(0x1FFBBF24), fg: Color(0xFFF59E0B)),
    TicketStatus.resolved: (bg: Color(0x1F10B981), fg: Color(0xFF34D399)),
    TicketStatus.closed: (bg: Color(0x22000000), fg: Color(0xFF94A3B8)),
  };

  String _statusLabel(TicketStatus s) => switch (s) {
        TicketStatus.open => 'OPEN',
        TicketStatus.inProgress => 'IN PROGRESS',
        TicketStatus.resolved => 'RESOLVED',
        TicketStatus.closed => 'CLOSED',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pColor = _priorityColors[ticket.priority]!;
    final sColor = _statusColors[ticket.status]!;
    final assignedAdmin =
        ticket.assignedTo is! String && ticket.assignedTo != null
            ? ticket.assignedTo as dynamic
            : null;

    return Container(
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded,
                        color: cs.onSurface),
                    onPressed: onBack,
                  ),
                  // Support avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_outlined,
                        size: 18, color: Color(0xFF818CF8)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support Team',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        if (assignedAdmin != null)
                          Text(
                            '${assignedAdmin.firstName} ${assignedAdmin.lastName}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _Badge(
                      label: _statusLabel(ticket.status),
                      bg: sColor.bg,
                      fg: sColor.fg),
                  const SizedBox(width: 6),
                  _Badge(
                    label: ticket.priority.name.toUpperCase(),
                    bg: pColor.bg,
                    fg: pColor.fg,
                  ),
                  if (onClose != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: closing ? null : onClose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: cs.outlineVariant
                                  .withValues(alpha: 0.3)),
                        ),
                        child: closing
                            ? const AppLoaderInline(
                                size: 12, strokeWidth: 1.5)
                            : Text(
                                'Close',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Subject + meta
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MetaChip(
                      label: 'Category',
                      value: ticket.category.name[0].toUpperCase() +
                          ticket.category.name.substring(1),
                    ),
                    _MetaChip(
                      label: 'Opened',
                      value: _formatDate(ticket.createdAt),
                    ),
                    if (ticket.resolvedAt != null)
                      _MetaChip(
                        label: 'Resolved',
                        value: _formatDate(ticket.resolvedAt!),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: fg,
          ),
        ),
      );
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
                color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
