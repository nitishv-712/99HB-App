import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/model/property.dart';

class DetailHeroGallery extends StatelessWidget {
  final ApiProperty property;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const DetailHeroGallery({
    super.key,
    required this.property,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final images = property.images;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (images.isNotEmpty)
                PageView.builder(
                  controller: pageCtrl,
                  onPageChanged: onPageChanged,
                  itemCount: images.length,
                  itemBuilder: (_, i) => Image.network(
                    images[i].url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.broken_image_outlined, size: 48, color: cs.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Container(
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    _GalleryBadge(
                      property.tag.toUpperCase(),
                      cs.primary,
                      cs.onPrimary,
                    ),
                    if (property.badge != null) ...[
                      const SizedBox(width: 8),
                      _GalleryBadge(
                        property.badge!.name.toUpperCase(),
                        cs.tertiaryContainer,
                        cs.onTertiaryContainer,
                      ),
                    ],
                  ],
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _GalleryDot(active: i == currentPage),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _GalleryBadge(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: fg,
        letterSpacing: 1.5,
      ),
    ),
  );
}

class _GalleryDot extends StatelessWidget {
  final bool active;
  const _GalleryDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? cs.surface : cs.surface.withValues(alpha: 0.4),
      ),
    );
  }
}
