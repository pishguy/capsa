part of 'reactive_core.dart';

class Effect {
  final void Function() _fn;

  final _EffectNode _node = _EffectNode();

  bool _disposed = false;

  ReactiveScope? _scope;

  /// Unique id, used for log messages.
  final int id = CapsaLogger.nextId();

  /// Optional human-readable label for debugging/logging.
  final String? debugLabel;

  Effect(this._fn, {ReactiveScope? scope, this.debugLabel}) {
    _node._owner = this;

    _scope = scope;

    _scope?.keepAlive(dispose);

    Devtools.registerEffect(this);

    CapsaLogger.debug(CapsaLogCategory.effect, '$_label created');

    _runEffect();
  }

  String get _label => debugLabel != null ? 'Effect#$id($debugLabel)' : 'Effect#$id';

  void _runEffect() {
    if (_disposed) {
      CapsaLogger.warn(
        CapsaLogCategory.effect,
        '$_label run skipped (already disposed)',
      );
      return;
    }

    _node._dirty = false;

    _node._cleanupDependencies();

    final stopwatch = Stopwatch()..start();

    CapsaLogger.debug(CapsaLogCategory.effect, '$_label run start');

    ReactiveContext.runNode(_node, () {
      _fn();
    });

    stopwatch.stop();

    CapsaLogger.debug(
      CapsaLogCategory.effect,
      '$_label run end (${_node._deps.length} dep(s), '
      '${stopwatch.elapsedMicroseconds}µs)',
    );
  }

  void dispose() {
    if (_disposed) return;

    _disposed = true;

    Devtools.unregisterEffect(this);

    _node.dispose();

    CapsaLogger.debug(CapsaLogCategory.effect, '$_label disposed');
  }

  @override
  String toString() => '$_label(dirty=${_node._dirty}, disposed=$_disposed)';
}


class _EffectNode extends ReactiveNode {

  Effect? _owner;

  @override
  ReactivePriority get priority => ReactivePriority.effect;

  @override
  void _execute() {
    CapsaLogger.verbose(
      CapsaLogCategory.scheduler,
      '${_owner?._label ?? 'Effect(?)'} scheduled to run via scheduleEffect',
    );
    scheduleEffect(() {
      _owner?._runEffect();
    });
  }
}

Effect effect(void Function() fn, {ReactiveScope? scope, String? debugLabel}) {
  return Effect(fn, scope: scope, debugLabel: debugLabel);
}
