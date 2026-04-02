import 'package:flutter/material.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/services/inquiries_service.dart';

class InquiriesProvider extends ChangeNotifier {
  // ── List ──────────────────────────────────────────────────────────────────
  List<ApiInquiry> _inquiries = [];
  bool _loading = false;
  String? _error;

  List<ApiInquiry> get inquiries => _inquiries;
  bool get loading => _loading;
  String? get error => _error;

  // ── Detail ────────────────────────────────────────────────────────────────
  SingleInquiryData? _detail;
  bool _detailLoading = false;
  String? _detailError;

  SingleInquiryData? get detail => _detail;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchMyInquiries({InquiryStatus? status, int? page, int? limit}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await InquiriesService.myInquiries(status: status, page: page, limit: limit);
      _inquiries = res.data;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await InquiriesService.get(id);
      _detail = res.data;
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
    notifyListeners();
  }

  Future<bool> submit({required String propertyId, required String message}) async {
    try {
      final res = await InquiriesService.submit(propertyId: propertyId, message: message);
      _inquiries.insert(0, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendMessage(String id, String text) async {
    try {
      await InquiriesService.sendMessage(id, text);
      // Re-fetch detail to get updated messages
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
      if (_detail?.inquiry.id == id) {
        _detail = SingleInquiryData(inquiry: res.data, messages: _detail!.messages);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
