import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/skeletons.dart';

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
        builder: (_, prov, __) {
          if (prov.loading) {
            return SkeletonList(itemBuilder: () => const SkeletonTile());
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.inquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _InquiryTile(inquiry: prov.inquiries[i], myId: myId),
          );
        },
      ),
    );
  }
}

// ── Inquiry Tile ──────────────────────────────────────────────────────────────

class _InquiryTile extends StatelessWidget {
  final ApiInquiry inquiry;
  final String? myId;
  const _InquiryTile({required this.inquiry, required this.myId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prop = inquiry.property is ApiProperty
        ? inquiry.property as ApiProperty
        : null;
    final isActive = inquiry.status == InquiryStatus.active;

    final isInquirer = inquiry.user is String
        ? inquiry.user == myId
        : (inquiry.user as ApiUser).id == myId;

    final statusBg = isActive
        ? const Color(0xFF10B981).withOpacity(0.12)
        : cs.surfaceContainerHighest.withOpacity(0.4);
    final statusFg =
        isActive ? const Color(0xFF34D399) : cs.onSurfaceVariant;

    final date = inquiry.lastMessageAt.length >= 10
        ? inquiry.lastMessageAt.substring(0, 10)
        : inquiry.lastMessageAt;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InquiryChatScreen(inquiryId: inquiry.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + date + sent/received
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          inquiry.status.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: statusFg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInquirer ? '(Sent)' : '(Received)',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Property title
                  Text(
                    prop?.title ?? 'Property Inquiry',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Location
                  if (prop?.locationString.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      prop!.locationString,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                Text(
                  'VIEW CHAT',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inquiry Chat ──────────────────────────────────────────────────────────────

class InquiryChatScreen extends StatefulWidget {
  final String inquiryId;
  const InquiryChatScreen({super.key, required this.inquiryId});

  @override
  State<InquiryChatScreen> createState() => _InquiryChatScreenState();
}

class _InquiryChatScreenState extends State<InquiryChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _msgCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<InquiriesProvider>().fetchDetail(widget.inquiryId),
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
    await context.read<InquiriesProvider>().sendMessage(widget.inquiryId, text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  Future<void> _toggleStatus(InquiryStatus current) async {
    setState(() => _updatingStatus = true);
    final next = current == InquiryStatus.active
        ? InquiryStatus.closed
        : InquiryStatus.active;
    await context.read<InquiriesProvider>().updateStatus(widget.inquiryId, next);
    setState(() => _updatingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Consumer<InquiriesProvider>(
        builder: (_, prov, __) {
          if (prov.detailLoading && prov.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.detailError != null) {
            return Scaffold(
              appBar: AppStandardBar(title: 'Inquiry Chat'),
              body: AppErrorRetry(
                message: prov.detailError!,
                onRetry: () => prov.fetchDetail(widget.inquiryId),
              ),
            );
          }
          final detail = prov.detail;
          if (detail == null) return const SizedBox.shrink();

          final inquiry = detail.inquiry;
          final messages = detail.messages;
          final isActive = inquiry.status == InquiryStatus.active;

          final prop = inquiry.property is ApiProperty
              ? inquiry.property as ApiProperty
              : null;
          final inquiryUser =
              inquiry.user is ApiUser ? inquiry.user as ApiUser : null;
          final inquiryOwner =
              inquiry.owner is ApiUser ? inquiry.owner as ApiUser : null;

          final isInquirer = inquiry.user is String
              ? inquiry.user == myId
              : (inquiry.user as ApiUser).id == myId;
          final isOwner = inquiry.owner is String
              ? inquiry.owner == myId
              : (inquiry.owner as ApiUser).id == myId;

          _scrollToBottom();

          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _ChatHeader(
                inquiry: inquiry,
                prop: prop,
                inquiryUser: inquiryUser,
                inquiryOwner: inquiryOwner,
                isInquirer: isInquirer,
                isOwner: isOwner,
                updatingStatus: _updatingStatus,
                onBack: () => Navigator.maybePop(context),
                onToggleStatus: () => _toggleStatus(inquiry.status),
              ),

              // ── Messages ─────────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          return _ChatBubble(
                            message: msg,
                            isMe: msg.sender == myId,
                          );
                        },
                      ),
              ),

              // ── Reply input ───────────────────────────────────────────────
              _ReplyInput(
                controller: _msgCtrl,
                sending: _sending,
                enabled: isActive,
                disabledHint:
                    'This inquiry is closed. Reopen it to continue.',
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Chat Header ───────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final ApiInquiry inquiry;
  final ApiProperty? prop;
  final ApiUser? inquiryUser;
  final ApiUser? inquiryOwner;
  final bool isInquirer;
  final bool isOwner;
  final bool updatingStatus;
  final VoidCallback onBack;
  final VoidCallback onToggleStatus;

  const _ChatHeader({
    required this.inquiry,
    required this.prop,
    required this.inquiryUser,
    required this.inquiryOwner,
    required this.isInquirer,
    required this.isOwner,
    required this.updatingStatus,
    required this.onBack,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = inquiry.status == InquiryStatus.active;

    final statusBg = isActive
        ? const Color(0xFF10B981).withOpacity(0.12)
        : cs.surfaceContainerHighest.withOpacity(0.4);
    final statusFg =
        isActive ? const Color(0xFF34D399) : cs.onSurfaceVariant;

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
                    icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inquiry.status.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: statusFg,
                      ),
                    ),
                  ),
                  // Close / Reopen (owner only)
                  if (isOwner) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: updatingStatus ? null : onToggleStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.3)),
                        ),
                        child: updatingStatus
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: cs.onSurfaceVariant),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.close_rounded
                                        : Icons.refresh_rounded,
                                    size: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActive ? 'CLOSE' : 'REOPEN',
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
                  ],
                ],
              ),
            ),
          ),

          // Property info
          if (prop != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  if (prop!.primaryImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        prop!.primaryImageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: cs.surfaceContainerHighest,
                          child: Icon(Icons.image_outlined,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  if (prop!.primaryImageUrl != null) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prop!.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (prop!.locationString.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            prop!.locationString,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Participants
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Wrap(
              spacing: 16,
              children: [
                _ParticipantChip(
                  label: 'Inquirer',
                  name: inquiryUser != null
                      ? '${inquiryUser!.firstName} ${inquiryUser!.lastName}'
                      : 'User',
                  isYou: isInquirer,
                ),
                _ParticipantChip(
                  label: 'Owner',
                  name: inquiryOwner != null
                      ? '${inquiryOwner!.firstName} ${inquiryOwner!.lastName}'
                      : 'Owner',
                  isYou: isOwner,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.2)),
        ],
      ),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  final String label;
  final String name;
  final bool isYou;
  const _ParticipantChip(
      {required this.label, required this.name, required this.isYou});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
        children: [
          TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
          TextSpan(text: name),
          if (isYou)
            TextSpan(
              text: ' (You)',
              style: TextStyle(
                  color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ApiMessage message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

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
    final isAdmin = message.role == MessageRole.admin;

    final bubbleBg = isAdmin
        ? const Color(0xFFFBBF24).withOpacity(0.08)
        : isMe
            ? cs.onSurface
            : cs.surfaceContainerHighest.withOpacity(0.5);
    final bubbleBorder = isAdmin
        ? const Color(0xFFFBBF24).withOpacity(0.2)
        : isMe
            ? Colors.transparent
            : cs.outlineVariant.withOpacity(0.25);
    final textColor = isMe && !isAdmin ? cs.surface : cs.onSurface;
    final roleColor =
        isAdmin ? const Color(0xFFF59E0B) : cs.onSurfaceVariant;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        decoration: BoxDecoration(
          color: bubbleBg,
          border: Border.all(color: bubbleBorder),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.role.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: roleColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(message.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: isMe && !isAdmin
                        ? cs.surface.withOpacity(0.5)
                        : cs.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                if (message.isEditedByAdmin) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(edited by admin)',
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        color: const Color(0xFFF59E0B),
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: GoogleFonts.inter(
                  fontSize: 14, color: textColor, height: 1.4),
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
        color: cs.surfaceContainerHighest.withOpacity(0.2),
        child: Text(
          disabledHint,
          textAlign: TextAlign.center,
          style:
              GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border:
            Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
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
                  maxLength: 2000,
                  maxLines: null,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      const SizedBox.shrink(),
                  style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurfaceVariant.withOpacity(0.5)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: cs.outlineVariant.withOpacity(0.4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: (controller.text.trim().isEmpty || sending)
                    ? null
                    : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.text.trim().isEmpty
                        ? cs.surfaceContainerHighest.withOpacity(0.4)
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
            '${controller.text.length}/2000',
            style: GoogleFonts.inter(
                fontSize: 10,
                color: cs.onSurfaceVariant.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
