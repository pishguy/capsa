part of 'reactive_core.dart';

/// Reactive signal (source node in graph)
/// Push-based propagation system
/// Subscribers are Effects & Computeds (via ReactiveNode) OR Callbacks (via Mixins)
class Signal<T> implements ReactiveSource {
  T _value;

  // 1. Subscribers for ReactiveNode (Effect/Computed)
  final Set<ReactiveNode> _reactiveSubscribers = HashSet();

  // 2. Subscribers for Callback-based (Render Mixin)
  final Set<void Function(T)> _callbackSubscribers = HashSet();

  bool _isPending = false;
  T? _pendingValue;

  /// Unique id, used for log messages.
  final int id = CapsaLogger.nextId();

  /// Optional human-readable label for debugging/logging.
  final String? debugLabel;

  Signal(this._value, {this.debugLabel}) {
    ReactiveDevTools.registerSignal(this);
    CapsaLogger.verbose(
      CapsaLogCategory.signal,
      '$_label created',
      data: _value,
    );
  }

  String get _label => debugLabel != null ? 'Signal#$id($debugLabel)' : 'Signal#$id<$T>';

  /// Public accessor for [_label], used by other libraries (e.g.
  /// `ReactiveList`) that want to include this signal's identity in logs.
  String get label => _label;

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  T call() {
    final node = ReactiveContext.currentTrackingNode;
    if (node != null) {
      // اگر در حال اجرای یک Effect/Computed هستیم، dependency را به روش ReactiveNode ثبت کن
      node._registerDependency(this);
      CapsaLogger.verbose(
        CapsaLogCategory.signal,
        '$_label read (tracked by $node)',
      );
    } else {
      // اگر در حالت رندر یا جایی دیگر هستیم، dependency را ثبت نکنیم
      // (این رفتار را باید در UltraReactiveRenderMixin کنترل کنیم)
    }
    return _value;
  }

  T peek() => _value;

  // ---------------------------------------------------------------------------
  // WRITE
  // ---------------------------------------------------------------------------

  set value(T next) {
    if (identical(next, _value)) {
      CapsaLogger.verbose(
        CapsaLogCategory.signal,
        '$_label write skipped (identical value)',
        data: next,
      );
      return;
    }

    if (ReactiveScheduler.isBatching) {
      _isPending = true;
      _pendingValue = next;
      ReactiveScheduler.queuePendingSignal(this);
      CapsaLogger.debug(
        CapsaLogCategory.signal,
        '$_label write queued (batching)',
        data: '$_value -> $next',
      );
      return;
    }

    CapsaLogger.debug(
      CapsaLogCategory.signal,
      '$_label write',
      data: '$_value -> $next',
    );

    _applyValue(next);
  }

  void _applyValue(T next) {
    _value = next;
    _isPending = false;
    _pendingValue = null;

    _notifyReactiveNodes();
    _notifyCallbacks();
  }

  void _flushPendingValue() {
    if (_isPending) {
      final next = _pendingValue as T;
      _applyValue(next);
    }
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATION
  // ---------------------------------------------------------------------------

  void _notifyReactiveNodes() {
    if (_reactiveSubscribers.isEmpty) return;
    CapsaLogger.verbose(
      CapsaLogCategory.signal,
      '$_label notifying ${_reactiveSubscribers.length} reactive subscriber(s)',
    );
    for (final node in _reactiveSubscribers) {
      node._markAsDirtyAndSchedule();
    }
  }

  void _notifyCallbacks() {
    if (_callbackSubscribers.isEmpty) return;
    CapsaLogger.verbose(
      CapsaLogCategory.signal,
      '$_label notifying ${_callbackSubscribers.length} callback subscriber(s)',
    );
    final currentValue = _value;
    for (final callback in _callbackSubscribers) {
      callback(currentValue);
    }
  }

  // ---------------------------------------------------------------------------
  // ReactiveNode Subscription (Effect/Computed)
  // ---------------------------------------------------------------------------

  @override
  void addSubscriber(ReactiveNode node) {
    _reactiveSubscribers.add(node);
  }

  @override
  void removeSubscriber(ReactiveNode node) {
    _reactiveSubscribers.remove(node);
  }

  // ---------------------------------------------------------------------------
  // Callback Subscription (Render Mixin)
  // ---------------------------------------------------------------------------

  void subscribeCallback(void Function(T) callback) {
    _callbackSubscribers.add(callback);
    // در اینجا مقدار اولیه را ارسال نمی‌کنیم چون در UltraReactiveRenderMixin
    // مقدار اولیه با .call() خوانده می‌شود.
  }

  void unsubscribeCallback(void Function(T) callback) {
    _callbackSubscribers.remove(callback);
  }

  @override
  String toString() => '$_label(value=$_value)';
}

/// Reactive source interface: Signal or Computed
abstract class ReactiveSource {
  void addSubscriber(ReactiveNode node);

  void removeSubscriber(ReactiveNode node);
}
