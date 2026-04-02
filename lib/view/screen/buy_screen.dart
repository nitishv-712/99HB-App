import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

const _properties = [
  (
    title: 'The Obsidian Manor',
    location: 'Jubilee Hills, Hyderabad',
    price: '₹8.4 Cr',
    bhk: '4 BHK',
    sqft: '4,200 SQFT',
    badge: 'No Brokerage',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDPrWBrv8aMcdHwlec6-jqVqU-wZsKITLa0wQpIoyr_mh4eUV9P0uAEkp5ocaksrQTv_Li3Tk_gqDmNc5nGYVhVzambT7dmPAuZco8BnYd3mu543jdxwjpjWaeQbFxOHPMEZQ6g04Pu8POUP7N0YoauYKgHKSXXzATt6fEMzJjDpi_WALZRiI75d-ep52WuhplncCuAB5Mxl7IWjND5pELpqMwhk_bTkJ5AnJjEtoJqBDMvmHohY-7DuNFWf7cyRlHEE-hjPGjc',
  ),
  (
    title: 'Elysian Heights',
    location: 'Worli, Mumbai',
    price: '₹12.5 Cr',
    bhk: '3 BHK',
    sqft: '3,150 SQFT',
    badge: 'Exclusive',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBjP_waXdJXowUTI6bc-5roiHhpescM-cvpL7gWFT2LhYqohCAaLU_RxODb17BEVIRAMLcIha3g83gqvubkNlIwDaV-yBW778ekjQHLHXb9NVwrQLzZuYWAo-I_PHrPdHs45Z3ICwTorWEJfICvfcrNxGpPxH4y1MdIJgPnMvHPXkEJRiFS80Rg6zwOFVLoyuchuxrsPIU0VfOW-iuwv2fKVgfUBkJAwNXyFN4b3InsDm1TF3bCT2QKJxD0VWKj4umnmaBPC_fn',
  ),
  (
    title: 'The Heritage Estate',
    location: 'Civil Lines, Delhi',
    price: '₹22.0 Cr',
    bhk: '6 BHK',
    sqft: '8,500 SQFT',
    badge: '',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvbOpGKq_TPrE09PzVrb2KpYo9saLDhZuSQh346P06zgYn1d64OMNqSHlhWBA4ocN25d462scDCF6Y6YEjdBkLsJlac1kS5La6HtMsBwO2qN3sDcyla-YrX8y_3cg-LErZ0y5kPW2yhCIcI_Y6AcLJG-_l4luxyHbxPMWkgswAD-4p1Qgj9WHZ_FakzswwIbq0LayJsX6tCkHG42muxsn9D6VR2Ytq4yV4F0YLqywBPO_L9JnVSk9I7JZKxQJhJgvDd-c1migz',
  ),
  (
    title: 'Skyline Sanctuary',
    location: 'Indiranagar, Bengaluru',
    price: '₹4.2 Cr',
    bhk: '2 BHK',
    sqft: '1,800 SQFT',
    badge: 'No Brokerage',
    img: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDLJVtYDUUmMsaE0W5WS7OpLqv9UH_fhq_bXd0s_mAYHUFo_tvt2flGnLTly3kZdI-Mg378kuNY4XcVFC4-9gByh4tRZVNEsaocysrcY6u1lZ5d0yCbeYFxnSV3SJukh55OwFhsvN1_lCSksJL-eH0d16iQMAK6IuitlT1yvQdtFIzucEmg1R76c7Hcpvfy0iry1vKHgwWPVMm3pden4R1O-q72d2rev4greSx3Q6yC_v6Tjofc6nfiIPOxIDrtxwn7md_sg0s_',
  ),
];

const _types = ['House', 'Apt', 'Villa', 'Land', 'Office'];
const _prices = ['Price Range', '₹50L - ₹1Cr', '₹1Cr - ₹5Cr', '₹5Cr +'];
const _bhks = ['BHK', '2 BHK', '3 BHK', '4+ BHK'];
const _sorts = ['Newest first', 'Price: Low to High', 'Price: High to Low'];

// ── Screen ────────────────────────────────────────────────────────────────────

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int _navIndex = 1;
  int _typeIndex = 0;
  int _priceIndex = 0;
  int _bhkIndex = 0;
  int _sortIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 768;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: const SizedBox(height: 72)),

                // Editorial header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 16, isWide ? 32 : 24, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('The Collection',
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.bold,
                          letterSpacing: 3, color: cs.primary,
                        )),
                      const SizedBox(height: 4),
                      Text('FOR SALE',
                        style: GoogleFonts.notoSerif(
                          fontSize: isWide ? 56 : 48, fontWeight: FontWeight.w900,
                          color: cs.onSurface, height: 1.1,
                        )),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('128', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: cs.onSurface)),
                              const SizedBox(width: 8),
                              Text('Exquisite Properties Found',
                                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant.withOpacity(0.6))),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 32, height: 1, color: cs.outlineVariant.withOpacity(0.4)),
                              const SizedBox(width: 12),
                              Text('Updated Today',
                                style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.6),
                                  fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ]),
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
                    isWide: isWide,
                  ),
                ),

                // Property grid
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 24, isWide ? 32 : 24, 0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isWide ? 480 : 600,
                      mainAxisSpacing: isWide ? 48 : 32,
                      crossAxisSpacing: isWide ? 24 : 16,
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
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _PaginationDot(active: true),
                        const SizedBox(width: 8),
                        _PaginationDot(active: false),
                        const SizedBox(width: 8),
                        _PaginationDot(active: false),
                      ]),
                      const SizedBox(height: 28),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientCta,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () {},
                          child: Text('EXPLORE MORE PROPERTIES',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, fontSize: 13)),
                        ),
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            // Top app bar
            _TopAppBar(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex),
    );
  }
}

// ── Top App Bar ───────────────────────────────────────────────────────────────

class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        color: cs.surface.withOpacity(0.85),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainer,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAqND4MKe0PuWID3qoVe8psX4gqOORxoOHnCyoAL-eJ-IeFES6bEMg3D10ZV2qadPoSOvWIVAmQqexsZi9Y2Q4Kvx4jPV2b65EYCLlWrqYSaf7aigORPUotLS05JkMYThbb9fIo5PPl4mjqW0i0ht2xQ5TC8opgDICt-VSyJIkjWdk5J8XYx7laFiNwDWVJ7nMoSkPNbDiqOK7ct8rAKIuajJWJHvF80rQ4ExcKzltElnE6D9R_6vAE_6eDIITIFemroTQAMpXQ',
                  ),
                ),
                const SizedBox(width: 12),
                Text('The Curated Estate',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5,
                  )),
              ]),
              Icon(Icons.search, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sticky Filter Header ──────────────────────────────────────────────────────

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int typeIndex, priceIndex, bhkIndex, sortIndex;
  final ValueChanged<int> onTypeChanged, onPriceChanged, onBhkChanged, onSortChanged;
  final bool isWide;

  const _FilterHeaderDelegate({
    required this.typeIndex, required this.priceIndex,
    required this.bhkIndex, required this.sortIndex,
    required this.onTypeChanged, required this.onPriceChanged,
    required this.onBhkChanged, required this.onSortChanged,
    required this.isWide,
  });

  @override
  double get minExtent => 120;
  @override
  double get maxExtent => 120;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface.withOpacity(0.97),
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 24, 8, isWide ? 32 : 24, 12),
      child: Column(children: [
        // Type chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final active = i == typeIndex;
              return GestureDetector(
                onTap: () => onTypeChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? cs.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: active ? [BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))] : null,
                  ),
                  child: Text(_types[i],
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: active ? cs.onPrimary : cs.onSurfaceVariant,
                    )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dropdowns
        Row(children: [
          Expanded(child: _DropdownChip(
            items: _prices, selectedIndex: priceIndex,
            onChanged: onPriceChanged, suffixIcon: Icons.expand_more,
          )),
          const SizedBox(width: 12),
          Expanded(child: _DropdownChip(
            items: _bhks, selectedIndex: bhkIndex,
            onChanged: onBhkChanged, suffixIcon: Icons.expand_more,
          )),
          const SizedBox(width: 12),
          Expanded(child: _DropdownChip(
            items: _sorts, selectedIndex: sortIndex,
            onChanged: onSortChanged, suffixIcon: Icons.sort,
          )),
        ]),
      ]),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate old) =>
      typeIndex != old.typeIndex || priceIndex != old.priceIndex ||
      bhkIndex != old.bhkIndex || sortIndex != old.sortIndex;
}

class _DropdownChip extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final IconData suffixIcon;

  const _DropdownChip({
    required this.items, required this.selectedIndex,
    required this.onChanged, required this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          builder: (_) => _PickerSheet(items: items, selected: selectedIndex),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(
            child: Text(items[selectedIndex],
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface)),
          ),
          Icon(suffixIcon, size: 16, color: cs.onSurfaceVariant.withOpacity(0.5)),
        ]),
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
        title: Text(items[i], style: GoogleFonts.inter(
          fontWeight: i == selected ? FontWeight.bold : FontWeight.normal,
          color: i == selected ? cs.primary : cs.onSurface,
        )),
        trailing: i == selected ? Icon(Icons.check, color: cs.primary) : null,
        onTap: () => Navigator.pop(context, i),
      ),
    );
  }
}

// ── Property Card ─────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final ({String title, String location, String price, String bhk, String sqft, String badge, String img}) property;
  final bool staggered;
  const _PropertyCard({required this.property, required this.staggered});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: staggered ? 48 : 0),
      child: GestureDetector(
        onTap: () => AppRouter.push(context, AppRoutes.propertyDetail, args: '1'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(property.img, fit: BoxFit.cover),
                if (property.badge.isNotEmpty)
                  Positioned(
                    top: 14, left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(property.badge,
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
                          color: AppColors.onTertiaryContainer, letterSpacing: 1.5)),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(property.title,
                      style: GoogleFonts.notoSerif(fontSize: 20, color: cs.onSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Flexible(child: Text(property.location,
                        style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant))),
                    ]),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(property.price,
                  style: GoogleFonts.notoSerif(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.bed_outlined, size: 14, color: cs.onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(property.bhk,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant.withOpacity(0.6), letterSpacing: 1)),
                const SizedBox(width: 20),
                Icon(Icons.straighten_outlined, size: 14, color: cs.onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(property.sqft,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant.withOpacity(0.6), letterSpacing: 1)),
              ]),
            ]),
          ),
        ]),
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
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.4),
      ),
    );
  }
}

