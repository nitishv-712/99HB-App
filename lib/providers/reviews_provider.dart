import 'package:flutter/material.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/services/reviews_service.dart';

class ReviewsProvider extends ChangeNotifier {
  // ── Property reviews ──────────────────────────────────────────────────────
  List<ApiReview> _reviews = [];
  ReviewStats? _stats;
  ApiReview? _userReview;
  bool _loading = false;
  String? _error;

  List<ApiReview> get reviews => _reviews;
  ReviewStats? get stats => _stats;
  ApiReview? get userReview => _userReview;
  bool get loading => _loading;
  String? get error => _error;

  // ── My reviews ────────────────────────────────────────────────────────────
  List<ApiReview> _myReviews = [];
  bool _myLoading = false;
  String? _myError;

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
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await ReviewsService.forProperty(
        propertyId, rating: rating, sort: sort, page: page, limit: limit);
      final data = raw['data'] as List? ?? [];
      _reviews = data.map((e) => ApiReview.fromJson(e as Map<String, dynamic>)).toList();
      if (raw['stats'] != null) {
        _stats = ReviewStats.fromJson(raw['stats'] as Map<String, dynamic>);
      }
      if (raw['userReview'] != null) {
        _userReview = ApiReview.fromJson(raw['userReview'] as Map<String, dynamic>);
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchMyReviews({int? page, int? limit}) async {
    _myLoading = true;
    _myError = null;
    notifyListeners();
    try {
      final res = await ReviewsService.myReviews(page: page, limit: limit);
      _myReviews = res.data;
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
      final res = await ReviewsService.submit(
        propertyId: propertyId, rating: rating, title: title, comment: comment);
      _reviews.insert(0, res.data);
      _userReview = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(String id, {int? rating, String? title, String? comment}) async {
    try {
      final res = await ReviewsService.update(id, rating: rating, title: title, comment: comment);
      final idx = _reviews.indexWhere((r) => r.id == id);
      if (idx != -1) _reviews[idx] = res.data;
      if (_userReview?.id == id) _userReview = res.data;
      final myIdx = _myReviews.indexWhere((r) => r.id == id);
      if (myIdx != -1) _myReviews[myIdx] = res.data;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await ReviewsService.delete(id);
      _reviews.removeWhere((r) => r.id == id);
      _myReviews.removeWhere((r) => r.id == id);
      if (_userReview?.id == id) _userReview = null;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
