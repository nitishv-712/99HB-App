import 'package:flutter/material.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  List<ApiSupportTicket> _tickets = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  // ── Detail cache (id → response) ─────────────────────────────────────────
  final Map<String, TicketDetailResponse> _detailCache = {};
  String? _detailId;
  bool _detailLoading = false;
  String? _detailError;

  List<ApiSupportTicket> get tickets => _tickets;
  bool get loading => _loading;
  String? get error => _error;

  TicketDetailResponse? get detail =>
      _detailId != null ? _detailCache[_detailId] : null;
  bool get detailLoading => _detailLoading;
  String? get detailError => _detailError;

  Future<void> fetchList({
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    int? page,
    int? limit,
  }) async {
    if (_loaded && _error == null) return;
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
      _loaded = true;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void invalidateList() => _loaded = false;

  Future<void> fetchDetail(String id, {int? page, int? limit}) async {
    _detailId = id;
    if (_detailCache.containsKey(id) && _detailError == null) {
      notifyListeners();
      return;
    }
    _detailLoading = true;
    _detailError = null;
    notifyListeners();
    try {
      final res = await SupportService.get(id, page: page, limit: limit);
      _detailCache[id] = res.data;
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
      _loaded = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addMessage(String id, String message) async {
    try {
      final res = await SupportService.addMessage(id, message);
      if (_detailCache.containsKey(id)) {
        _detailCache[id] = TicketDetailResponse(
          ticket: _detailCache[id]!.ticket,
          messages: [..._detailCache[id]!.messages, res.data],
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
      if (_detailCache.containsKey(id)) {
        _detailCache[id] = TicketDetailResponse(
            ticket: res.data, messages: _detailCache[id]!.messages);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
