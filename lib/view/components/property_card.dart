import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

/// Property data model shared across cards.
class PropertyItem {
  final String title;
  final String location;
  final String price;
  final String bhk;
  final String sqft;
  final String badge;
  final String imageUrl;

  const PropertyItem({
    required this.title,
    required this.location,
    required this.price,
    required this.bhk,
    required this.sqft,
    this.badge = '',
    required this.imageUrl,
  });
}

/// Compact horizontal card — used in home screen featured listings.
class PropertyCardHorizontal extends StatelessWidget {
  final PropertyItem item;
  final VoidCallback? onTap;

  const PropertyCardHorizontal({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(children: [
              Image.network(item.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              if (item.badge.isNotEmpty)
                Positioned(
                  top: 12, left: 12,
                  child: AppBadge(label: item.badge),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                ),
                const SizedBox(width: 8),
                Text(item.price,
                  style: GoogleFonts.inter(color: cs.primary, fontWeight: FontWeight.w900, fontSize: 14)),
              ]),
              const SizedBox(height: 4),
              _LocationRow(location: item.location),
              const SizedBox(height: 12),
              Divider(color: cs.outlineVariant.withOpacity(0.3), height: 1),
              const SizedBox(height: 10),
              _StatsRow(bhk: item.bhk, sqft: item.sqft),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Editorial vertical card — used in buy screen grid with optional stagger offset.
class PropertyCardVertical extends StatelessWidget {
  final PropertyItem item;
  final bool staggered;
  final VoidCallback? onTap;

  const PropertyCardVertical({
    super.key,
    required this.item,
    this.staggered = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: staggered ? 48 : 0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(item.imageUrl, fit: BoxFit.cover),
                if (item.badge.isNotEmpty)
                  Positioned(top: 14, left: 14, child: AppBadge(label: item.badge)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.title,
                        style: GoogleFonts.notoSerif(
                          fontSize: 20, color: cs.onSurface, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      _LocationRow(location: item.location),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Text(item.price,
                    style: GoogleFonts.notoSerif(
                      fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              _StatsRow(bhk: item.bhk, sqft: item.sqft, iconSize: 14),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  final String location;
  const _LocationRow({required this.location});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
      const SizedBox(width: 2),
      Flexible(
        child: Text(location,
          style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
      ),
    ]);
  }
}

class _StatsRow extends StatelessWidget {
  final String bhk;
  final String sqft;
  final double iconSize;
  const _StatsRow({required this.bhk, required this.sqft, this.iconSize = 16});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.outline;
    return Row(children: [
      Icon(Icons.bed_outlined, size: iconSize, color: color),
      const SizedBox(width: 4),
      Text(bhk,
        style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
      const SizedBox(width: 16),
      Icon(Icons.straighten_outlined, size: iconSize, color: color),
      const SizedBox(width: 4),
      Text(sqft,
        style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
    ]);
  }
}

/// Pill badge shown on property images.
class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.bold,
          color: textColor ?? cs.onTertiaryContainer,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
