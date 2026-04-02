import 'package:flutter/material.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/services/comparisons_service.dart';

class ComparisonsProvider extends ChangeNotifier {
  List<ApiComparison> _comparisons = [];
  bool _loading = false;
  String? _error;

  ApiComparison? _detail;
  ComparisonAnalysis? _analysis;
  bool _detailLoading = false;
  String? _detailError;

  List<ApiComparison> get comparisons => _comparisons;
  bool get loading => _loading;
  String? get error => _error;

  ApiComparison? get detail => _detail;
  ComparisonAnalysis? get analysis => _analysis;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> fetchList({int? page, int? limit}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ComparisonsService.list(page: page, limit: limit);
      _comparisons = res.data;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final raw = await ComparisonsService.get(id);
      final data = raw['data'] as Map<String, dynamic>;
      _detail = ApiComparison.fromJson(data['comparison'] as Map<String, dynamic>);
      _analysis = ComparisonAnalysis.fromJson(data['analysis'] as Map<String, dynamic>);
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
        name: name, propertyIds: propertyIds,
        description: description, notes: notes, tags: tags,
      );
      _comparisons.insert(0, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, {
    String? name, String? description, String? notes,
    List<String>? tags, bool? isPublic, List<String>? propertyIds,
  }) async {
    try {
      final res = await ComparisonsService.update(
        id, name: name, description: description, notes: notes,
        tags: tags, isPublic: isPublic, propertyIds: propertyIds,
      );
      final idx = _comparisons.indexWhere((c) => c.id == id);
      if (idx != -1) _comparisons[idx] = res.data;
      if (_detail?.id == id) _detail = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.addProperty(id, propertyId);
      if (_detail?.id == id) _detail = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.removeProperty(id, propertyId);
      if (_detail?.id == id) _detail = res.data;
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
      if (_detail?.id == id) _detail = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
