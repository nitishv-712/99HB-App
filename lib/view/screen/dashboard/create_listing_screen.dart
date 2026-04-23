import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/config/env.dart';
import 'package:homebazaar/model/misc.dart';
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

  final _picker = ImagePicker();
  final List<({XFile file, bool isPrimary})> _images = [];

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
    super.dispose();
  }

  Future<List<_PlacePrediction>> _fetchSuggestions(String input) async {
    if (input.trim().length < 3) return [];
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:in'
      '&language=en'
      '&key=${Env.googlePlacesApiKey}',
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final predictions = (data['predictions'] as List? ?? []);
    return predictions
        .map((p) => _PlacePrediction(
              placeId: p['place_id'] as String,
              description: p['description'] as String,
            ))
        .toList();
  }

  Future<void> _fillFromPlaceId(String placeId) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=address_components'
      '&key=${Env.googlePlacesApiKey}',
    );
    final res = await http.get(uri);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final components = (data['result']?['address_components'] as List?) ?? [];

    String streetNumber = '', route = '', city = '', state = '', zip = '';
    for (final c in components) {
      final types = List<String>.from(c['types'] as List);
      final long = c['long_name'] as String;
      final short = c['short_name'] as String;
      if (types.contains('street_number')) streetNumber = long;
      if (types.contains('route')) route = long;
      if (types.contains('sublocality_level_1') && city.isEmpty) city = long;
      if (types.contains('locality')) city = long;
      if (types.contains('administrative_area_level_1')) state = long;
      if (types.contains('postal_code')) zip = short;
    }

    setState(() {
      _streetCtrl.text = [streetNumber, route].where((s) => s.isNotEmpty).join(' ');
      _cityCtrl.text = city;
      _stateCtrl.text = state;
      _zipCtrl.text = zip;
    });
  }

  Future<void> _pickImages(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;
      setState(() {
        for (final f in files) {
          _images.add((file: f, isPrimary: _images.isEmpty));
        }
      });
    } else {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      setState(() => _images.add((file: file, isPrimary: _images.isEmpty)));
    }
  }

  void _setPrimary(int idx) {
    setState(() {
      for (var i = 0; i < _images.length; i++) {
        _images[i] = (file: _images[i].file, isPrimary: i == idx);
      }
    });
  }

  void _removeImage(int idx) {
    setState(() {
      _images.removeAt(idx);
      if (_images.isNotEmpty && !_images.any((e) => e.isPrimary)) {
        _images[0] = (file: _images[0].file, isPrimary: true);
      }
    });
  }

  Future<List<Map<String, dynamic>>?> _uploadImages() async {
    final userProvider = context.read<UserProvider>();
    final uploaded = <Map<String, dynamic>>[];
    for (final img in _images) {
      final link = await userProvider.getUploadUrl(UploadFolder.properties);
      if (link == null) return null;
      final bytes = await File(img.file.path).readAsBytes();
      final mime = lookupMimeType(img.file.path) ?? 'image/jpeg';
      final ok = await userProvider.uploadFile(
        uploadUrl: Uri.parse(link.uploadUrl),
        fileBytes: bytes,
        contentType: mime,
      );
      if (!ok) return null;
      uploaded.add({'url': link.viewUrl, 'isPrimary': img.isPrimary});
    }
    return uploaded;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo')),
      );
      return;
    }

    setState(() => _loading = true);

    final uploadedImages = await _uploadImages();
    if (!mounted) return;
    if (uploadedImages == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed. Please try again.')),
      );
      return;
    }

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
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          bedrooms: int.tryParse(_bedsCtrl.text.trim()),
          bathrooms: int.tryParse(_bathsCtrl.text.trim()),
          sqft: double.tryParse(_sqftCtrl.text.trim()),
          yearBuilt: int.tryParse(_yearCtrl.text.trim()),
          badge: _badge,
          images: uploadedImages,
        );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      context.read<UserProvider>().invalidateListings();
      context.read<AnalyticsProvider>().invalidateOverview();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing submitted — pending admin approval')),
      );
      Navigator.maybePop(context);
    } else {
      final err = context.read<PropertiesProvider>().createError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Failed to create listing')),
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
                _AddressAutocompleteField(
                  onFillAddress: _fillFromPlaceId,
                  fetchSuggestions: _fetchSuggestions,
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'STREET',
                  controller: _streetCtrl,
                  hint: '14 Hill Road',
                  icon: Icons.signpost_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
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
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppInputField(
                  label: 'ZIP CODE',
                  controller: _zipCtrl,
                  hint: '400050',
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) return '6-digit ZIP';
                    return null;
                  },
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Invalid';
                          return null;
                        },
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
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = int.tryParse(v.trim());
                          final now = DateTime.now().year;
                          if (n == null || n < 1800 || n > now) return 'Invalid year';
                          return null;
                        },
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
                AppSectionLabel('PHOTOS'),
                const SizedBox(height: 12),
                _ImagePickerSection(
                  images: _images,
                  onPickGallery: () => _pickImages(ImageSource.gallery),
                  onPickCamera: () => _pickImages(ImageSource.camera),
                  onSetPrimary: _setPrimary,
                  onRemove: _removeImage,
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

// ── Address Autocomplete Field ────────────────────────────────────────────────

// ── Place prediction model ────────────────────────────────────────────────────

class _PlacePrediction {
  final String placeId;
  final String description;
  const _PlacePrediction({required this.placeId, required this.description});
}

// ── Address Autocomplete Field ────────────────────────────────────────────────

class _AddressAutocompleteField extends StatelessWidget {
  final Future<void> Function(String placeId) onFillAddress;
  final Future<List<_PlacePrediction>> Function(String input) fetchSuggestions;

  const _AddressAutocompleteField({
    required this.onFillAddress,
    required this.fetchSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEARCH TO AUTO-FILL',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<_PlacePrediction>(
          optionsBuilder: (value) async {
            if (value.text.trim().length < 3) return [];
            return fetchSuggestions(value.text);
          },
          displayStringForOption: (p) => p.description,
          onSelected: (p) => onFillAddress(p.placeId),
          fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search address to auto-fill fields below',
                hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 20, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            );
          },
          optionsViewBuilder: (ctx, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: cs.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outlineVariant.withValues(alpha: 0.3)),
                    itemBuilder: (_, i) {
                      final p = options.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: cs.onSurfaceVariant),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.description,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: cs.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
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

// ── Image Picker Section ──────────────────────────────────────────────────────

class _ImagePickerSection extends StatelessWidget {
  final List<({XFile file, bool isPrimary})> images;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final ValueChanged<int> onSetPrimary;
  final ValueChanged<int> onRemove;

  const _ImagePickerSection({
    required this.images,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onSetPrimary,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source buttons
        Row(
          children: [
            Expanded(
              child: _SourceButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onPickGallery,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: onPickCamera,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (images.isEmpty)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 28, color: cs.onSurfaceVariant),
                const SizedBox(height: 6),
                Text(
                  'No photos added yet',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          )
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (_, i) {
              final img = images[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(img.file.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (img.isPrimary)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cs.onSurface, width: 2.5),
                        ),
                      ),
                    ),
                  if (img.isPrimary)
                    Positioned(
                      bottom: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.onSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: cs.surface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => onRemove(i),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 13, color: Colors.white),
                          ),
                        ),
                        if (!img.isPrimary) ...[
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => onSetPrimary(i),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: cs.onSurface.withOpacity(0.75),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star_rounded,
                                  size: 13, color: cs.surface),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${images.length} photo${images.length == 1 ? '' : 's'} · tap ★ to set primary',
            style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
