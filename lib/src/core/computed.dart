part of 'reactive_core.dart';


/// Computed node (derived reactive value)
/// Features:
/// - lazy
/// - memoized
/// - glitch‑free
/// - dependency graph tracking
/// - devtools support
class Computed<T> implements ReactiveSource {

  final T Function() _compute;

  /// optional debug label
  final String? debugLabel;

  /// Cached value
  T? _value;

  /// Whether computed executed at least once
  bool _hasValue = false;

  /// subscribers (effects / computeds)
  final Set<ReactiveNode> _subscribers = HashSet();

  /// dependency node
  final _node = _ComputedNode();

  /// guard against recursive compute
  bool _computing = false;

  /// Unique id, used for log messages.
  final int id = CapsaLogger.nextId();

  Computed(
      this._compute, {
        this.debugLabel,
      }) {
    _node._owner = this;

    ReactiveDevTools.registerComputed(this);

    CapsaLogger.debug(CapsaLogCategory.computed, '$_label created');
  }

  String get _label =>
      debugLabel != null ? 'Computed#$id($debugLabel)' : 'Computed#$id<$T>';

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  T call() {

    final tracking = ReactiveContext.currentTrackingNode;

    if (tracking != null) {
      tracking._registerDependency(this);
    }

    if (_node._dirty || !_hasValue) {
      _recompute();
    }

    return _value as T;
  }

  /// read without dependency tracking
  T peek() {

    if (_node._dirty || !_hasValue) {
      _recompute();
    }

    return _value as T;
  }

  // ---------------------------------------------------------------------------
  // RECOMPUTE
  // ---------------------------------------------------------------------------

  void _recompute() {

    if (_computing) {
      CapsaLogger.error(
        CapsaLogCategory.computed,
        '$_label circular dependency detected',
      );
      throw Exception('Circular computed detected: $debugLabel');
    }

    _computing = true;

    _node._dirty = false;

    _node._cleanupDependencies();

    final stopwatch = Stopwatch()..start();
    final previous = _hasValue ? _value : null;

    ReactiveContext.runNode(_node, () {

      final next = _compute();

      if (!_hasValue || next != _value) {
        _value = next;
      }

      _hasValue = true;

    });

    stopwatch.stop();

    _computing = false;

    CapsaLogger.debug(
      CapsaLogCategory.computed,
      '$_label recomputed (${_node._deps.length} dep(s), '
      '${stopwatch.elapsedMicroseconds}µs)',
      data: '$previous -> $_value',
    );
  }

  // ---------------------------------------------------------------------------
  // Dirty propagation
  // ---------------------------------------------------------------------------

  void _markDirtyAndNotify() {

    if (_node._dirty) return;

    _node._dirty = true;

    CapsaLogger.verbose(
      CapsaLogCategory.computed,
      '$_label marked dirty, notifying ${_subscribers.length} subscriber(s)',
    );

    for (final sub in _subscribers) {
      sub._markAsDirtyAndSchedule();
    }
  }

  // ---------------------------------------------------------------------------
  // Subscribers
  // ---------------------------------------------------------------------------

  @override
  void addSubscriber(ReactiveNode node) {
    _subscribers.add(node);
  }

  @override
  void removeSubscriber(ReactiveNode node) {
    _subscribers.remove(node);
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {

    _node.dispose();

    _subscribers.clear();

    ReactiveDevTools.unregisterComputed(this);

    CapsaLogger.debug(CapsaLogCategory.computed, '$_label disposed');
  }

  // ---------------------------------------------------------------------------

  @override
  String toString() => '$_label(dirty=${_node._dirty} value=$_value)';
}


/// Internal node controlling computed execution
class _ComputedNode extends ReactiveNode {

  Computed? _owner;

  /// Computeds run BEFORE effects in the scheduler, so that any effect
  /// reading a computed in the same flush sees an up-to-date dirty flag
  /// and the dependency graph stays glitch-free.
  ///
  /// NOTE: this was previously unset, which meant `_ComputedNode` fell
  /// back to the default `ReactivePriority.effect` and the `computed`
  /// queue in [ReactiveScheduler] was never used.
  @override
  ReactivePriority get priority => ReactivePriority.computed;

  @override
  void _execute() {

    /// Computed doesn't recompute here
    /// it only marks itself dirty
    _owner?._markDirtyAndNotify();
  }
}

/// helper factory
Computed<T> computed<T>(
    T Function() fn, {
      String? label,
    }) {
  return Computed(fn, debugLabel: label);
}
