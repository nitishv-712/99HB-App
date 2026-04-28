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

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = message.isMe;
    final isAdmin = message.isAdmin;

    final bubbleBg = isAdmin
        ? const Color(0xFFFBBF24).withValues(alpha: 0.15)
        : isMe
            ? cs.primary
            : cs.surfaceContainerHighest;
    final textColor = isMe && !isAdmin ? cs.onPrimary : cs.onSurface;
    final metaColor = isMe && !isAdmin
        ? cs.onPrimary.withValues(alpha: 0.6)
        : cs.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 4,
        left: isMe ? 48 : 8,
        right: isMe ? 8 : 48,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.adminLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        'edited',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFFF59E0B),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(fontSize: 10, color: metaColor),
                  ),
                  if (isMe) ...[
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

  String _label() {
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return 'Today';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day) {
        return 'Yesterday';
      }
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _label(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
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

    if (!enabled) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
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
        12,
        8,
        12,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: controller,
                maxLines: null,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor:
                      cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap:
                (controller.text.trim().isEmpty || sending) ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: controller.text.trim().isEmpty
                    ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                    : cs.primary,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: AppLoaderInline(size: 18, strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: controller.text.trim().isEmpty
                          ? cs.onSurfaceVariant
                          : cs.onPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
