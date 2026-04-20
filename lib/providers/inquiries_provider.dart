import 'package:flutter/material.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/services/inquiries_service.dart';

class InquiriesProvider extends ChangeNotifier {
  // ── List ──────────────────────────────────────────────────────────────────
  List<ApiInquiry> _inquiries = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;
  InquiryStatus? _lastStatus;

  List<ApiInquiry> get inquiries => _inquiries;
  bool get loading => _loading;
  String? get error => _error;

  // ── Detail cache (id → data) ──────────────────────────────────────────────
  final Map<String, SingleInquiryData> _detailCache = {};
  String? _detailId;
  bool _detailLoading = false;
  String? _detailError;

  SingleInquiryData? get detail =>
      _detailId != null ? _detailCache[_detailId] : null;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchMyInquiries(
      {InquiryStatus? status, int? page, int? limit}) async {
    if (_loaded && status == _lastStatus && _error == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await InquiriesService.myInquiries(
          status: status, page: page, limit: limit);
      _inquiries = res.data;
      _loaded = true;
      _lastStatus = status;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void invalidateList() => _loaded = false;

  Future<void> fetchDetail(String id) async {
    _detailId = id;
    if (_detailCache.containsKey(id) && _detailError == null) {
      notifyListeners();
      return;
    }
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await InquiriesService.get(id);
      _detailCache[id] = res.data;
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
    notifyListeners();
  }

  Future<bool> submit(
      {required String propertyId, required String message}) async {
    try {
      final res = await InquiriesService.submit(
          propertyId: propertyId, message: message);
      _inquiries.insert(0, res.data);
      _loaded = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendMessage(String id, String text) async {
    try {
      await InquiriesService.sendMessage(id, text);
      // Invalidate detail cache so next open re-fetches messages
      _detailCache.remove(id);
      await fetchDetail(id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, InquiryStatus status) async {
    try {
      final res = await InquiriesService.updateStatus(id, status);
      final idx = _inquiries.indexWhere((i) => i.id == id);
      if (idx != -1) _inquiries[idx] = res.data;
      if (_detailCache.containsKey(id)) {
        _detailCache[id] = SingleInquiryData(
          inquiry: res.data,
          messages: _detailCache[id]!.messages,
        );
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
