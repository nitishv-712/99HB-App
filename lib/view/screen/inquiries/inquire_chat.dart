import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/view/components/app_shared.dart';
import 'package:homebazaar/view/components/chat_widgets.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';

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
    await context.read<InquiriesProvider>().updateStatus(
      widget.inquiryId,
      next,
    );
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
          final inquiryUser = inquiry.user is ApiUser
              ? inquiry.user as ApiUser
              : null;
          final inquiryOwner = inquiry.owner is ApiUser
              ? inquiry.owner as ApiUser
              : null;
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
                                  isMe: msg.senderId == myId,
                                  isAdmin: msg.role == MessageRole.admin,
                                  adminLabel: 'ADMIN',
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

  static const _activeColor = Color(0xFF10B981);

  // ── Fix: capitalize each word in a name ──
  String _capitalizeName(String name) => name
      .trim()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = inquiry.status == InquiryStatus.active;
    final accentColor = isActive ? _activeColor : cs.onSurfaceVariant;

    final otherUser = isInquirer ? inquiryOwner : inquiryUser;

    // ── Fix: capitalize both parts ──
    final otherName = otherUser != null
        ? _capitalizeName('${otherUser.firstName} ${otherUser.lastName}')
        : isInquirer
        ? 'Owner'
        : 'Inquirer';

    final otherAvatar = otherUser?.avatar;
    final initials = otherName.trim().isNotEmpty
        ? otherName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ──
                  Row(
                    children: [
                      // Back button
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

                      // Avatar — two-letter initials, rounded square
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                          image: otherAvatar != null
                              ? DecorationImage(
                                  image: NetworkImage(otherAvatar),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: otherAvatar == null
                            ? Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.inter(
                                    fontSize: initials.length > 1 ? 13 : 15,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),

                      // Name + role subtitle
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isInquirer ? 'Property owner' : 'Inquirer',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Closed',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),

                      // Close / Reopen (owner only)
                      if (isOwner) ...[
                        const SizedBox(width: 7),
                        GestureDetector(
                          onTap: updatingStatus ? null : onToggleStatus,
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
                            child: updatingStatus
                                ? const AppLoaderInline(
                                    size: 12,
                                    strokeWidth: 1.5,
                                  )
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

                  // ── Property strip ──
                  if (prop != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 13,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Re: ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              prop!.title,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
