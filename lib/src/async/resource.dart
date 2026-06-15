import 'dart:async';

import '../core/reactive_core.dart';

enum ResourceStatus { loading, ready, error }

class CapsaResource<T> {
  final Future<T> Function() _loader;

  final Signal<ResourceStatus> status = Signal(ResourceStatus.loading);
  final Signal<T?> data = Signal(null);
  final Signal<Object?> error = Signal(null);
  final Signal<StackTrace?> stack = Signal(null);

  int _requestId = 0;

  CapsaResource(this._loader) {
    _fetch();
  }

  // ---------------------------------------------------------------------------
  // FETCH (internal)
  // ---------------------------------------------------------------------------

  void _fetch() {
    final req = ++_requestId;

    status.value = ResourceStatus.loading;

    _loader().then((value) {
      if (req != _requestId) return; // race safety

      data.value = value;
      error.value = null;
      stack.value = null;
      status.value = ResourceStatus.ready;
    }).catchError((err, st) {
      if (req != _requestId) return;

      error.value = err;
      stack.value = st;
      status.value = ResourceStatus.error;
    });
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------

  Future<void> reload() async => _fetch();

  Future<void> refresh() async => _fetch();

  void reset() {
    _requestId++;
    status.value = ResourceStatus.loading;
    data.value = null;
    error.value = null;
    stack.value = null;
  }
}
