import 'package:flutter/material.dart';
import 'package:homebazaar/model/analytics.dart';
import 'package:homebazaar/model/misc.dart';
import 'package:homebazaar/model/support_ticket.dart';
import 'package:homebazaar/services/misc_services.dart';

// ─── Saved Properties ─────────────────────────────────────────────────────────

class SavedProvider extends ChangeNotifier {
  List<ApiSavedProperty> _items = [];
  bool _loading = false;
  String? _error;

  List<ApiSavedProperty> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  bool isSaved(String propertyId) =>
      _items.any((s) => (s.property is String ? s.property : (s.property as dynamic).id) == propertyId);

  Future<void> fetchList({int? page, int? limit}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await SavedSearchesService.list(page: page, limit: limit);
      _items = res.data;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> toggle(String propertyId) async {
    try {
      final res = await SavedSearchesService.toggle(propertyId);
      final saved = res.data['saved'] as bool;
      if (!saved) {
        _items.removeWhere((s) =>
            (s.property is String ? s.property : (s.property as dynamic).id) == propertyId);
      }
      // Re-fetch to get the new saved item if added
      if (saved) await fetchList();
      notifyListeners();
      return saved;
    } catch (_) {
      return false;
    }
  }
}

// ─── Search History ───────────────────────────────────────────────────────────

class SearchHistoryProvider extends ChangeNotifier {
  List<ApiSearchHistory> _history = [];
  bool _loading = false;
  String? _error;

  List<ApiSearchHistory> get history => _history;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchList({int? page, int? limit}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await SearchHistoryService.list(page: page, limit: limit);
      _history = res.data;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> record({required String query, Map<String, dynamic>? filters}) async {
    try {
      final res = await SearchHistoryService.record(query: query, filters: filters);
      _history.insert(0, res.data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await SearchHistoryService.delete(id);
      _history.removeWhere((h) => h.id == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteAll() async {
    try {
      await SearchHistoryService.deleteAll();
      _history.clear();
      notifyListeners();
    } catch (_) {}
  }
}

// ─── Analytics ────────────────────────────────────────────────────────────────

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

// ─── Support ──────────────────────────────────────────────────────────────────

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
        status: status, category: category,
        priority: priority, page: page, limit: limit,
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
        subject: subject, category: category,
        message: message, priority: priority,
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
        _detail = TicketDetailResponse(ticket: res.data, messages: _detail!.messages);
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
