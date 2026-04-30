import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/services/saved_service.dart';

class SavedProvider extends ChangeNotifier {
  final _state = ProviderState<List<ApiSavedProperty>>();

  List<ApiSavedProperty> get items => _state.data ?? [];
  bool get loading => _state.loading;
  String? get error => _state.error;

  bool isSaved(String propertyId) => items.any((s) {
        final id = s.property is ApiProperty
            ? (s.property as ApiProperty).id
            : s.property as String;
        return id == propertyId;
      });

  Future<void> fetchList({int? page, int? limit}) async {
    if (!_state.shouldFetch) return;
    _state.startLoading();
    notifyListeners();
    try {
      final res = await SavedService.list(page: page, limit: limit);
      _state.setData(res.data);
    } catch (e) {
      _state.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidate() => _state.invalidate();

  Future<bool> toggle(String propertyId) async {
    final wasSaved = isSaved(propertyId);
    if (wasSaved) {
      _state.setData(items.where((s) {
        final id = s.property is ApiProperty
            ? (s.property as ApiProperty).id
            : s.property as String;
        return id != propertyId;
      }).toList());
      notifyListeners();
    }
    try {
      final res = await SavedService.toggle(propertyId);
      final saved = res.data['saved'] as bool;
      if (saved) {
        _state.invalidate();
        await fetchList();
      }
      return saved;
    } catch (_) {
      if (wasSaved) {
        _state.invalidate();
        await fetchList();
      }
      return wasSaved;
    }
  }
}
