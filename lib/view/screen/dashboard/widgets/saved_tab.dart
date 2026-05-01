import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/saved_provider.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'dash_states.dart';

class DashSavedTab extends StatefulWidget {
  const DashSavedTab({super.key});

  @override
  State<DashSavedTab> createState() => _DashSavedTabState();
}

class _DashSavedTabState extends State<DashSavedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedProvider>().invalidate();
      context.read<SavedProvider>().fetchList();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<SavedProvider>();
    if (provider.loading) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const SkeletonPropertyCard(),
      );
    }
    if (provider.error != null) {
      return DashErrorState(
        message: provider.error!,
        onRetry: () {
          provider.invalidate();
          provider.fetchList();
        },
      );
    }
    final saved = provider.items
        .map(
          (s) => s.property is ApiProperty ? s.property as ApiProperty : null,
        )
        .whereType<ApiProperty>()
        .toList();
    if (saved.isEmpty) {
      return const DashEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved properties',
        subtitle: 'Properties you save will appear here.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 28,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: saved.length,
      itemBuilder: (_, i) =>
          _SavedPropertyCard(property: saved[i], staggered: i.isOdd, index: i),
    );
  }
}

class _SavedPropertyCard extends StatefulWidget {
  final ApiProperty property;
  final bool staggered;
  final int index;
  const _SavedPropertyCard({
    required this.property,
    required this.staggered,
    required this.index,
  });

  @override
  State<_SavedPropertyCard> createState() => _SavedPropertyCardState();
}

class _SavedPropertyCardState extends State<_SavedPropertyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrl = widget.property.primaryImageUrl;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(top: widget.staggered ? 36 : 0),
          child: GestureDetector(
            onTap: () => AppRouter.push(
              context,
              AppRoutes.propertyDetail,
              args: widget.property.id,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _ImgPlaceholder(cs: cs),
                              )
                            : _ImgPlaceholder(cs: cs),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.45),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            widget.property.priceLabel,
                            style: GoogleFonts.notoSerif(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => context.read<SavedProvider>().toggle(
                              widget.property.id,
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: cs.surface.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bookmark_rounded,
                                size: 14,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.property.title,
                  style: GoogleFonts.notoSerif(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        "${widget.property.address.city}, ${widget.property.address.state}",
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  final ColorScheme cs;
  const _ImgPlaceholder({required this.cs});
  @override
  Widget build(BuildContext context) => Container(
    color: cs.surfaceContainerHigh,
    child: Icon(Icons.image_outlined, color: cs.outline, size: 28),
  );
}
