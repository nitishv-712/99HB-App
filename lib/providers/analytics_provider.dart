import 'package:flutter/material.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  OwnerAnalytics? _overview;
  bool _overviewLoading = false;
  String? _overviewError;
  PropertyAnalytics? _propertyAnalytics;
  bool _propertyLoading = false;
  String? _propertyError;

  OwnerAnalytics? get overview => _overview;
  bool get overviewLoading => _overviewLoading;
  String? get overviewError => _overviewError;
  PropertyAnalytics? get propertyAnalytics => _propertyAnalytics;
  bool get propertyLoading => _propertyLoading;
  String? get propertyError => _propertyError;

  Future<void> fetchOverview() async {
    _overviewLoading = true;
    _overviewError = null;
    notifyListeners();
    try {
      final res = await AnalyticsService.overview();
      _overview = res.data;
    } catch (e) {
      _overviewError = e.toString();
    }
    _overviewLoading = false;
    notifyListeners();
  }

  Future<void> fetchPropertyAnalytics(String id) async {
    _propertyLoading = true;
    _propertyError = null;
    notifyListeners();
    try {
      final res = await AnalyticsService.property(id);
      _propertyAnalytics = res.data;
    } catch (e) {
      _propertyError = e.toString();
    }
    _propertyLoading = false;
    notifyListeners();
  }
}
