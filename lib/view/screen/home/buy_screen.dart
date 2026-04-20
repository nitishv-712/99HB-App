import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_top_bar.dart';

// ── Filter config ─────────────────────────────────────────────────────────────

const _propTypes = [
  (label: 'All', type: null),
  (label: 'House', type: PropertyType.house),
  (label: 'Apartment', type: PropertyType.apartment),
  (label: 'Villa', type: PropertyType.villa),
  (label: 'Land', type: PropertyType.land),
  (label: 'Office', type: PropertyType.office),
];

const _sortOptions = [
  (label: 'Newest', sort: SortOrder.newest),
  (label: 'Price ↑', sort: SortOrder.priceAsc),
  (label: 'Price ↓', sort: SortOrder.priceDesc),
  (label: 'Popular', sort: SortOrder.popular),
];

const _priceRanges = [
  (label: 'Any Price', min: null, max: null),
  (label: 'Under ₹1Cr', min: null, max: 10000000.0),
  (label: '₹1–5 Cr', min: 10000000.0, max: 50000000.0),
  (label: '₹5Cr+', min: 50000000.0, max: null),
];

const _bedOptions = [
  (label: 'Any BHK', beds: null),
  (label: '2 BHK', beds: '2'),
  (label: '3 BHK', beds: '3'),
  (label: '4+ BHK', beds: '4'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int _typeIndex = 0;
  int _sortIndex = 0;
  int _priceIndex = 0;
  int _bedIndex = 0;
  ListingType _listingType = ListingType.sale;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<PropertiesProvider>().fetchListForced(
      PropertyFilters(
        type: _listingType,
        propType: _propTypes[_typeIndex].type,
        sort: _sortOptions[_sortIndex].sort,
        minPrice: _priceRanges[_priceIndex].min,
        maxPrice: _priceRanges[_priceIndex].max,
        minBeds: _bedOptions[_bedIndex].beds,
        search: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
      ),
    );
  }

  void _applyFilter() => setState(() => _fetch());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 72)),

                // ── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BROWSE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _listingType == ListingType.sale
                                  ? 'For Sale'
                                  : 'For Rent',
                              style: GoogleFonts.notoSerif(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                                height: 1.1,
                              ),
                            ),
                            _ListingToggle(
                              value: _listingType,
                              onChanged: (t) => setState(() {
                                _listingType = t;
                                _fetch();
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Icon(
                                Icons.search_rounded,
                                color: cs.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onSubmitted: (_) => _applyFilter(),
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search city, project or builder...',
                                    hintStyle: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _applyFilter,
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.onSurface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Search',
                                    style: GoogleFonts.inter(
                                      color: cs.surface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Sticky filters ───────────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterDelegate(
                    typeIndex: _typeIndex,
                    sortIndex: _sortIndex,
                    priceIndex: _priceIndex,
                    bedIndex: _bedIndex,
                    onTypeChanged: (i) {
                      setState(() => _typeIndex = i);
                      _fetch();
                    },
                    onSortChanged: (i) {
                      setState(() => _sortIndex = i);
                      _fetch();
                    },
                    onPriceChanged: (i) {
                      setState(() => _priceIndex = i);
                      _fetch();
                    },
                    onBedChanged: (i) {
                      setState(() => _bedIndex = i);
                      _fetch();
                    },
                  ),
                ),

                // ── Results ──────────────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _ResultsSliver(onRetry: _fetch),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
          const AppTopBar(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

// ── Listing Toggle ───────────────────────────────────────────────────────────

class _ListingToggle extends StatelessWidget {
  final ListingType value;
  final ValueChanged<ListingType> onChanged;
  const _ListingToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'Buy',
            active: value == ListingType.sale,
            onTap: () => onChanged(ListingType.sale),
            cs: cs,
          ),
          const SizedBox(width: 3),
          _ToggleBtn(
            label: 'Rent',
            active: value == ListingType.rent,
            onTap: () => onChanged(ListingType.rent),
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active ? cs.surface : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Results Sliver ────────────────────────────────────────────────────────────

class _ResultsSliver extends StatelessWidget {
  final VoidCallback onRetry;
  const _ResultsSliver({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<PropertiesProvider>();

    if (provider.listLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.listError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline_rounded, color: cs.error, size: 32),
                const SizedBox(height: 12),
                Text(
                  provider.listError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: cs.surface,
                        fontWeight: FontWeight.bold,
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

    if (provider.properties.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: cs.onSurfaceVariant,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'No properties found',
                  style: GoogleFonts.inter(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Count row
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Text(
                  '${provider.properties.length}',
                  style: GoogleFonts.notoSerif(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'properties found',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisSpacing: 28,
              crossAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PropertyCard(
                property: provider.properties[i],
                staggered: i.isOdd,
              ),
              childCount: provider.properties.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Filter Delegate ───────────────────────────────────────────────────────────

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final int typeIndex, sortIndex, priceIndex, bedIndex;
  final ValueChanged<int> onTypeChanged,
      onSortChanged,
      onPriceChanged,
      onBedChanged;

  const _FilterDelegate({
    required this.typeIndex,
    required this.sortIndex,
    required this.priceIndex,
    required this.bedIndex,
    required this.onTypeChanged,
    required this.onSortChanged,
    required this.onPriceChanged,
    required this.onBedChanged,
  });

  @override
  double get minExtent => 96;
  @override
  double get maxExtent => 96;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        children: [
          // Type chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _propTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final active = i == typeIndex;
                return GestureDetector(
                  onTap: () => onTypeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? cs.onSurface
                          : cs.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? cs.onSurface
                            : cs.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _propTypes[i].label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? cs.surface : cs.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Dropdown row
          Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: _priceRanges[priceIndex].label,
                  items: _priceRanges.map((e) => e.label).toList(),
                  selectedIndex: priceIndex,
                  onChanged: onPriceChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: _bedOptions[bedIndex].label,
                  items: _bedOptions.map((e) => e.label).toList(),
                  selectedIndex: bedIndex,
                  onChanged: onBedChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterChip(
                  label: _sortOptions[sortIndex].label,
                  items: _sortOptions.map((e) => e.label).toList(),
                  selectedIndex: sortIndex,
                  onChanged: onSortChanged,
                  icon: Icons.sort_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterDelegate old) =>
      typeIndex != old.typeIndex ||
      sortIndex != old.sortIndex ||
      priceIndex != old.priceIndex ||
      bedIndex != old.bedIndex;
}

class _FilterChip extends StatelessWidget {
  final String label;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.icon = Icons.expand_more_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _PickerSheet(items: items, selected: selectedIndex),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(icon, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final List<String> items;
  final int selected;
  const _PickerSheet({required this.items, required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            items.length,
            (i) => ListTile(
              title: Text(
                items[i],
                style: GoogleFonts.inter(
                  fontWeight: i == selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: i == selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              trailing: i == selected
                  ? Icon(Icons.check_rounded, color: cs.onSurface, size: 18)
                  : null,
              onTap: () => Navigator.pop(context, i),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Property Card ─────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final ApiProperty property;
  final bool staggered;
  const _PropertyCard({required this.property, required this.staggered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: staggered ? 40 : 0),
      child: GestureDetector(
        onTap: () => AppRouter.push(
          context,
          AppRoutes.propertyDetail,
          args: property.id,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    property.primaryImageUrl != null
                        ? Image.network(
                            property.primaryImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _Placeholder(cs: cs),
                          )
                        : _Placeholder(cs: cs),

                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.45),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Badge
                    if (property.badge != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            property.tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // Price on image
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Text(
                        property.priceLabel,
                        style: GoogleFonts.notoSerif(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Save button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            const SizedBox(height: 12),
            Text(
              property.title,
              style: GoogleFonts.notoSerif(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    property.locationString,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(
                  icon: Icons.bed_outlined,
                  label: '${property.bedrooms} BHK',
                  cs: cs,
                ),
                const SizedBox(width: 12),
                _Stat(
                  icon: Icons.straighten_outlined,
                  label: '${property.sqft.toInt()} sqft',
                  cs: cs,
                ),
                if (property.bathrooms != null) ...[
                  const SizedBox(width: 12),
                  _Stat(
                    icon: Icons.bathtub_outlined,
                    label: '${property.bathrooms} Bath',
                    cs: cs,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _Stat({required this.icon, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final ColorScheme cs;
  const _Placeholder({required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    color: cs.surfaceContainerHigh,
    child: Icon(Icons.image_outlined, color: cs.outline, size: 36),
  );
}
