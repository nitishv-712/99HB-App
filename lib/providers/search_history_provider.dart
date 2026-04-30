import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/services/search_history_service.dart';

class SearchHistoryProvider extends ChangeNotifier {
  final _state = ProviderState<List<ApiSearchHistory>>();

  List<ApiSearchHistory> get history => _state.data ?? [];
  bool get loading => _state.loading;
  String? get error => _state.error;

  Future<void> fetchList({int? page, int? limit}) async {
    if (!_state.shouldFetch) return;
    _state.startLoading();
    notifyListeners();
    try {
      final res = await SearchHistoryService.list(page: page, limit: limit);
      _state.setData(res.data);
    } catch (e) {
      _state.setError(e.toString());
    }
    notifyListeners();
  }

  Future<void> record({
    required String query,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final res = await SearchHistoryService.record(query: query, filters: filters);
      _state.data?.insert(0, res.data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await SearchHistoryService.delete(id);
      _state.data?.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteAll() async {
    try {
      await SearchHistoryService.deleteAll();
      _state.clear();
      notifyListeners();
    } catch (_) {}
  }
}
