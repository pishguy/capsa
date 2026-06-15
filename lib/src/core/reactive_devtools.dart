import 'dart:collection';

class ReactiveDevTools {
  // ---------------------------------------------------------------------------
  // Node registries
  // ---------------------------------------------------------------------------

  static final Set<Object> _signals = HashSet();
  static final Set<Object> _computeds = HashSet();
  static final Set<Object> _effects = HashSet();

  /// dependency graph
  static final Map<Object, Set<Object>> _edges = {};

  // ---------------------------------------------------------------------------
  // Register nodes
  // ---------------------------------------------------------------------------

  static void registerSignal(Object signal) {
    _signals.add(signal);
  }

  static void unregisterSignal(Object signal) {
    _signals.remove(signal);
    _removeEdgesOf(signal);
  }

  static void registerComputed(Object computed) {
    _computeds.add(computed);
  }

  static void unregisterComputed(Object computed) {
    _computeds.remove(computed);
    _removeEdgesOf(computed);
  }

  static void registerEffect(Object effect) {
    _effects.add(effect);
  }

  static void unregisterEffect(Object effect) {
    _effects.remove(effect);
    _removeEdgesOf(effect);
  }

  // ---------------------------------------------------------------------------
  // Graph edges
  // ---------------------------------------------------------------------------

  static void registerDependency(Object from, Object to) {
    final set = _edges.putIfAbsent(from, () => HashSet());

    set.add(to);
  }

  /// remove edges where node is source or target
  static void _removeEdgesOf(Object node) {
    /// remove outgoing edges
    _edges.remove(node);

    /// remove incoming edges
    for (final entry in _edges.values) {
      entry.remove(node);
    }
  }

  // ---------------------------------------------------------------------------
  // Debug print
  // ---------------------------------------------------------------------------

  static void printReactiveGraph() {
    print('------ Reactive Graph ------');

    if (_edges.isEmpty) {
      print('(empty)');
    }

    for (final entry in _edges.entries) {
      final from = entry.key;

      for (final to in entry.value) {
        print('$from -> $to');
      }
    }

    print('----------------------------');
  }

  static void printStats() {
    int edgeCount = 0;

    for (final v in _edges.values) {
      edgeCount += v.length;
    }

    print('------ Reactive Stats ------');
    print('signals   : ${_signals.length}');
    print('computeds : ${_computeds.length}');
    print('effects   : ${_effects.length}');
    print('edges     : $edgeCount');
    print('----------------------------');
  }

  // ---------------------------------------------------------------------------
  // Memory leak detection
  // ---------------------------------------------------------------------------

  static void detectLeaks() {
    print('------ Leak Detection ------');

    for (final computed in _computeds) {
      bool hasIncoming = false;

      for (final entry in _edges.values) {
        if (entry.contains(computed)) {
          hasIncoming = true;
          break;
        }
      }

      if (!hasIncoming) {
        print('⚠️ Orphan computed detected: $computed');
      }
    }

    for (final effect in _effects) {
      bool hasIncoming = false;

      for (final entry in _edges.values) {
        if (entry.contains(effect)) {
          hasIncoming = true;
          break;
        }
      }

      if (!hasIncoming) {
        print('⚠️ Orphan effect detected: $effect');
      }
    }

    print('----------------------------');
  }
}
