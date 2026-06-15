import 'reactive_core.dart';

class Devtools {
  static final Set<Signal> _signals = {};
  static final Set<Effect> _effects = {};

  static Iterable<Signal> get signals => _signals;
  static Iterable<Effect> get effects => _effects;

  static void registerSignal(Signal s) {
    assert(() {
      _signals.add(s);
      return true;
    }());
  }

  static void unregisterSignal(Signal s) {
    assert(() {
      _signals.remove(s);
      return true;
    }());
  }

  static void registerEffect(Effect e) {
    assert(() {
      _effects.add(e);
      return true;
    }());
  }

  static void unregisterEffect(Effect e) {
    assert(() {
      _effects.remove(e);
      return true;
    }());
  }
}
