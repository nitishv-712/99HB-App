import 'package:flutter/material.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/services/reviews_service.dart';

class ReviewsProvider extends ChangeNotifier {
  // ── Property reviews cache (propertyId → data) ────────────────────────────
  final Map<String, ({List<ApiReview> reviews, ReviewStats? stats, ApiReview? userReview})>
      _propertyCache = {};
  String? _currentPropertyId;
  bool _loading = false;
  String? _error;

  List<ApiReview> get reviews =>
      _currentPropertyId != null
          ? (_propertyCache[_currentPropertyId]?.reviews ?? [])
          : [];
  ReviewStats? get stats =>
      _currentPropertyId != null
          ? _propertyCache[_currentPropertyId]?.stats
          : null;
  ApiReview? get userReview =>
      _currentPropertyId != null
          ? _propertyCache[_currentPropertyId]?.userReview
          : null;
  bool get loading => _loading;
  String? get error => _error;

  // ── My reviews ────────────────────────────────────────────────────────────
  List<ApiReview> _myReviews = [];
  bool _myLoading = false;
  String? _myError;
  bool _myLoaded = false;

  List<ApiReview> get myReviews => _myReviews;
  bool get myLoading => _myLoading;
  String? get myError => _myError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchForProperty(
    String propertyId, {
    int? rating,
    String? sort,
    int? page,
    int? limit,
  }) async {
    _currentPropertyId = propertyId;
    if (_propertyCache.containsKey(propertyId) && _error == null) {
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await ReviewsService.forProperty(propertyId,
          rating: rating, sort: sort, page: page, limit: limit);
      final data = raw['data'] as List? ?? [];
      final reviews = data
          .map((e) => ApiReview.fromJson(e as Map<String, dynamic>))
          .toList();
      final stats = raw['stats'] != null
          ? ReviewStats.fromJson(raw['stats'] as Map<String, dynamic>)
          : null;
      final userReview = raw['userReview'] != null
          ? ApiReview.fromJson(raw['userReview'] as Map<String, dynamic>)
          : null;
      _propertyCache[propertyId] =
          (reviews: reviews, stats: stats, userReview: userReview);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void invalidateProperty(String propertyId) =>
      _propertyCache.remove(propertyId);

  Future<void> fetchMyReviews({int? page, int? limit}) async {
    if (_myLoaded && _myError == null) return;
    _myLoading = true;
    _myError = null;
    notifyListeners();
    try {
      final res = await ReviewsService.myReviews(page: page, limit: limit);
      _myReviews = res.data;
      _myLoaded = true;
    } catch (e) {
      _myError = e.toString();
    }
    _myLoading = false;
    notifyListeners();
  }

  Future<bool> submit({
    required String propertyId,
    required int rating,
    required String title,
    required String comment,
  }) async {
    try {
      await ReviewsService.submit(
          propertyId: propertyId,
          rating: rating,
          title: title,
          comment: comment);
      // Invalidate cache so next fetch gets fresh data
      _propertyCache.remove(propertyId);
      _myLoaded = false;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id,
      {int? rating, String? title, String? comment}) async {
    try {
      final res = await ReviewsService.update(id,
          rating: rating, title: title, comment: comment);
      // Update in-place in my reviews
      final myIdx = _myReviews.indexWhere((r) => r.id == id);
      if (myIdx != -1) _myReviews[myIdx] = res.data;
      // Invalidate property cache for the affected property
      final propId = res.data.property is String
          ? res.data.property as String
          : (res.data.property as dynamic).id as String;
      _propertyCache.remove(propId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ReviewsService.delete(id);
      _myReviews.removeWhere((r) => r.id == id);
      // Invalidate all property caches (we don't know which property)
      _propertyCache.clear();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
