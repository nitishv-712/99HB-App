import 'package:flutter/material.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/services/properties_service.dart';

class PropertiesProvider extends ChangeNotifier {
  // ── List ──────────────────────────────────────────────────────────────────
  List<ApiProperty> _properties = [];
  bool _listLoading = false;
  String? _listError;
  bool _listLoaded = false;
  PropertyFilters _filters = const PropertyFilters();

  List<ApiProperty> get properties => _properties;
  bool get listLoading => _listLoading;
  String? get listError => _listError;
  PropertyFilters get filters => _filters;

  // ── Featured ──────────────────────────────────────────────────────────────
  List<ApiProperty> _featured = [];
  bool _featuredLoading = false;
  String? _featuredError;
  bool _featuredLoaded = false;

  List<ApiProperty> get featured => _featured;
  bool get featuredLoading => _featuredLoading;
  String? get featuredError => _featuredError;

  // ── Detail cache (id → property) ─────────────────────────────────────────
  final Map<String, ApiProperty> _detailCache = {};
  String? _detailId;
  bool _detailLoading = false;
  String? _detailError;

  ApiProperty? get detail => _detailId != null ? _detailCache[_detailId] : null;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Fetches list only if filters changed or not yet loaded.
  Future<void> fetchList([PropertyFilters? filters]) async {
    final filtersChanged = filters != null && filters != _filters;
    if (_listLoaded && !filtersChanged && _listError == null) return;
    if (filters != null) _filters = filters;
    _listLoading = true;
    _listError = null;
    notifyListeners();
    try {
      final res = await PropertiesService.list(_filters);
      _properties = res.data;
      _listLoaded = true;
    } catch (e) {
      _listError = e.toString();
    }
    _listLoading = false;
    notifyListeners();
  }

  /// Force re-fetch regardless of cache (used when filters change).
  Future<void> fetchListForced([PropertyFilters? filters]) async {
    if (filters != null) _filters = filters;
    _listLoaded = false;
    await fetchList();
  }

  void updateFilters(PropertyFilters filters) => fetchListForced(filters);

  Future<void> fetchFeatured() async {
    if (_featuredLoaded && _featuredError == null) return;
    _featuredLoading = true;
    _featuredError = null;
    notifyListeners();
    try {
      final res = await PropertiesService.featured();
      _featured = res.data;
      _featuredLoaded = true;
    } catch (e) {
      _featuredError = e.toString();
    }
    _featuredLoading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _detailId = id;
    if (_detailCache.containsKey(id) && _detailError == null) {
      notifyListeners();
      return;
    }
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await PropertiesService.get(id);
      _detailCache[id] = res.data;
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
    notifyListeners();
  }

  void invalidateDetail(String id) => _detailCache.remove(id);

  Future<bool> create({
    required String title,
    required ListingType listingType,
    required PropertyType propertyType,
    required double price,
    required Map<String, dynamic> address,
    String? description,
    int? bedrooms,
    int? bathrooms,
    double? sqft,
    int? yearBuilt,
    PropertyBadge? badge,
    bool? isFeatured,
    required List<Map<String, dynamic>> images,
  }) async {
    try {
      final res = await PropertiesService.create(
        title: title,
        listingType: listingType,
        propertyType: propertyType,
        price: price,
        address: address,
        description: description,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        sqft: sqft,
        yearBuilt: yearBuilt,
        badge: badge,
        isFeatured: isFeatured,
        images: images,
      );
      _properties.insert(0, res.data);
      _detailCache[res.data.id] = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> body) async {
    try {
      final res = await PropertiesService.update(id, body);
      final idx = _properties.indexWhere((p) => p.id == id);
      if (idx != -1) _properties[idx] = res.data;
      _detailCache[id] = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await PropertiesService.delete(id);
      _properties.removeWhere((p) => p.id == id);
      _detailCache.remove(id);
      if (_detailId == id) _detailId = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
