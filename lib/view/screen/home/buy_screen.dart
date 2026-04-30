import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'buy/buy_filter_config.dart';
import 'buy/buy_listing_toggle.dart';
import 'buy/buy_all_filters_sheet.dart';
import 'buy/buy_results_grid.dart';

class BuyScreen extends StatefulWidget {
  final ListingType initialListingType;
  const BuyScreen({super.key, this.initialListingType = ListingType.sale});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

  int get _activeFilterCount =>
      (_typeIndex != 0 ? 1 : 0) +
      (_sortIndex != 0 ? 1 : 0) +
      (_priceIndex != 0 ? 1 : 0) +
      (_bedIndex != 0 ? 1 : 0);

  void _fetch() {
    context.read<PropertiesProvider>().fetchList(
      PropertyFilters(
        type: _listingType,
        propType: propTypes[_typeIndex].type,
        sort: sortOptions[_sortIndex].sort,
        minPrice: priceRanges[_priceIndex].min,
        maxPrice: priceRanges[_priceIndex].max,
        minBeds: bedOptions[_bedIndex].beds,
        search: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
      ),
    );
  }

  void _showAllFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BuyAllFiltersSheet(
        typeIndex: _typeIndex,
        sortIndex: _sortIndex,
        priceIndex: _priceIndex,
        bedIndex: _bedIndex,
        onApply: (t, s, p, b) {
          setState(() {
            _typeIndex = t;
            _sortIndex = s;
            _priceIndex = p;
            _bedIndex = b;
          });
          _fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final hasFilters = _activeFilterCount > 0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: BrandAppBar(
        searchBar: Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search_rounded,
                      color: cs.onSurfaceVariant,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => setState(() => _fetch()),
                        style: TextStyle(color: cs.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search city, project...',
                          hintStyle: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showAllFilters,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: hasFilters
                      ? cs.onSurface
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasFilters
                        ? cs.onSurface
                        : cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: hasFilters ? cs.surface : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      hasFilters ? 'Filters ($_activeFilterCount)' : 'Filters',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasFilters ? cs.surface : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _listingType == ListingType.sale ? 'For Sale' : 'For Rent',
                  style: GoogleFonts.notoSerif(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    height: 1.1,
                  ),
                ),
                BuyListingToggle(
                  value: _listingType,
                  onChanged: (t) => setState(() {
                    _listingType = t;
                    _fetch();
                  }),
                ),
              ],
            ),
          ),
          Expanded(child: BuyResultsGrid(onRetry: _fetch)),
        ],
      ),
    );
  }
}
