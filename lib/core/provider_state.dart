/// Holds async state for a single data fetch: data, loading, error.
class ProviderState<T> {
  T? _data;
  bool _loading = false;
  String? _error;

  T? get data => _data;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasData => _data != null;

  /// Skip fetch if data is already loaded and there's no error.
  bool get shouldFetch => _data == null || _error != null;

  void startLoading() {
    _loading = true;
    _error = null;
  }

  /// Like startLoading but keeps existing data visible (for refetch).
  void startRefresh() {
    _loading = true;
    _error = null;
  }

  void setData(T data) {
    _data = data;
    _loading = false;
    _error = null;
  }

  void setError(String error) {
    _error = error;
    _loading = false;
  }

  void invalidate() {
    _data = null;
    _error = null;
  }

  void clear() {
    _data = null;
    _loading = false;
    _error = null;
  }
}

/// Holds async state for a map-based detail cache keyed by id.
class ProviderMapState<K, V> {
  final _store = <K, V>{};
  K? _activeKey;
  bool _loading = false;
  String? _error;

  V? get active => _activeKey != null ? _store[_activeKey] : null;
  K? get activeKey => _activeKey;
  bool get loading => _loading;
  String? get error => _error;

  V? get(K key) => _store[key];

  bool has(K key) => _store.containsKey(key);

  /// Skip fetch if this key already has data and there's no error.
  bool shouldFetch(K key) => !_store.containsKey(key) || _error != null;

  void setActive(K key) => _activeKey = key;

  void startLoading(K key) {
    _activeKey = key;
    _store.remove(key);
    _loading = true;
    _error = null;
  }

  void setData(K key, V data) {
    _store[key] = data;
    _loading = false;
    _error = null;
  }

  void setError(String error) {
    _error = error;
    _loading = false;
  }

  void remove(K key) {
    _store.remove(key);
    if (_activeKey == key) _activeKey = null;
  }

  void clear() {
    _store.clear();
    _activeKey = null;
    _loading = false;
    _error = null;
  }
}
