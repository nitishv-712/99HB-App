import 'package:flutter/material.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  // ── Overview ──────────────────────────────────────────────────────────────
  OwnerAnalytics? _overview;
  bool _overviewLoading = false;
  String? _overviewError;
  bool _overviewLoaded = false;

  OwnerAnalytics? get overview => _overview;
  bool get overviewLoading => _overviewLoading;
  String? get overviewError => _overviewError;

  // ── Per-property cache (id → analytics) ──────────────────────────────────
  final Map<String, PropertyAnalytics> _propertyCache = {};
  String? _propertyId;
  bool _propertyLoading = false;
  String? _propertyError;

  PropertyAnalytics? get propertyAnalytics =>
      _propertyId != null ? _propertyCache[_propertyId] : null;
  bool get propertyLoading => _propertyLoading;
  String? get propertyError => _propertyError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchOverview() async {
    if (_overviewLoaded && _overviewError == null) return;
    _overviewLoading = true;
    _overviewError = null;
    notifyListeners();
    try {
      final res = await AnalyticsService.overview();
      _overview = res.data;
      _overviewLoaded = true;
    } catch (e) {
      _overviewError = e.toString();
    }
    _overviewLoading = false;
    notifyListeners();
  }

  void invalidateOverview() => _overviewLoaded = false;

  Future<void> fetchPropertyAnalytics(String id) async {
    _propertyId = id;
    if (_propertyCache.containsKey(id) && _propertyError == null) {
      notifyListeners();
      return;
    }
    _propertyLoading = true;
    _propertyError = null;
    notifyListeners();
    try {
      final res = await AnalyticsService.property(id);
      _propertyCache[id] = res.data;
    } catch (e) {
      _propertyError = e.toString();
    }
    _propertyLoading = false;
    notifyListeners();
  }

  void invalidateProperty(String id) => _propertyCache.remove(id);
}
