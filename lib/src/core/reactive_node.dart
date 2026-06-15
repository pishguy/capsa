part of 'reactive_core.dart';

/// Base class for nodes inside reactive graph
///
/// Used by:
/// - Effect
/// - Computed
abstract class ReactiveNode {
  /// Execution priority used by ReactiveScheduler
  ReactivePriority get priority => ReactivePriority.effect;

  /// Dependencies this node depends on
  final Set<ReactiveSource> _deps = HashSet();

  /// Whether node is dirty
  bool _dirty = true;

  /// Whether node is already scheduled
  bool _scheduled = false;

  // ---------------------------------------------------------------------------
  // Dependency tracking
  // ---------------------------------------------------------------------------

  void _registerDependency(ReactiveSource source) {
    if (_deps.add(source)) {
      source.addSubscriber(this);

      /// DevTools graph edge
      ReactiveDevTools.registerDependency(source, this);
    }
  }

  void _cleanupDependencies() {
    for (final d in _deps) {
      d.removeSubscriber(this);
    }

    _deps.clear();
  }

  // ---------------------------------------------------------------------------
  // Dirty handling
  // ---------------------------------------------------------------------------

  void _markAsDirtyAndSchedule() {
    if (_dirty) return;

    _dirty = true;

    if (!_scheduled) {
      _scheduled = true;

      ReactiveScheduler.scheduleNode(this);
    }
  }

  // ---------------------------------------------------------------------------
  // Execution
  // ---------------------------------------------------------------------------

  void _run() {
    _scheduled = false;

    if (!_dirty) return;

    _dirty = false;

    _execute();
  }

  /// Implemented by Effect / ComputedNode
  void _execute();

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    _cleanupDependencies();
  }
}
