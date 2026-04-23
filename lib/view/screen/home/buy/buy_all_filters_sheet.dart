import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_filter_config.dart';

class BuyAllFiltersSheet extends StatefulWidget {
  final int typeIndex, sortIndex, priceIndex, bedIndex;
  final void Function(int type, int sort, int price, int bed) onApply;

  const BuyAllFiltersSheet({
    super.key,
    required this.typeIndex, required this.sortIndex,
    required this.priceIndex, required this.bedIndex,
    required this.onApply,
  });

  @override
  State<BuyAllFiltersSheet> createState() => _BuyAllFiltersSheetState();
}

class _BuyAllFiltersSheetState extends State<BuyAllFiltersSheet> {
  late int _type, _sort, _price, _bed;

  @override
  void initState() {
    super.initState();
    _type = widget.typeIndex;
    _sort = widget.sortIndex;
    _price = widget.priceIndex;
    _bed = widget.bedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('All Filters', style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.w900)),
                TextButton(
                  onPressed: () => setState(() { _type = 0; _sort = 0; _price = 0; _bed = 0; }),
                  child: Text('Reset', style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 16),
              _FilterSection(title: 'Property Type',
                  options: propTypes.map((e) => e.label).toList(),
                  selected: _type, onChanged: (i) => setState(() => _type = i)),
              const SizedBox(height: 16),
              _FilterSection(title: 'Price Range',
                  options: priceRanges.map((e) => e.label).toList(),
                  selected: _price, onChanged: (i) => setState(() => _price = i)),
              const SizedBox(height: 16),
              _FilterSection(title: 'Bedrooms',
                  options: bedOptions.map((e) => e.label).toList(),
                  selected: _bed, onChanged: (i) => setState(() => _bed = i)),
              const SizedBox(height: 16),
              _FilterSection(title: 'Sort By',
                  options: sortOptions.map((e) => e.label).toList(),
                  selected: _sort, onChanged: (i) => setState(() => _sort = i)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () { Navigator.pop(context); widget.onApply(_type, _sort, _price, _bed); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Apply Filters',
                        style: GoogleFonts.inter(color: cs.surface, fontWeight: FontWeight.bold, fontSize: 15))),
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

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  const _FilterSection({required this.title, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: List.generate(options.length, (i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? cs.onSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? cs.onSurface : cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Text(options[i], style: GoogleFonts.inter(
                fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? cs.surface : cs.onSurfaceVariant,
              )),
            ),
          );
        }),
      ),
    ]);
  }
}
