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

  final Set<String> _toggling = {};

  bool isToggling(String propertyId) => _toggling.contains(propertyId);

  Future<bool> toggle(String propertyId) async {
    if (_toggling.contains(propertyId)) return isSaved(propertyId);
    _toggling.add(propertyId);

    final wasSaved = isSaved(propertyId);
    // Optimistic update
    if (wasSaved) {
      _items.removeWhere((s) {
        final id = s.property is ApiProperty
            ? (s.property as ApiProperty).id
            : s.property as String;
        return id == propertyId;
      });
    } else {
      _items.add(ApiSavedProperty(
        id: '_optimistic_$propertyId',
        user: '',
        property: propertyId,
        savedAt: DateTime.now().toIso8601String(),
      ));
    }
    notifyListeners();

    try {
      final res = await SavedService.toggle(propertyId);
      final saved = res.data['saved'] as bool;
      // If server disagrees with optimistic state, correct it
      if (saved != isSaved(propertyId)) {
        if (saved) {
          _items.add(ApiSavedProperty(
            id: '_optimistic_$propertyId',
            user: '',
            property: propertyId,
            savedAt: DateTime.now().toIso8601String(),
          ));
        } else {
          _items.removeWhere((s) {
            final id = s.property is ApiProperty
                ? (s.property as ApiProperty).id
                : s.property as String;
            return id == propertyId;
          });
        }
        notifyListeners();
      }
      _toggling.remove(propertyId);
      notifyListeners();
      return saved;
    } catch (_) {
      // Revert optimistic update on error
      if (wasSaved) {
        _items.add(ApiSavedProperty(
          id: '_optimistic_$propertyId',
          user: '',
          property: propertyId,
          savedAt: DateTime.now().toIso8601String(),
        ));
      } else {
        _items.removeWhere((s) {
          final id = s.property is ApiProperty
              ? (s.property as ApiProperty).id
              : s.property as String;
          return id == propertyId;
        });
      }
      _toggling.remove(propertyId);
      notifyListeners();
      return wasSaved;
    }
  }
}
