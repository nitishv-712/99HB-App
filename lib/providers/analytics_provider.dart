import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _overview = ProviderState<OwnerAnalytics>();
  final _property = ProviderMapState<String, PropertyAnalytics>();

  OwnerAnalytics? get overview => _overview.data;
  bool get overviewLoading => _overview.loading;
  String? get overviewError => _overview.error;

  PropertyAnalytics? get propertyAnalytics => _property.active;
  bool get propertyLoading => _property.loading;
  String? get propertyError => _property.error;

  Future<void> fetchOverview() async {
    if (!_overview.shouldFetch) return;
    _overview.startLoading();
    notifyListeners();
    try {
      final res = await AnalyticsService.overview();
      _overview.setData(res.data);
    } catch (e) {
      _overview.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateOverview() => _overview.invalidate();
  void invalidateProperty(String id) => _property.remove(id);

  Future<void> fetchPropertyAnalytics(String id) async {
    _property.setActive(id);
    if (!_property.shouldFetch(id)) {
      notifyListeners();
      return;
    }
    notifyListeners();
    try {
      final res = await AnalyticsService.property(id);
      _property.setData(id, res.data);
    } catch (e) {
      _property.setError(e.toString());
    }
    notifyListeners();
  }
}
