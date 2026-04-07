import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';

// ── Static data ───────────────────────────────────────────────────────────────

const _properties = [
  (
    title: 'The Obsidian Manor',
    location: 'Jubilee Hills, Hyderabad',
    price: '₹8.4 Cr',
    bhk: '4 BHK',
    sqft: '4,200 SQFT',
    badge: 'No Brokerage',
    img:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDPrWBrv8aMcdHwlec6-jqVqU-wZsKITLa0wQpIoyr_mh4eUV9P0uAEkp5ocaksrQTv_Li3Tk_gqDmNc5nGYVhVzambT7dmPAuZco8BnYd3mu543jdxwjpjWaeQbFxOHPMEZQ6g04Pu8POUP7N0YoauYKgHKSXXzATt6fEMzJjDpi_WALZRiI75d-ep52WuhplncCuAB5Mxl7IWjND5pELpqMwhk_bTkJ5AnJjEtoJqBDMvmHohY-7DuNFWf7cyRlHEE-hjPGjc',
  ),
  (
    title: 'Elysian Heights',
    location: 'Worli, Mumbai',
    price: '₹12.5 Cr',
    bhk: '3 BHK',
    sqft: '3,150 SQFT',
    badge: 'Exclusive',
    img:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBjP_waXdJXowUTI6bc-5roiHhpescM-cvpL7gWFT2LhYqohCAaLU_RxODb17BEVIRAMLcIha3g83gqvubkNlIwDaV-yBW778ekjQHLHXb9NVwrQLzZuYWAo-I_PHrPdHs45Z3ICwTorWEJfICvfcrNxGpPxH4y1MdIJgPnMvHPXkEJRiFS80Rg6zwOFVLoyuchuxrsPIU0VfOW-iuwv2fKVgfUBkJAwNXyFN4b3InsDm1TF3bCT2QKJxD0VWKj4umnmaBPC_fn',
  ),
  (
    title: 'The Heritage Estate',
    location: 'Civil Lines, Delhi',
    price: '₹22.0 Cr',
    bhk: '6 BHK',
    sqft: '8,500 SQFT',
    badge: '',
    img:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBvbOpGKq_TPrE09PzVrb2KpYo9saLDhZuSQh346P06zgYn1d64OMNqSHlhWBA4ocN25d462scDCF6Y6YEjdBkLsJlac1kS5La6HtMsBwO2qN3sDcyla-YrX8y_3cg-LErZ0y5kPW2yhCIcI_Y6AcLJG-_l4luxyHbxPMWkgswAD-4p1Qgj9WHZ_FakzswwIbq0LayJsX6tCkHG42muxsn9D6VR2Ytq4yV4F0YLqywBPO_L9JnVSk9I7JZKxQJhJgvDd-c1migz',
  ),
  (
    title: 'Skyline Sanctuary',
    location: 'Indiranagar, Bengaluru',
    price: '₹4.2 Cr',
    bhk: '2 BHK',
    sqft: '1,800 SQFT',
    badge: 'No Brokerage',
    img:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDLJVtYDUUmMsaE0W5WS7OpLqv9UH_fhq_bXd0s_mAYHUFo_tvt2flGnLTly3kZdI-Mg378kuNY4XcVFC4-9gByh4tRZVNEsaocysrcY6u1lZ5d0yCbeYFxnSV3SJukh55OwFhsvN1_lCSksJL-eH0d16iQMAK6IuitlT1yvQdtFIzucEmg1R76c7Hcpvfy0iry1vKHgwWPVMm3pden4R1O-q72d2rev4greSx3Q6yC_v6Tjofc6nfiIPOxIDrtxwn7md_sg0s_',
  ),
];

const _types = ['House', 'Apt', 'Villa', 'Land', 'Office'];
const _prices = ['Price Range', '₹50L–₹1Cr', '₹1Cr–₹5Cr', '₹5Cr+'];
const _bhks = ['BHK', '2 BHK', '3 BHK', '4+ BHK'];
const _sorts = ['Newest first', 'Price: Low to High', 'Price: High to Low'];

// ── Screen ────────────────────────────────────────────────────────────────────

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final int _navIndex = 1;
  int _typeIndex = 0;
  int _priceIndex = 0;
  int _bhkIndex = 0;
  int _sortIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    final hPad = isWide ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE COLLECTION',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: cs.primary, letterSpacing: 3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'FOR SALE',
                          style: GoogleFonts.notoSerif(
                            fontSize: isWide ? 56 : 44,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '128',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Exquisite Properties Found',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 1,
                                  color: cs.outlineVariant,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Updated Today',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sticky filters
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterHeaderDelegate(
                    typeIndex: _typeIndex,
                    priceIndex: _priceIndex,
                    bhkIndex: _bhkIndex,
                    sortIndex: _sortIndex,
                    onTypeChanged: (i) => setState(() => _typeIndex = i),
                    onPriceChanged: (i) => setState(() => _priceIndex = i),
                    onBhkChanged: (i) => setState(() => _bhkIndex = i),
                    onSortChanged: (i) => setState(() => _sortIndex = i),
                    hPad: hPad,
                  ),
                ),

                // Grid
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isWide ? 480 : 600,
                      mainAxisSpacing: isWide ? 48 : 32,
                      crossAxisSpacing: isWide ? 24 : 14,
                      childAspectRatio: isWide ? 0.62 : 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _PropertyCard(
                        property: _properties[i],
                        staggered: i.isOdd && isWide,
                      ),
                      childCount: _properties.length,
                    ),
                  ),
                ),

                // Pagination
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 56),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PaginationDot(active: true),
                            const SizedBox(width: 8),
                            _PaginationDot(active: false),
                            const SizedBox(width: 8),
                            _PaginationDot(active: false),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientCta,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'LOAD MORE PROPERTIES',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex),
    );
  }
}

// ── Filter Header ─────────────────────────────────────────────────────────────

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int typeIndex, priceIndex, bhkIndex, sortIndex;
  final ValueChanged<int> onTypeChanged,
      onPriceChanged,
      onBhkChanged,
      onSortChanged;
  final double hPad;

  const _FilterHeaderDelegate({
    required this.typeIndex,
    required this.priceIndex,
    required this.bhkIndex,
    required this.sortIndex,
    required this.onTypeChanged,
    required this.onPriceChanged,
    required this.onBhkChanged,
    required this.onSortChanged,
    required this.hPad,
  });

  @override
  double get minExtent => 100;
  @override
  double get maxExtent => 100;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
      child: Column(
        children: [
          // Type chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == typeIndex;
                return GestureDetector(
                  onTap: () => onTypeChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _types[i],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: selected ? Colors.white : cs.onSurface,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Dropdown row
          Row(
            children: [
              Expanded(
                child: _DropdownChip(
                  items: _prices,
                  selectedIndex: priceIndex,
                  onChanged: onPriceChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownChip(
                  items: _bhks,
                  selectedIndex: bhkIndex,
                  onChanged: onBhkChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownChip(
                  items: _sorts,
                  selectedIndex: sortIndex,
                  onChanged: onSortChanged,
                  suffixIcon: Icons.sort_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate old) =>
      typeIndex != old.typeIndex ||
      priceIndex != old.priceIndex ||
      bhkIndex != old.bhkIndex ||
      sortIndex != old.sortIndex;
}

class _DropdownChip extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final IconData suffixIcon;

  const _DropdownChip({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.suffixIcon = Icons.expand_more_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          builder: (_) => _PickerSheet(items: items, selected: selectedIndex),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                items[selectedIndex],
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: cs.onSurface),
              ),
            ),
            Icon(
              suffixIcon,
              size: 15,
              color: cs.onSurfaceVariant.withOpacity(0.6),
            ),
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(
          items[i],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: i == selected ? FontWeight.bold : FontWeight.normal,
            color: i == selected ? cs.primary : cs.onSurface,
          ),
        ),
        trailing: i == selected
            ? Icon(Icons.check_rounded, color: cs.primary)
            : null,
        onTap: () => Navigator.pop(context, i),
      ),
    );
  }
}

// ── Property Card ─────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final ({
    String title,
    String location,
    String price,
    String bhk,
    String sqft,
    String badge,
    String img,
  })
  property;
  final bool staggered;
  const _PropertyCard({required this.property, required this.staggered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: staggered ? 48 : 0),
      child: GestureDetector(
        onTap: () =>
            AppRouter.push(context, AppRoutes.propertyDetail, args: '1'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(property.img, fit: BoxFit.cover),
                    if (property.badge.isNotEmpty)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            property.badge,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.onTertiaryContainer,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
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
                              property.title,
                              style: GoogleFonts.notoSerif(
                                fontSize: 18,
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    property.location,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        property.price,
                        style: GoogleFonts.notoSerif(
                          fontSize: 17,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        size: 13,
                        color: cs.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.bhk,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.straighten_outlined,
                        size: 13,
                        color: cs.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.sqft,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pagination Dot ────────────────────────────────────────────────────────────

class _PaginationDot extends StatelessWidget {
  final bool active;
  const _PaginationDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active ? AppColors.primary : cs.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}
