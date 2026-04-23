import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/skeletons.dart';

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
        builder: (_, prov, child) {
          if (prov.loading) {
            return SkeletonList(itemBuilder: () => const SkeletonTile());
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.tickets.length,
            separatorBuilder: (_, i) => const SizedBox(height: 12),
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
      builder: (ctx) => ChangeNotifierProvider.value(
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
          builder: (_) => TicketDetailScreen(ticketId: ticket.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.support_agent_outlined, size: 20, color: color),
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
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _statusLabel(ticket.status),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
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
            child: GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.surface,
                          ),
                        )
                      : Text(
                          'Submit Ticket',
                          style: GoogleFonts.inter(
                            color: cs.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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
  bool _sending = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<SupportProvider>().fetchDetail(widget.ticketId),
    );
    _msgCtrl.addListener(() => setState(() {}));
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
      backgroundColor: cs.surface,
      body: Consumer<SupportProvider>(
        builder: (_, prov, child) {
          if (prov.detailLoading && prov.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.detailError != null) {
            return Scaffold(
              appBar: AppStandardBar(title: 'Ticket'),
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

          // scroll when messages update
          _scrollToBottom();

          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _TicketHeader(
                ticket: ticket,
                closing: _closing,
                onClose: isClosed ? null : _close,
                onBack: () => Navigator.maybePop(context),
              ),

              // ── Messages ────────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final senderId = msg.sender is String
                              ? msg.sender as String
                              : (msg.sender as dynamic).id as String;
                          final senderName = msg.sender is! String
                              ? () {
                                  final u = msg.sender as dynamic;
                                  return '${u.firstName} ${u.lastName}';
                                }()
                              : null;
                          return _SupportBubble(
                            text: msg.text,
                            isMe: senderId == myId,
                            isAdmin: msg.isAdmin,
                            senderName: senderName,
                            timestamp: msg.createdAt,
                          );
                        },
                      ),
              ),

              // ── Reply input ──────────────────────────────────────────────
              _ReplyInput(
                controller: _msgCtrl,
                sending: _sending,
                enabled: !isClosed,
                disabledHint: 'Ticket ${ticket.status == TicketStatus.closed ? 'closed' : 'resolved'} — no further replies',
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Ticket Header ─────────────────────────────────────────────────────────────

class _TicketHeader extends StatelessWidget {
  final ApiSupportTicket ticket;
  final bool closing;
  final VoidCallback? onClose;
  final VoidCallback onBack;

  const _TicketHeader({
    required this.ticket,
    required this.closing,
    required this.onClose,
    required this.onBack,
  });

  static const _priorityColors = {
    TicketPriority.low:    (bg: Color(0x1F10B981), fg: Color(0xFF34D399)),
    TicketPriority.medium: (bg: Color(0x1FFBBF24), fg: Color(0xFFF59E0B)),
    TicketPriority.high:   (bg: Color(0x1FEF4444), fg: Color(0xFFF87171)),
  };

  static const _statusColors = {
    TicketStatus.open:       (bg: Color(0x266366F1), fg: Color(0xFF818CF8)),
    TicketStatus.inProgress: (bg: Color(0x1FFBBF24), fg: Color(0xFFF59E0B)),
    TicketStatus.resolved:   (bg: Color(0x1F10B981), fg: Color(0xFF34D399)),
    TicketStatus.closed:     (bg: Color(0x22000000), fg: Color(0xFF94A3B8)),
  };

  String _statusLabel(TicketStatus s) => switch (s) {
    TicketStatus.open       => 'OPEN',
    TicketStatus.inProgress => 'IN PROGRESS',
    TicketStatus.resolved   => 'RESOLVED',
    TicketStatus.closed     => 'CLOSED',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pColor = _priorityColors[ticket.priority]!;
    final sColor = _statusColors[ticket.status]!;
    final assignedAdmin = ticket.assignedTo is! String && ticket.assignedTo != null
        ? ticket.assignedTo as dynamic
        : null;

    return Container(
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top safe area + back row
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  // Status badge
                  _Badge(label: _statusLabel(ticket.status), bg: sColor.bg, fg: sColor.fg),
                  const SizedBox(width: 6),
                  // Priority badge
                  _Badge(
                    label: ticket.priority.name.toUpperCase(),
                    bg: pColor.bg,
                    fg: pColor.fg,
                  ),
                  const SizedBox(width: 8),
                  // Close button
                  if (onClose != null)
                    GestureDetector(
                      onTap: closing ? null : onClose,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: closing
                            ? SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(strokeWidth: 1.5, color: cs.onSurfaceVariant),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close_rounded, size: 12, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CLOSE',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Subject + meta
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MetaChip(label: 'Category', value: ticket.category.name[0].toUpperCase() + ticket.category.name.substring(1)),
                    _MetaChip(
                      label: 'Opened',
                      value: _formatDate(ticket.createdAt),
                    ),
                    if (assignedAdmin != null)
                      _MetaChip(label: 'Assigned', value: '${assignedAdmin.firstName} ${assignedAdmin.lastName}'),
                    if (ticket.resolvedAt != null)
                      _MetaChip(label: 'Resolved', value: _formatDate(ticket.resolvedAt!)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.2)),
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Support Bubble ────────────────────────────────────────────────────────────

class _SupportBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final bool isAdmin;
  final String? senderName;
  final String timestamp;

  const _SupportBubble({
    required this.text,
    required this.isMe,
    required this.isAdmin,
    required this.timestamp,
    this.senderName,
  });

  String _formatTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final h = d.hour.toString().padLeft(2, '0');
      final m = d.minute.toString().padLeft(2, '0');
      return '${d.day}/${d.month} $h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bubbleBg = isAdmin
        ? const Color(0xFFFBBF24).withValues(alpha: 0.08)
        : isMe
            ? cs.onSurface
            : cs.surfaceContainerHighest.withValues(alpha: 0.5);
    final bubbleBorder = isAdmin
        ? const Color(0xFFFBBF24).withValues(alpha: 0.2)
        : isMe
            ? Colors.transparent
            : cs.outlineVariant.withValues(alpha: 0.25);
    final textColor = isMe && !isAdmin ? cs.surface : cs.onSurface;
    final nameColor = isAdmin ? const Color(0xFFF59E0B) : cs.onSurfaceVariant;
    final nameLabel = isAdmin ? 'SUPPORT' : (senderName ?? 'YOU');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: Border.all(color: bubbleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nameLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: nameColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: isMe && !isAdmin
                        ? cs.surface.withValues(alpha: 0.5)
                        : cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: GoogleFonts.inter(fontSize: 14, color: textColor, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reply Input ───────────────────────────────────────────────────────────────

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final bool enabled;
  final String disabledHint;
  final VoidCallback onSend;

  const _ReplyInput({
    required this.controller,
    required this.sending,
    required this.enabled,
    required this.disabledHint,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!enabled) {
      return Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        child: Text(
          disabledHint,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLength: 5000,
                  maxLines: null,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      const SizedBox.shrink(),
                  style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: (controller.text.trim().isEmpty || sending) ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.text.trim().isEmpty
                        ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                        : cs.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: sending
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.surface),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: controller.text.trim().isEmpty
                              ? cs.onSurfaceVariant
                              : cs.surface,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${controller.text.length}/5000',
            style: GoogleFonts.inter(
                fontSize: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
