import 'package:flutter/material.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/services/saved_service.dart';

class SavedProvider extends ChangeNotifier {
  List<ApiSavedProperty> _items = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  List<ApiSavedProperty> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  bool isSaved(String propertyId) => _items.any((s) {
        final id = s.property is ApiProperty
            ? (s.property as ApiProperty).id
            : s.property as String;
        return id == propertyId;
      });

  Future<void> fetchList({int? page, int? limit}) async {
    if (_loaded && _error == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await SavedService.list(page: page, limit: limit);
      _items = res.data;
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void invalidate() => _loaded = false;

  Future<bool> toggle(String propertyId) async {
    final wasSaved = isSaved(propertyId);
    // optimistic remove for unsave
    if (wasSaved) {
      _items.removeWhere((s) {
        final id = s.property is ApiProperty
            ? (s.property as ApiProperty).id
            : s.property as String;
        return id == propertyId;
      });
      notifyListeners();
    }
    try {
      final res = await SavedService.toggle(propertyId);
      final saved = res.data['saved'] as bool;
      if (saved) {
        // fetch to get the real saved object
        _loaded = false;
        await fetchList();
      } else if (!wasSaved) {
        // was not saved and still not — nothing to do
        notifyListeners();
      }
      return saved;
    } catch (_) {
      // revert optimistic remove
      if (wasSaved) {
        _loaded = false;
        await fetchList();
      }
      return wasSaved;
    }
  }
}
