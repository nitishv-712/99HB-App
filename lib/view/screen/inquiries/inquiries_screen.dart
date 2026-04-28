import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/chat_widgets.dart';
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
            return SkeletonList(
              itemBuilder: () => const SkeletonChatTile(),
            );
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

    final statusColor =
        isActive ? const Color(0xFF34D399) : cs.onSurfaceVariant;
    final statusBg = isActive
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : cs.surfaceContainerHighest.withValues(alpha: 0.4);

    // last message preview
    final lastMsg = inquiry.lastMessageAt.length >= 10
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
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            // Avatar / icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 22,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prop?.title ?? 'Property Inquiry',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMsg,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          inquiry.status.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isInquirer ? 'Sent by you' : 'Received',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inquiry Chat Screen ───────────────────────────────────────────────────────

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
    await context
        .read<InquiriesProvider>()
        .sendMessage(widget.inquiryId, text);
    setState(() => _sending = false);
    _scrollToBottom();
  }

  Future<void> _toggleStatus(InquiryStatus current) async {
    setState(() => _updatingStatus = true);
    final next = current == InquiryStatus.active
        ? InquiryStatus.closed
        : InquiryStatus.active;
    await context
        .read<InquiriesProvider>()
        .updateStatus(widget.inquiryId, next);
    setState(() => _updatingStatus = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final myId = context.read<AuthProvider>().user?.id;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Consumer<InquiriesProvider>(
        builder: (_, prov, _) {
          if (prov.detailLoading && prov.detail == null) {
            return const SkeletonChatScreen();
          }
          if (prov.detailError != null) {
            return Scaffold(
              appBar: AppStandardBar(title: 'Inquiry'),
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
              // ── Header ────────────────────────────────────────────────
              _InquiryChatHeader(
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

              // ── Messages ──────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'No messages yet.\nSend the first message!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
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
                                  isMe: msg.senderId == myId,
                                  isAdmin: msg.role == MessageRole.admin,
                                  adminLabel: 'ADMIN',
                                  timestamp: msg.createdAt,
                                  isEdited: msg.isEditedByAdmin,
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
                enabled: isActive,
                disabledHint: 'This inquiry is closed. Reopen to continue.',
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Inquiry Chat Header ───────────────────────────────────────────────────────

class _InquiryChatHeader extends StatelessWidget {
  final ApiInquiry inquiry;
  final ApiProperty? prop;
  final ApiUser? inquiryUser;
  final ApiUser? inquiryOwner;
  final bool isInquirer;
  final bool isOwner;
  final bool updatingStatus;
  final VoidCallback onBack;
  final VoidCallback onToggleStatus;

  const _InquiryChatHeader({
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
    final statusColor =
        isActive ? const Color(0xFF34D399) : cs.onSurfaceVariant;
    final statusBg = isActive
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : cs.surfaceContainerHighest.withValues(alpha: 0.4);

    final otherUser = isInquirer ? inquiryOwner : inquiryUser;
    final otherName = otherUser != null
        ? '${otherUser.firstName} ${otherUser.lastName}'
        : isInquirer
            ? 'Owner'
            : 'Inquirer';
    final otherAvatar = otherUser?.avatar;

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                    onPressed: onBack,
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.surfaceContainerHighest,
                    backgroundImage: otherAvatar != null
                        ? NetworkImage(otherAvatar)
                        : null,
                    child: otherAvatar == null
                        ? Text(
                            otherName.isNotEmpty
                                ? otherName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: cs.onSurface,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        if (prop != null)
                          Text(
                            prop!.title,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
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
                        color: statusColor,
                      ),
                    ),
                  ),
                  // Close / Reopen (owner only)
                  if (isOwner) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: updatingStatus ? null : onToggleStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                cs.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: updatingStatus
                            ? const AppLoaderInline(
                                size: 12, strokeWidth: 1.5)
                            : Text(
                                isActive ? 'Close' : 'Reopen',
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
          Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
