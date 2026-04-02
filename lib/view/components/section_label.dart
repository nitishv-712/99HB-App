import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
/// Eyebrow label + headline used in section headers across screens.
class SectionLabel extends StatelessWidget {
  final String eyebrow;
  final String headline;
  final double headlineFontSize;

  const SectionLabel({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.headlineFontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        eyebrow.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.bold,
          letterSpacing: 2.5, color: cs.primary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        headline,
        style: GoogleFonts.notoSerif(
          fontSize: headlineFontSize, fontWeight: FontWeight.w900,
          color: cs.onSurface, height: 1.1,
        ),
      ),
    ]);
  }
}

/// Inline section header with a divider line — used inside detail pages.
class SectionDividerHeader extends StatelessWidget {
  final String title;

  const SectionDividerHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Text(title,
        style: GoogleFonts.notoSerif(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(width: 16),
      Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.2))),
    ]);
  }
}

/// Small uppercase field label used in forms.
class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.bold,
        letterSpacing: 2, color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
