import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;
  const DashEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: GoogleFonts.notoSerif(
                    fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.5)),
            if (action != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: cs.onSurface, borderRadius: BorderRadius.circular(12)),
                  child: Text(action!,
                      style: GoogleFonts.inter(
                          color: cs.surface, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const DashErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 36),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                    color: cs.onSurface, borderRadius: BorderRadius.circular(10)),
                child: Text('Retry',
                    style: TextStyle(color: cs.surface, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
