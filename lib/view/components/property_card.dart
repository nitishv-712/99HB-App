import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Data model ────────────────────────────────────────────────────────────────

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

// ── Horizontal card ───────────────────────────────────────────────────────────

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
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _ImagePlaceholder(height: 180),
                  ),
                  if (item.badge.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: AppBadge(label: item.badge),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.price,
                        style: GoogleFonts.inter(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _LocationRow(location: item.location),
                  const SizedBox(height: 12),
                  Divider(height: 1),
                  const SizedBox(height: 10),
                  _StatsRow(bhk: item.bhk, sqft: item.sqft),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vertical card ─────────────────────────────────────────────────────────────

/// Editorial vertical card — used in buy screen grid with optional stagger.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ImagePlaceholder(height: null),
                    ),
                    if (item.badge.isNotEmpty)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: AppBadge(label: item.badge),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.notoSerif(
                                fontSize: 18,
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _LocationRow(location: item.location),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.price,
                        style: GoogleFonts.notoSerif(
                          fontSize: 17,
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _StatsRow(bhk: item.bhk, sqft: item.sqft, iconSize: 13),
                ],
              ),
            ),
          ],
        ),
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
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            location,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String bhk;
  final String sqft;
  final double iconSize;
  const _StatsRow({required this.bhk, required this.sqft, this.iconSize = 15});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: color, letterSpacing: 0.5);

    return Row(
      children: [
        Icon(Icons.bed_outlined, size: iconSize, color: color),
        const SizedBox(width: 4),
        Text(bhk, style: labelStyle),
        const SizedBox(width: 16),
        Icon(Icons.straighten_outlined, size: iconSize, color: color),
        const SizedBox(width: 4),
        Text(sqft, style: labelStyle),
      ],
    );
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor ?? cs.onTertiaryContainer,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

/// Generic image placeholder shown when network image fails.
class _ImagePlaceholder extends StatelessWidget {
  final double? height;
  const _ImagePlaceholder({this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      color: cs.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_outlined, color: cs.outline, size: 36),
      ),
    );
  }
}
