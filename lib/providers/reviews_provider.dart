import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/services/reviews_service.dart';

class ReviewsProvider extends ChangeNotifier {
  final _property = ProviderMapState<String,
      ({List<ApiReview> reviews, ReviewStats? stats, ApiReview? userReview})>();
  final _myReviews = ProviderState<List<ApiReview>>();

  List<ApiReview> get reviews => _property.active?.reviews ?? [];
  ReviewStats? get stats => _property.active?.stats;
  ApiReview? get userReview => _property.active?.userReview;
  bool get loading => _property.loading;
  String? get error => _property.error;

  List<ApiReview> get myReviews => _myReviews.data ?? [];
  bool get myLoading => _myReviews.loading;
  String? get myError => _myReviews.error;

  Future<void> fetchForProperty(String propertyId, {
    int? rating, String? sort, int? page, int? limit,
  }) async {
    _property.setActive(propertyId);
    if (!_property.shouldFetch(propertyId)) {
      notifyListeners();
      return;
    }
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
      _property.setData(
          propertyId, (reviews: reviews, stats: stats, userReview: userReview));
    } catch (e) {
      _property.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateProperty(String propertyId) => _property.remove(propertyId);

  Future<void> fetchMyReviews({int? page, int? limit}) async {
    if (!_myReviews.shouldFetch) return;
    _myReviews.startLoading();
    notifyListeners();
    try {
      final res = await ReviewsService.myReviews(page: page, limit: limit);
      _myReviews.setData(res.data);
    } catch (e) {
      _myReviews.setError(e.toString());
    }
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
          propertyId: propertyId, rating: rating, title: title, comment: comment);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, {int? rating, String? title, String? comment}) async {
    try {
      final res = await ReviewsService.update(id,
          rating: rating, title: title, comment: comment);
      final data = _myReviews.data;
      if (data != null) {
        final idx = data.indexWhere((r) => r.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ReviewsService.delete(id);
      _myReviews.data?.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
