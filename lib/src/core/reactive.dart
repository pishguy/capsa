import 'reactive_core.dart';

class Reactive<T> {
  final T? _value;
  final Signal<T>? _signal;

  const Reactive._value(this._value) : _signal = null;
  const Reactive._signal(this._signal) : _value = null;

  bool get isSignal => _signal != null;

  T read() {
    final s = _signal;
    if (s != null) return s();
    return _value as T;
  }

  Signal<T>? get signal => _signal;
}

extension ReactiveValueExt<T> on T {
  Reactive<T> get rx => Reactive._value(this);
}

extension ReactiveSignalExt<T> on Signal<T> {
  Reactive<T> get rx => Reactive._signal(this);
}
