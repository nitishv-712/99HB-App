import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_shared.dart';

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
        (_) => context.read<InquiriesProvider>().fetchMyInquiries());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Inquiries',
        actions: [
          PopupMenuButton<InquiryStatus?>(
            icon: Icon(Icons.filter_list_rounded, color: cs.onSurface),
            onSelected: (v) {
              setState(() => _filter = v);
              context.read<InquiriesProvider>().fetchMyInquiries(status: v);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('All')),
              PopupMenuItem(
                  value: InquiryStatus.active, child: Text('Active')),
              PopupMenuItem(
                  value: InquiryStatus.closed, child: Text('Closed')),
            ],
          ),
        ],
      ),
      body: Consumer<InquiriesProvider>(
        builder: (_, prov, __) {
          if (prov.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return AppErrorRetry(
                message: prov.error!,
                onRetry: () => prov.fetchMyInquiries(status: _filter));
          }
          if (prov.inquiries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No inquiries',
              subtitle: 'Your property inquiries will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: prov.inquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _InquiryTile(inquiry: prov.inquiries[i]),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final ApiInquiry inquiry;
  const _InquiryTile({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prop = inquiry.property is ApiProperty
        ? inquiry.property as ApiProperty
        : null;
    final isActive = inquiry.status == InquiryStatus.active;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InquiryChatScreen(inquiryId: inquiry.id)),
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
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : cs.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: isActive
                      ? Colors.green.shade700
                      : cs.onSurfaceVariant),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prop?.title ?? 'Property',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prop?.locationString.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(prop!.locationString,
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : cs.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                inquiry.status.name.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.green.shade700
                        : cs.onSurfaceVariant,
                    letterSpacing: 0.8),
              ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<InquiriesProvider>().fetchDetail(widget.inquiryId));
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
    await context.read<InquiriesProvider>().sendMessage(widget.inquiryId, text);
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
        title: 'Inquiry Chat',
        actions: [
          Consumer<InquiriesProvider>(
            builder: (_, prov, __) {
              if (prov.detail?.inquiry.status != InquiryStatus.active) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () =>
                    prov.updateStatus(widget.inquiryId, InquiryStatus.closed),
                child: Text('Close',
                    style: TextStyle(
                        color: cs.error, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
      body: Consumer<InquiriesProvider>(
        builder: (_, prov, __) {
          if (prov.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.detailError != null) {
            return AppErrorRetry(
                message: prov.detailError!,
                onRetry: () => prov.fetchDetail(widget.inquiryId));
          }
          final messages = prov.detail?.messages ?? [];
          final isActive =
              prov.detail?.inquiry.status == InquiryStatus.active;
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          return _ChatBubble(
                              message: msg, isMe: msg.sender == myId);
                        },
                      ),
              ),
              AppChatInput(
                controller: _msgCtrl,
                onSend: _send,
                enabled: isActive,
                disabledHint: 'Inquiry closed',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ApiMessage message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

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
          color: isMe
              ? cs.onSurface
              : cs.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(message.text,
            style: GoogleFonts.inter(
                fontSize: 14,
                color: isMe ? cs.surface : cs.onSurface)),
      ),
    );
  }
}
