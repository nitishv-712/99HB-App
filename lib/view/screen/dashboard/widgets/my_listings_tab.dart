import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'dash_states.dart';

class DashMyListingsTab extends StatelessWidget {
  const DashMyListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    if (provider.listingsLoading) {
      return SkeletonList(itemBuilder: () => const SkeletonListRow());
    }
    if (provider.listingsError != null) {
      return DashErrorState(
        message: provider.listingsError!,
        onRetry: () => context.read<UserProvider>().fetchMyListings(),
      );
    }
    if (provider.myListings.isEmpty) {
      return DashEmptyState(
        icon: Icons.home_work_outlined,
        title: 'No listings yet',
        subtitle: 'Your published properties will appear here.',
        action: 'Add Listing',
        onAction: () {},
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: provider.myListings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _ListingRow(property: provider.myListings[i], index: i),
    );
  }
}

class _ListingRow extends StatefulWidget {
  final ApiProperty property;
  final int index;
  const _ListingRow({required this.property, required this.index});

  @override
  State<_ListingRow> createState() => _ListingRowState();
}

class _ListingRowState extends State<_ListingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.05, 0),
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
    final status = widget.property.status.name.toUpperCase();
    final isActive = widget.property.status == PropertyStatus.active;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => AppRouter.push(
            context,
            AppRoutes.propertyDetail,
            args: widget.property.id,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _ImgPlaceholder(cs: cs),
                          )
                        : _ImgPlaceholder(cs: cs),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.title,
                        style: GoogleFonts.notoSerif(
                          fontSize: 14,
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
                              widget.property.locationString,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            widget.property.priceLabel,
                            style: GoogleFonts.notoSerif(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEAF3DE)
                                  : cs.surfaceContainerHighest.withValues(
                                      alpha: 0.5,
                                    ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF27500A)
                                    : cs.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
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
