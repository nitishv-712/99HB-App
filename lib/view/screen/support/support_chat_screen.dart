import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/support_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/chat_widgets.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';

import '../../../model/support_ticket.dart';

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
          final isClosed =
              ticket.status == TicketStatus.closed ||
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
                          final showDate =
                              i == 0 ||
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

  static const _statusMeta = {
    TicketStatus.open: (color: Color(0xFF6366F1), label: 'Open'),
    TicketStatus.inProgress: (color: Color(0xFFF59E0B), label: 'In progress'),
    TicketStatus.resolved: (color: Color(0xFF10B981), label: 'Resolved'),
    TicketStatus.closed: (color: Color(0xFF94A3B8), label: 'Closed'),
  };

  static const _priorityMeta = {
    TicketPriority.low: (color: Color(0xFF10B981), label: 'Low'),
    TicketPriority.medium: (color: Color(0xFFF59E0B), label: 'Medium'),
    TicketPriority.high: (color: Color(0xFFEF4444), label: 'High'),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sMeta = _statusMeta[ticket.status]!;
    final pMeta = _priorityMeta[ticket.priority]!;

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
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ──
                  Row(
                    children: [
                      // Back
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Avatar — rounded square, indigo tint
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.support_agent_outlined,
                          size: 20,
                          color: Color(0xFF818CF8),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Name + assigned agent
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
                                '${assignedAdmin.firstName} ${assignedAdmin.lastName} · Agent',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status + priority pills
                      _Pill(label: sMeta.label, color: sMeta.color),
                      const SizedBox(width: 5),
                      _Pill(label: pMeta.label, color: pMeta.color),

                      // Close button
                      if (onClose != null) ...[
                        const SizedBox(width: 7),
                        GestureDetector(
                          onTap: closing ? null : onClose,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: closing
                                ? const AppLoaderInline(
                                    size: 12,
                                    strokeWidth: 1.5,
                                  )
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
                  const SizedBox(height: 12),

                  // ── Subject ──
                  Text(
                    ticket.subject,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Meta chips ──
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                        label: 'Category',
                        value:
                            ticket.category.name[0].toUpperCase() +
                            ticket.category.name.substring(1),
                      ),
                      _MetaChip(
                        label: 'Ticket',
                        value:
                            '#TKT-${ticket.id.substring(0, 6).toUpperCase()}',
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
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ── Shared pill widget ────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
