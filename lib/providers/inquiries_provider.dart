import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/inquiry.dart';
import 'package:homebazaar/services/inquiries_service.dart';

class InquiriesProvider extends ChangeNotifier {
  final _list = ProviderState<List<ApiInquiry>>();
  final _detail = ProviderMapState<String, SingleInquiryData>();

  InquiryStatus? _lastStatus;

  List<ApiInquiry> get inquiries => _list.data ?? [];
  bool get loading => _list.loading;
  String? get error => _list.error;

  SingleInquiryData? get detail => _detail.active;
  bool get detailLoading => _detail.loading;
  String? get detailError => _detail.error;

  Future<void> fetchMyInquiries({
    InquiryStatus? status,
    int? page,
    int? limit,
  }) async {
    if (status != _lastStatus) _lastStatus = status;
    else if (!_list.shouldFetch) return;
    _list.startLoading();
    notifyListeners();
    try {
      final res = await InquiriesService.myInquiries(
        status: status,
        page: page,
        limit: limit,
      );
      _list.setData(res.data);
    } catch (e) {
      _list.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateList() => _list.invalidate();

  Future<void> fetchDetail(String id) async {
    _detail.setActive(id);
    if (!_detail.shouldFetch(id)) {
      notifyListeners();
      return;
    }
    notifyListeners();
    try {
      final res = await InquiriesService.get(id);
      _detail.setData(id, res.data);
    } catch (e) {
      _detail.setError(e.toString());
    }
    notifyListeners();
  }

  Future<bool> submit({
    required String propertyId,
    required String message,
  }) async {
    try {
      final res = await InquiriesService.submit(
        propertyId: propertyId,
        message: message,
      );
      _list.data?.insert(0, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendMessage(String id, String text) async {
    try {
      await InquiriesService.sendMessage(id, text);
      final cached = _detail.get(id);
      if (cached != null) {
        _detail.setData(
          id,
          SingleInquiryData(
            inquiry: cached.inquiry,
            messages: [
              ...cached.messages,
              Message(
                id: id,
                inquiry: cached.messages.first.inquiry,
                sender: cached.messages.first.sender,
                role: cached.messages.first.role,
                text: text,
                createdAt: DateTime.now().toIso8601String(),
                updatedAt: DateTime.now().toIso8601String(),
              ),
            ],
          ),
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, InquiryStatus status) async {
    try {
      final res = await InquiriesService.updateStatus(id, status);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((i) => i.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      final cached = _detail.get(id);
      if (cached != null) {
        _detail.setData(
          id,
          SingleInquiryData(inquiry: res.data, messages: cached.messages),
        );
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
