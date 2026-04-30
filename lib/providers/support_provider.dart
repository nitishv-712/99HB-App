import 'package:flutter/material.dart';
import 'package:homebazaar/core/provider_state.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  final _list = ProviderState<List<ApiSupportTicket>>();
  final _detail = ProviderMapState<String, TicketDetailResponse>();

  List<ApiSupportTicket> get tickets => _list.data ?? [];
  bool get loading => _list.loading;
  String? get error => _list.error;

  TicketDetailResponse? get detail => _detail.active;
  bool get detailLoading => _detail.loading;
  String? get detailError => _detail.error;

  Future<void> fetchList({
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    int? page,
    int? limit,
  }) async {
    if (!_list.shouldFetch) return;
    _list.startLoading();
    notifyListeners();
    try {
      final res = await SupportService.list(
        status: status, category: category,
        priority: priority, page: page, limit: limit,
      );
      _list.setData(res.data);
    } catch (e) {
      _list.setError(e.toString());
    }
    notifyListeners();
  }

  void invalidateList() => _list.invalidate();

  Future<void> fetchDetail(String id, {int? page, int? limit}) async {
    _detail.setActive(id);
    if (!_detail.shouldFetch(id)) {
      notifyListeners();
      return;
    }
    notifyListeners();
    try {
      final res = await SupportService.get(id, page: page, limit: limit);
      _detail.setData(id, res.data);
    } catch (e) {
      _detail.setError(e.toString());
    }
    notifyListeners();
  }

  Future<bool> create({
    required String subject,
    required TicketCategory category,
    required String message,
    TicketPriority? priority,
  }) async {
    try {
      final res = await SupportService.create(
        subject: subject, category: category,
        message: message, priority: priority,
      );
      _list.data?.insert(0, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addMessage(String id, String message) async {
    try {
      final res = await SupportService.addMessage(id, message);
      final cached = _detail.get(id);
      if (cached != null) {
        _detail.setData(id, TicketDetailResponse(
          ticket: cached.ticket,
          messages: [...cached.messages, res.data],
        ));
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> close(String id) async {
    try {
      final res = await SupportService.close(id);
      final data = _list.data;
      if (data != null) {
        final idx = data.indexWhere((t) => t.id == id);
        if (idx != -1) data[idx] = res.data;
      }
      final cached = _detail.get(id);
      if (cached != null) {
        _detail.setData(id, TicketDetailResponse(
          ticket: res.data,
          messages: cached.messages,
        ));
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
