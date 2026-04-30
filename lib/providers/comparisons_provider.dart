import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/services/comparisons_service.dart';

class ComparisonsProvider extends ChangeNotifier {
  final _list = ProviderState<List<ApiComparison>>();
  final _detail = ProviderMapState<String,
      ({ApiComparison comparison, ComparisonAnalysis? analysis})>();

  List<ApiComparison> get comparisons => _list.data ?? [];
  bool get loading => _list.loading;
  String? get error => _list.error;

  ApiComparison? get detail => _detail.active?.comparison;
  ComparisonAnalysis? get analysis => _detail.active?.analysis;
  bool get detailLoading => _detail.loading;
  String? get detailError => _detail.error;

  Future<void> fetchList({int? page, int? limit}) async {
    if (!_list.shouldFetch) return;
    _list.startLoading();
    notifyListeners();
    try {
      final res = await ComparisonsService.list(page: page, limit: limit);
      _list.setData(res.data);
    } catch (e) {
      _list.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateList() => _list.invalidate();

  Future<void> fetchDetail(String id) async {
    _detail.setActive(id);
    if (!_detail.shouldFetch(id)) {
      notifyListeners();
      return;
    }
    notifyListeners();
    try {
      final raw = await ComparisonsService.get(id);
      final data = raw['data'] as Map<String, dynamic>;
      final comp = ApiComparison.fromJson(data['comparison'] as Map<String, dynamic>);
      final analysis = ComparisonAnalysis.fromJson(data['analysis'] as Map<String, dynamic>);
      _detail.setData(id, (comparison: comp, analysis: analysis));
    } catch (e) {
      _detail.setError(e.toString());
    }
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
      _list.data?.insert(0, res.data);
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
      final res = await ComparisonsService.update(id,
          name: name, description: description, notes: notes,
          tags: tags, isPublic: isPublic, propertyIds: propertyIds);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((c) => c.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      _detail.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.addProperty(id, propertyId);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((c) => c.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      _detail.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeProperty(String id, String propertyId) async {
    try {
      final res = await ComparisonsService.removeProperty(id, propertyId);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((c) => c.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      _detail.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ComparisonsService.delete(id);
      _list.data?.removeWhere((c) => c.id == id);
      _detail.remove(id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
