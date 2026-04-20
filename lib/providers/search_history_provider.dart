import 'package:flutter/material.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/services/search_history_service.dart';

class SearchHistoryProvider extends ChangeNotifier {
  List<ApiSearchHistory> _history = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  List<ApiSearchHistory> get history => _history;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchList({int? page, int? limit}) async {
    if (_loaded && _error == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res =
          await SearchHistoryService.list(page: page, limit: limit);
      _history = res.data;
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> record({
    required String query,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final res =
          await SearchHistoryService.record(query: query, filters: filters);
      _history.insert(0, res.data);
      _loaded = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await SearchHistoryService.delete(id);
      _history.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteAll() async {
    try {
      await SearchHistoryService.deleteAll();
      _history.clear();
      notifyListeners();
    } catch (_) {}
  }
}
