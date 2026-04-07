import 'package:flutter/material.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/services/properties_service.dart';

class PropertiesProvider extends ChangeNotifier {
  // ── List ──────────────────────────────────────────────────────────────────
  List<ApiProperty> _properties = [];
  bool _listLoading = false;
  String? _listError;
  PropertyFilters _filters = const PropertyFilters();

  List<ApiProperty> get properties => _properties;
  bool get listLoading => _listLoading;
  String? get listError => _listError;
  PropertyFilters get filters => _filters;

  // ── Featured ──────────────────────────────────────────────────────────────
  List<ApiProperty> _featured = [];
  bool _featuredLoading = false;
  String? _featuredError;

  List<ApiProperty> get featured => _featured;
  bool get featuredLoading => _featuredLoading;
  String? get featuredError => _featuredError;

  // ── Detail ────────────────────────────────────────────────────────────────
  ApiProperty? _detail;
  bool _detailLoading = false;
  String? _detailError;

  ApiProperty? get detail => _detail;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchList([PropertyFilters? filters]) async {
    if (filters != null) _filters = filters;
    _listLoading = true;
    _listError = null;
    notifyListeners();
    try {
      final res = await PropertiesService.list(_filters);
      _properties = res.data;
    } catch (e) {
      _listError = e.toString();
    }
    _listLoading = false;
    notifyListeners();
  }

  void updateFilters(PropertyFilters filters) {
    _filters = filters;
    fetchList();
  }

  Future<void> fetchFeatured() async {
    _featuredLoading = true;
    _featuredError = null;
    notifyListeners();
    try {
      final res = await PropertiesService.featured();
      _featured = res.data;
    } catch (e) {
      _featuredError = e.toString();
    }
    _featuredLoading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _detailLoading = true;
    _detailError = null;
    _detail = null;
    notifyListeners();
    try {
      final res = await PropertiesService.get(id);
      _detail = res.data;
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
    notifyListeners();
  }

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
      if (_detail?.id == id) _detail = res.data;
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
      if (_detail?.id == id) _detail = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
