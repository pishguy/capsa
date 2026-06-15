part of 'reactive_core.dart';

/// Execution priority for reactive nodes
enum ReactivePriority { computed, render, effect, low }

/// Global reactive scheduler.
///
/// Features:
/// - batching
/// - priority queues
/// - microtask flushing
/// - deduplicated node execution
/// - ordered graph updates
class ReactiveScheduler {
  // ---------------------------------------------------------------------------
  // Batch state
  // ---------------------------------------------------------------------------

  static bool _batching = false;

  static bool get isBatching => _batching;

  // ---------------------------------------------------------------------------
  // Flush state
  // ---------------------------------------------------------------------------

  static bool _flushScheduled = false;

  // ---------------------------------------------------------------------------
  // Pending signal writes
  // ---------------------------------------------------------------------------

  static final Set<Signal> _pendingSignals = HashSet();

  // ---------------------------------------------------------------------------
  // Priority queues
  // ---------------------------------------------------------------------------

  static final Queue<ReactiveNode> _computedQueue = ListQueue();
  static final Queue<ReactiveNode> _renderQueue = ListQueue();
  static final Queue<ReactiveNode> _effectQueue = ListQueue();
  static final Queue<ReactiveNode> _lowQueue = ListQueue();

  /// Prevent duplicate scheduling
  static final Set<ReactiveNode> _scheduledNodes = HashSet();

  // ---------------------------------------------------------------------------
  // Batch API
  // ---------------------------------------------------------------------------

  /// Run updates in a batch.
  ///
  /// Prevents intermediate recomputation.
  static void batch(void Function() fn) {
    final prev = _batching;

    _batching = true;

    if (!prev) {
      CapsaLogger.debug(CapsaLogCategory.scheduler, 'batch() started');
    }

    try {
      fn();
    } finally {
      _batching = prev;

      if (!_batching) {
        CapsaLogger.debug(
          CapsaLogCategory.scheduler,
          'batch() ended, flushing ${_pendingSignals.length} pending signal(s)',
        );
        _flushPendingSignals();
        _scheduleFlush();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Signal handling
  // ---------------------------------------------------------------------------

  /// Register signal write during batching
  static void queuePendingSignal(Signal signal) {
    _pendingSignals.add(signal);
  }

  /// Apply pending signal values
  static void _flushPendingSignals() {
    if (_pendingSignals.isEmpty) return;

    final signals = List<Signal>.from(_pendingSignals);

    _pendingSignals.clear();

    for (final signal in signals) {
      signal._flushPendingValue();
    }
  }

  // ---------------------------------------------------------------------------
  // Node scheduling
  // ---------------------------------------------------------------------------

  /// Schedule a reactive node execution
  static void scheduleNode(ReactiveNode node) {
    /// prevent duplicate execution
    if (!_scheduledNodes.add(node)) {
      return;
    }

    switch (node.priority) {
      case ReactivePriority.computed:
        _computedQueue.add(node);
        break;

      case ReactivePriority.render:
        _renderQueue.add(node);
        break;

      case ReactivePriority.effect:
        _effectQueue.add(node);
        break;

      case ReactivePriority.low:
        _lowQueue.add(node);
        break;
    }

    _scheduleFlush();
  }

  // ---------------------------------------------------------------------------
  // Flush control
  // ---------------------------------------------------------------------------

  static void _scheduleFlush() {
    if (_flushScheduled) return;

    _flushScheduled = true;

    scheduleMicrotask(_flush);
  }

  // ---------------------------------------------------------------------------
  // Queue execution
  // ---------------------------------------------------------------------------

  static void _flush() {
    _flushScheduled = false;

    void runQueue(Queue<ReactiveNode> queue) {
      while (queue.isNotEmpty) {
        final node = queue.removeFirst();

        _scheduledNodes.remove(node);

        node._run();
      }
    }

    final totalPending = _computedQueue.length +
        _renderQueue.length +
        _effectQueue.length +
        _lowQueue.length;

    CapsaLogger.verbose(
      CapsaLogCategory.scheduler,
      'flush() started ($totalPending node(s) pending: '
      'computed=${_computedQueue.length}, render=${_renderQueue.length}, '
      'effect=${_effectQueue.length}, low=${_lowQueue.length})',
    );

    /// Execution order matters for graph consistency
    runQueue(_computedQueue);
    runQueue(_renderQueue);
    runQueue(_effectQueue);
    runQueue(_lowQueue);

    CapsaLogger.verbose(CapsaLogCategory.scheduler, 'flush() ended');
  }
}
