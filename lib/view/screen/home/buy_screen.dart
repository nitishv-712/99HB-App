import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'buy/buy_filter_config.dart';
import 'buy/buy_listing_toggle.dart';
import 'buy/buy_filter_bar.dart';
import 'buy/buy_all_filters_sheet.dart';
import 'buy/buy_results_sliver.dart';

class BuyScreen extends StatefulWidget {
  final ListingType initialListingType;
  const BuyScreen({super.key, this.initialListingType = ListingType.sale});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int _typeIndex = 0;
  int _sortIndex = 0;
  int _priceIndex = 0;
  int _bedIndex = 0;
  late ListingType _listingType;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listingType = widget.initialListingType;
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
        propType: propTypes[_typeIndex].type,
        sort: sortOptions[_sortIndex].sort,
        minPrice: priceRanges[_priceIndex].min,
        maxPrice: priceRanges[_priceIndex].max,
        minBeds: bedOptions[_bedIndex].beds,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      ),
    );
  }

  void _applyFilter() => setState(() => _fetch());

  void _showAllFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BuyAllFiltersSheet(
        typeIndex: _typeIndex,
        sortIndex: _sortIndex,
        priceIndex: _priceIndex,
        bedIndex: _bedIndex,
        onApply: (t, s, p, b) {
          setState(() { _typeIndex = t; _sortIndex = s; _priceIndex = p; _bedIndex = b; });
          _fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: BrandAppBar(),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BROWSE', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  letterSpacing: 2.5, color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _listingType == ListingType.sale ? 'For Sale' : 'For Rent',
                    style: GoogleFonts.notoSerif(fontSize: 36, fontWeight: FontWeight.w900,
                        color: cs.onSurface, height: 1.1),
                  ),
                  BuyListingToggle(
                    value: _listingType,
                    onChanged: (t) => setState(() { _listingType = t; _fetch(); }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: (_) => _applyFilter(),
                      style: TextStyle(color: cs.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search city, project or builder...',
                        hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                        border: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _applyFilter,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(10)),
                      child: Text('Search', style: GoogleFonts.inter(
                          color: cs.surface, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: BuyFilterDelegate(
            typeIndex: _typeIndex,
            sortIndex: _sortIndex,
            priceIndex: _priceIndex,
            bedIndex: _bedIndex,
            onTypeChanged: (i) { setState(() => _typeIndex = i); _fetch(); },
            onSortChanged: (i) { setState(() => _sortIndex = i); _fetch(); },
            onPriceChanged: (i) { setState(() => _priceIndex = i); _fetch(); },
            onBedChanged: (i) { setState(() => _bedIndex = i); _fetch(); },
            onShowAllFilters: _showAllFilters,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        BuyResultsSliver(onRetry: _fetch),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }
}
