import 'package:flutter/material.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  List<ApiSupportTicket> _tickets = [];
  bool _loading = false;
  String? _error;

  TicketDetailResponse? _detail;
  bool _detailLoading = false;
  String? _detailError;

  List<ApiSupportTicket> get tickets => _tickets;
  bool get loading => _loading;
  String? get error => _error;

  TicketDetailResponse? get detail => _detail;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> fetchList({
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    int? page,
    int? limit,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await SupportService.list(
        status: status,
        category: category,
        priority: priority,
        page: page,
        limit: limit,
      );
      _tickets = res.data;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(String id, {int? page, int? limit}) async {
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await SupportService.get(id, page: page, limit: limit);
      _detail = res.data;
    } catch (e) {
      _detailError = e.toString();
    }
    _detailLoading = false;
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
        subject: subject,
        category: category,
        message: message,
        priority: priority,
      );
      _tickets.insert(0, res.data);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addMessage(String id, String message) async {
    try {
      final res = await SupportService.addMessage(id, message);
      if (_detail != null && _detail!.ticket.id == id) {
        _detail = TicketDetailResponse(
          ticket: _detail!.ticket,
          messages: [..._detail!.messages, res.data],
        );
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
      final idx = _tickets.indexWhere((t) => t.id == id);
      if (idx != -1) _tickets[idx] = res.data;
      if (_detail?.ticket.id == id) {
        _detail = TicketDetailResponse(
            ticket: res.data, messages: _detail!.messages);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
