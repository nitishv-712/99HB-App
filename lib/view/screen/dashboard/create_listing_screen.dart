import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/app_loader.dart';
import 'package:homebazaar/view/components/app_shared.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _bedsCtrl = TextEditingController();
  final _bathsCtrl = TextEditingController();
  final _sqftCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  ListingType _listingType = ListingType.sale;
  PropertyType _propertyType = PropertyType.apartment;
  PropertyBadge? _badge;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _bedsCtrl.dispose();
    _bathsCtrl.dispose();
    _sqftCtrl.dispose();
    _yearCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one image URL is required')),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await context.read<PropertiesProvider>().create(
          title: _titleCtrl.text.trim(),
          listingType: _listingType,
          propertyType: _propertyType,
          price: double.parse(_priceCtrl.text.trim()),
          address: {
            'street': _streetCtrl.text.trim(),
            'city': _cityCtrl.text.trim(),
            'state': _stateCtrl.text.trim(),
            'zip': _zipCtrl.text.trim(),
          },
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          bedrooms: _bedsCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_bedsCtrl.text.trim()),
          bathrooms: _bathsCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_bathsCtrl.text.trim()),
          sqft: _sqftCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_sqftCtrl.text.trim()),
          yearBuilt: _yearCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_yearCtrl.text.trim()),
          badge: _badge,
          images: [
            {'url': _imageUrlCtrl.text.trim(), 'isPrimary': true},
          ],
        );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      // Invalidate my-listings and analytics so they re-fetch
      context.read<UserProvider>().invalidateListings();
      context.read<AnalyticsProvider>().invalidateOverview();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Listing submitted — pending admin approval')),
      );
      Navigator.maybePop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create listing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppStandardBar(title: 'New Listing'),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // ── Listing type toggle ──────────────────────────────────
                AppSectionLabel('LISTING TYPE'),
                const SizedBox(height: 12),
                _ToggleRow<ListingType>(
                  options: const [
                    (label: 'For Sale', value: ListingType.sale),
                    (label: 'For Rent', value: ListingType.rent),
                  ],
                  selected: _listingType,
                  onChanged: (v) => setState(() => _listingType = v),
                ),

                const SizedBox(height: 24),
                AppSectionLabel('PROPERTY TYPE'),
                const SizedBox(height: 12),
                _PropertyTypeGrid(
                  selected: _propertyType,
                  onChanged: (v) => setState(() => _propertyType = v),
                ),

                const SizedBox(height: 24),
                AppSectionLabel('BASIC INFO'),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'TITLE',
                  controller: _titleCtrl,
                  hint: '3BHK Apartment in Bandra',
                  icon: Icons.title_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _TextAreaField(
                  label: 'DESCRIPTION',
                  controller: _descCtrl,
                  hint: 'Describe the property...',
                ),
                const SizedBox(height: 16),
                AppInputField(
                  label: 'PRICE (₹)',
                  controller: _priceCtrl,
                  hint: '9500000',
                  icon: Icons.currency_rupee_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                AppSectionLabel('ADDRESS'),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'STREET',
                  controller: _streetCtrl,
                  hint: '14 Hill Road',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: 'CITY',
                        controller: _cityCtrl,
                        hint: 'Mumbai',
                        icon: Icons.location_city_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputField(
                        label: 'STATE',
                        controller: _stateCtrl,
                        hint: 'Maharashtra',
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInputField(
                  label: 'ZIP CODE',
                  controller: _zipCtrl,
                  hint: '400050',
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),
                AppSectionLabel('DETAILS'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: 'BEDROOMS',
                        controller: _bedsCtrl,
                        hint: '3',
                        icon: Icons.bed_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputField(
                        label: 'BATHROOMS',
                        controller: _bathsCtrl,
                        hint: '2',
                        icon: Icons.bathtub_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: 'AREA (SQFT)',
                        controller: _sqftCtrl,
                        hint: '1200',
                        icon: Icons.square_foot_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputField(
                        label: 'YEAR BUILT',
                        controller: _yearCtrl,
                        hint: '2018',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                AppSectionLabel('BADGE (OPTIONAL)'),
                const SizedBox(height: 12),
                _BadgePicker(
                  selected: _badge,
                  onChanged: (v) => setState(() => _badge = v),
                ),

                const SizedBox(height: 24),
                AppSectionLabel('PRIMARY IMAGE'),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'IMAGE URL',
                  controller: _imageUrlCtrl,
                  hint: 'https://...',
                  icon: Icons.image_outlined,
                  keyboardType: TextInputType.url,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 32),
                AppPrimaryButton(
                  text: 'SUBMIT LISTING',
                  onPressed: _loading ? () {} : _submit,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your listing will be reviewed by an admin before going live.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (_loading) const AppLoader(),
        ],
      ),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow<T> extends StatelessWidget {
  final List<({String label, T value})> options;
  final T selected;
  final ValueChanged<T> onChanged;
  const _ToggleRow(
      {required this.options,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: options.map((o) {
          final active = o.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? cs.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  o.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? cs.surface : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Property Type Grid ────────────────────────────────────────────────────────

class _PropertyTypeGrid extends StatelessWidget {
  final PropertyType selected;
  final ValueChanged<PropertyType> onChanged;
  const _PropertyTypeGrid(
      {required this.selected, required this.onChanged});

  static const _types = [
    (label: 'Apartment', icon: Icons.apartment_outlined, value: PropertyType.apartment),
    (label: 'House', icon: Icons.house_outlined, value: PropertyType.house),
    (label: 'Villa', icon: Icons.villa_outlined, value: PropertyType.villa),
    (label: 'Penthouse', icon: Icons.roofing_outlined, value: PropertyType.penthouse),
    (label: 'Townhouse', icon: Icons.home_work_outlined, value: PropertyType.townhouse),
    (label: 'Land', icon: Icons.landscape_outlined, value: PropertyType.land),
    (label: 'Office', icon: Icons.business_outlined, value: PropertyType.office),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _types.map((t) {
        final active = t.value == selected;
        return GestureDetector(
          onTap: () => onChanged(t.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? cs.onSurface
                  : cs.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? cs.onSurface
                    : cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.icon,
                    size: 16,
                    color: active ? cs.surface : cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  t.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? cs.surface : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Badge Picker ──────────────────────────────────────────────────────────────

class _BadgePicker extends StatelessWidget {
  final PropertyBadge? selected;
  final ValueChanged<PropertyBadge?> onChanged;
  const _BadgePicker({required this.selected, required this.onChanged});

  static const _badges = [
    (label: 'None', value: null),
    (label: 'New', value: PropertyBadge.newBadge),
    (label: 'Premium', value: PropertyBadge.premium),
    (label: 'Featured', value: PropertyBadge.featured),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: _badges.map((b) {
        final active = b.value == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: b.value != PropertyBadge.featured ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(b.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? cs.onSurface
                      : cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active
                        ? cs.onSurface
                        : cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  b.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? cs.surface : cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Text Area Field ───────────────────────────────────────────────────────────

class _TextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  const _TextAreaField(
      {required this.label,
      required this.controller,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}
