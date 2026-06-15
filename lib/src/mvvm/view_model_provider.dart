part of '../core/reactive_core.dart';

enum ResourceStatus {
  loading,
  ready,
  error,
}

class XResource<T> {
  final ResourceStatus status;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const XResource._({
    required this.status,
    this.data,
    this.error,
    this.stackTrace,
  });

  const XResource.loading()
      : this._(
    status: ResourceStatus.loading,
  );

  const XResource.ready(T value)
      : this._(
    status: ResourceStatus.ready,
    data: value,
  );

  const XResource.error(
      Object err, [
        StackTrace? stack,
      ]) : this._(
    status: ResourceStatus.error,
    error: err,
    stackTrace: stack,
  );

  bool get isLoading => status == ResourceStatus.loading;

  bool get isReady => status == ResourceStatus.ready;

  bool get isError => status == ResourceStatus.error;
}

class Resource<T> {
  final Signal<XResource<T>> _state;

  final Future<T> Function() _fetcher;

  int _requestId = 0;

  bool _disposed = false;

  Resource._(
      this._state,
      this._fetcher,
      );

  // ----------------------------------------------------------

  XResource<T> call() => _state();

  Signal<XResource<T>> get signal => _state;

  ResourceStatus get status => _state.peek().status;

  T? get data => _state.peek().data;

  Object? get error => _state.peek().error;

  bool get isLoading => _state.peek().isLoading;

  bool get isReady => _state.peek().isReady;

  bool get isError => _state.peek().isError;

  // ----------------------------------------------------------

  static Resource<T> create<T>(
      Future<T> Function() fetcher, {
        bool immediate = true,
      }) {
    final signal = Signal<XResource<T>>(const XResource.loading());

    final resource = Resource._(signal, fetcher);

    if (immediate) {
      resource._executeFetch();
    }

    return resource;
  }

  // ----------------------------------------------------------

  Future<void> reload() async {
    await _executeFetch();
  }

  Future<void> refresh() async {
    _state.value = const XResource.loading();
    await _executeFetch();
  }

  void setData(T value) {
    _state.value = XResource.ready(value);
  }

  void setError(Object err, [StackTrace? stack]) {
    _state.value = XResource.error(err, stack);
  }

  void reset() {
    _state.value = const XResource.loading();
  }

  // ----------------------------------------------------------

  Future<void> _executeFetch() async {
    if (_disposed) return;

    final id = ++_requestId;

    try {
      final result = await _fetcher();

      if (_disposed) return;

      if (id != _requestId) return;

      _state.value = XResource.ready(result);
    } catch (e, s) {
      if (_disposed) return;

      if (id != _requestId) return;

      _state.value = XResource.error(e, s);
    }
  }

  // ----------------------------------------------------------

  void dispose() {
    _disposed = true;
  }
}
