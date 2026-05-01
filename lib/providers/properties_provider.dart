import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/services/properties_service.dart';

class PropertiesProvider extends ChangeNotifier {
  final _list = ProviderState<List<ApiProperty>>();
  final _featured = ProviderState<List<ApiProperty>>();
  final _detail = ProviderMapState<String, ApiProperty>();
  PropertyFilters _filters = const PropertyFilters();
  String? _createError;

  List<ApiProperty> get properties => _list.data ?? [];
  bool get listLoading => _list.loading;
  String? get listError => _list.error;
  PropertyFilters get filters => _filters;

  List<ApiProperty> get featured => _featured.data ?? [];
  bool get featuredLoading => _featured.loading;
  String? get featuredError => _featured.error;

  ApiProperty? get detail => _detail.active;
  bool get detailLoading => _detail.loading;
  String? get detailError => _detail.error;

  String? get createError => _createError;

  final _cache = <String, List<ApiProperty>>{};

  // Helper to build a stable key from filters
  String _cacheKey(PropertyFilters f) =>
      '${f.type?.name}_${f.propType?.name}_${f.sort?.name}'
      '_${f.minPrice}_${f.maxPrice}_${f.minBeds}_${f.search}';

  Future<void> fetchList({bool force = false, PropertyFilters? filters}) async {
    final filtersChanged = filters != null && filters != _filters;
    if (filtersChanged) _filters = filters;

    final key = _cacheKey(_filters);

    if (!force && _cache.containsKey(key)) {
      _list.setData(_cache[key]!);
      notifyListeners();
      return;
    }

    _list.startLoading();
    notifyListeners();
    try {
      final res = await PropertiesService.list(_filters);
      _cache[key] = res.data; // ✅ Store in cache
      _list.setData(res.data);
    } catch (e) {
      _list.setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchFeatured() async {
    if (!_featured.shouldFetch) return;
    _featured.startLoading();
    notifyListeners();
    try {
      final res = await PropertiesService.featured();
      _featured.setData(res.data);
    } catch (e) {
      _featured.setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _detail.setActive(id);
    if (!_detail.shouldFetch(id)) {
      notifyListeners();
      return;
    }
    _detail.startLoading(id);
    notifyListeners();
    try {
      final res = await PropertiesService.get(id);
      _detail.setData(id, res.data);
    } catch (e) {
      _detail.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateDetail(String id) => _detail.remove(id);

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
    _createError = null;
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
      _list.data?.insert(0, res.data);
      _detail.setData(res.data.id, res.data);
      notifyListeners();
      return true;
    } catch (e) {
      _createError = e
          .toString()
          .replaceFirst('ApiException(', '')
          .replaceFirst(RegExp(r'\d+\): '), '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> body) async {
    try {
      final res = await PropertiesService.update(id, body);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((p) => p.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      _detail.setData(id, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await PropertiesService.delete(id);
      _list.data?.removeWhere((p) => p.id == id);
      _detail.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
