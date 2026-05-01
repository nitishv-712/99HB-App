import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/loaders.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isAdmin;
  final String adminLabel;
  final String timestamp;
  final bool isEdited;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.isAdmin = false,
    this.adminLabel = 'ADMIN',
    this.isEdited = false,
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

bool chatSameDay(String a, String b) {
  try {
    final da = DateTime.parse(a).toLocal();
    final db = DateTime.parse(b).toLocal();
    return da.year == db.year && da.month == db.month && da.day == db.day;
  } catch (_) {
    return false;
  }
}

String _formatTime(String iso) {
  try {
    final d = DateTime.parse(iso).toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '';
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
// ── Chat Bubble ───────────────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = message.isMe;
    final isAdmin = message.isAdmin;

    // Admin messages always appear on the left regardless of isMe
    final alignLeft = !isMe || isAdmin;

    final bubbleBg = isAdmin
        ? const Color(0xFFFBBF24).withValues(alpha: 0.12)
        : isMe
        ? cs.primary
        : cs.surfaceContainerHighest.withValues(alpha: 0.6);

    final textColor = isMe && !isAdmin ? cs.onPrimary : cs.onSurface;
    final metaColor = isMe && !isAdmin
        ? cs.onPrimary.withValues(alpha: 0.55)
        : cs.onSurfaceVariant.withValues(alpha: 0.7);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 4,
        left: alignLeft ? 8 : 52,
        right: alignLeft ? 52 : 8,
      ),
      child: Align(
        alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(alignLeft ? 4 : 18),
              bottomRight: Radius.circular(alignLeft ? 18 : 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // always start
            mainAxisSize: MainAxisSize.min,
            children: [
              // Admin label
              if (isAdmin) ...[
                Text(
                  message.adminLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 3),
              ],

              // Message text
              Text(
                message.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 4),

              // Time + edited + ticks — always bottom-right of bubble
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (message.isEdited) ...[
                    Text(
                      'edited',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: metaColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(fontSize: 10, color: metaColor),
                  ),
                  if (isMe && !isAdmin) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.done_all_rounded, size: 13, color: metaColor),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────────

class ChatDateSeparator extends StatelessWidget {
  final String iso;
  const ChatDateSeparator({super.key, required this.iso});

  static const _months = [
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

  String _label() {
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(d.year, d.month, d.day);
      final diff = today.difference(date).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      // Same year → omit year
      if (d.year == now.year) return '${d.day} ${_months[d.month]}';
      return '${d.day} ${_months[d.month]} ${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = _label();
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.25)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }
}

// ── Reply Input ───────────────────────────────────────────────────────────────

class ChatReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final bool enabled;
  final String disabledHint;
  final VoidCallback onSend;

  const ChatReplyInput({
    super.key,
    required this.controller,
    required this.sending,
    required this.enabled,
    required this.disabledHint,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final hasText = controller.text.trim().isNotEmpty;

    // ── Disabled state ──
    if (!enabled) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                disabledHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Active state ──
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button — rounded square, not circle
          GestureDetector(
            onTap: (!hasText || sending) ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasText
                    ? cs.primary
                    : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(13), // rounded square
              ),
              child: sending
                  ? Padding(
                      padding: const EdgeInsets.all(11),
                      child: AppLoaderInline(size: 18, strokeWidth: 2),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded, // ↑ more modern than send
                      size: 19,
                      color: hasText
                          ? cs.onPrimary
                          : cs.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
