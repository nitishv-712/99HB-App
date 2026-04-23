import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_filter_config.dart';

class BuyFilterDelegate extends SliverPersistentHeaderDelegate {
  final int typeIndex, sortIndex, priceIndex, bedIndex;
  final ValueChanged<int> onTypeChanged, onSortChanged, onPriceChanged, onBedChanged;
  final VoidCallback onShowAllFilters;

  const BuyFilterDelegate({
    required this.typeIndex,
    required this.sortIndex,
    required this.priceIndex,
    required this.bedIndex,
    required this.onTypeChanged,
    required this.onSortChanged,
    required this.onPriceChanged,
    required this.onBedChanged,
    required this.onShowAllFilters,
  });

  @override
  double get minExtent => 104;
  @override
  double get maxExtent => 104;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    final elevated = shrinkOffset > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: elevated
            ? [BoxShadow(color: cs.shadow.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: propTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final active = i == typeIndex;
              return GestureDetector(
                onTap: () => onTypeChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? cs.onSurface : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active ? cs.onSurface : cs.outlineVariant.withOpacity(0.4),
                      width: active ? 0 : 1,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (active) ...[
                      Icon(Icons.check_rounded, size: 11, color: cs.surface),
                      const SizedBox(width: 4),
                    ],
                    Text(propTypes[i].label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                          color: active ? cs.surface : cs.onSurfaceVariant,
                        )),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: BuyFilterChip(
            label: priceRanges[priceIndex].label, icon: Icons.currency_rupee_rounded,
            items: priceRanges.map((e) => e.label).toList(),
            selectedIndex: priceIndex, onChanged: onPriceChanged, active: priceIndex != 0,
          )),
          const SizedBox(width: 6),
          Expanded(child: BuyFilterChip(
            label: bedOptions[bedIndex].label, icon: Icons.bed_outlined,
            items: bedOptions.map((e) => e.label).toList(),
            selectedIndex: bedIndex, onChanged: onBedChanged, active: bedIndex != 0,
          )),
          const SizedBox(width: 6),
          Expanded(child: BuyFilterChip(
            label: sortOptions[sortIndex].label, icon: Icons.sort_rounded,
            items: sortOptions.map((e) => e.label).toList(),
            selectedIndex: sortIndex, onChanged: onSortChanged, active: sortIndex != 0,
          )),
          const SizedBox(width: 6),
          BuyAllFiltersButton(
            activeCount: (priceIndex != 0 ? 1 : 0) + (bedIndex != 0 ? 1 : 0) +
                (sortIndex != 0 ? 1 : 0) + (typeIndex != 0 ? 1 : 0),
            onTap: onShowAllFilters,
          ),
        ]),
      ]),
    );
  }

  @override
  bool shouldRebuild(BuyFilterDelegate old) =>
      typeIndex != old.typeIndex || sortIndex != old.sortIndex ||
      priceIndex != old.priceIndex || bedIndex != old.bedIndex ||
      onShowAllFilters != old.onShowAllFilters;
}

class BuyFilterChip extends StatelessWidget {
  final String label;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final IconData icon;
  final bool active;

  const BuyFilterChip({
    super.key,
    required this.label, required this.items, required this.selectedIndex,
    required this.onChanged, required this.icon, this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => BuyPickerSheet(items: items, selected: selectedIndex),
        );
        if (result != null) onChanged(result);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.onSurface : cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? cs.onSurface : cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 12, color: active ? cs.surface : cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: active ? cs.surface : cs.onSurface))),
          const SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, size: 13,
              color: active ? cs.surface.withOpacity(0.7) : cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

class BuyPickerSheet extends StatelessWidget {
  final List<String> items;
  final int selected;
  const BuyPickerSheet({super.key, required this.items, required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 8),
        ...List.generate(items.length, (i) => ListTile(
          title: Text(items[i], style: GoogleFonts.inter(
            fontWeight: i == selected ? FontWeight.bold : FontWeight.normal,
            color: i == selected ? cs.onSurface : cs.onSurfaceVariant,
          )),
          trailing: i == selected ? Icon(Icons.check_rounded, color: cs.onSurface, size: 18) : null,
          onTap: () => Navigator.pop(context, i),
        )),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class BuyAllFiltersButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;
  const BuyAllFiltersButton({super.key, required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasActive = activeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: hasActive ? cs.primary : cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: hasActive ? cs.primary : cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.tune_rounded, size: 13, color: hasActive ? cs.onPrimary : cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(hasActive ? 'Filters ($activeCount)' : 'Filters',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: hasActive ? cs.onPrimary : cs.onSurface)),
        ]),
      ),
    );
  }
}
