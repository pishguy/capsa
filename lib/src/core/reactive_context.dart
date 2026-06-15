part of 'reactive_core.dart';

/// Reactive execution context.
/// Maintains the currently running reactive node.
///
/// Similar to SolidJS owner stack.
class ReactiveContext {
  static final List<ReactiveNode> _stack = [];

  static ReactiveNode? get currentTrackingNode {
    if (_stack.isEmpty) return null;
    return _stack.last;
  }

  /// Execute a node inside tracking context
  static void runNode(ReactiveNode node, void Function() fn) {
    _stack.add(node);

    try {
      fn();
    } finally {
      _stack.removeLast();
    }
  }
}