import 'package:flutter/material.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/services/comparisons_service.dart';

class ComparisonsProvider extends ChangeNotifier {
  List<ApiComparison> _comparisons = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // ── Detail cache (id → {comparison, analysis}) ───────────────────────────
  final Map<String, ({ApiComparison comparison, ComparisonAnalysis? analysis})>
  _detailCache = {};
  String? _detailId;
  bool _detailLoading = false;
  String? _detailError;

  List<ApiComparison> get comparisons => _comparisons;
  bool get loading => _loading;
  String? get error => _error;

  ApiComparison? get detail =>
      _detailId != null ? _detailCache[_detailId]?.comparison : null;
  ComparisonAnalysis? get analysis =>
      _detailId != null ? _detailCache[_detailId]?.analysis : null;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> fetchList({int? page, int? limit}) async {
    if (_loaded && _error == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ComparisonsService.list(page: page, limit: limit);
      _comparisons = res.data;
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void invalidateList() => _loaded = false;

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
      final raw = await ComparisonsService.get(id);
      final data = raw['data'] as Map<String, dynamic>;
      final comp = ApiComparison.fromJson(
        data['comparison'] as Map<String, dynamic>,
      );
      final analysis = ComparisonAnalysis.fromJson(
        data['analysis'] as Map<String, dynamic>,
      );
      _detailCache[id] = (comparison: comp, analysis: analysis);
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
    notifyListeners();
  }

  Future<bool> create({
    required String name,
    required List<String> propertyIds,
    String? description,
    String? notes,
    List<String>? tags,
  }) async {
    try {
      final res = await ComparisonsService.create(
        name: name,
        propertyIds: propertyIds,
        description: description,
        notes: notes,
        tags: tags,
      );
      _comparisons.insert(0, res.data);
      _loaded = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(
    String id, {
    String? name,
    String? description,
    String? notes,
    List<String>? tags,
    bool? isPublic,
    List<String>? propertyIds,
  }) async {
    try {
      final res = await ComparisonsService.update(
        id,
        name: name,
        description: description,
        notes: notes,
        tags: tags,
        isPublic: isPublic,
        propertyIds: propertyIds,
      );
      final idx = _comparisons.indexWhere((c) => c.id == id);
      if (idx != -1) _comparisons[idx] = res.data;
      _detailCache.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.addProperty(id, propertyId);
      final idx = _comparisons.indexWhere((c) => c.id == id);
      if (idx != -1) _comparisons[idx] = res.data;
      _detailCache.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.removeProperty(id, propertyId);
      final idx = _comparisons.indexWhere((c) => c.id == id);
      if (idx != -1) _comparisons[idx] = res.data;
      _detailCache.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ComparisonsService.delete(id);
      _comparisons.removeWhere((c) => c.id == id);
      _detailCache.remove(id);
      if (_detailId == id) _detailId = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
