import '../core/capsa_logger.dart';
import '../core/reactive_core.dart';

/// A reactive, observable list.
///
/// BUGFIX: previously this class kept two separate signals
/// (`_version` and `_versionSignal`) — reads/`.value` tracked `_version`,
/// while `subscribeCallback`/`unsubscribeCallback` (used by `UltraFor`,
/// `UltraCollection`, `UltraGrid`, `UltraWrap`, ...) listened on
/// `_versionSignal`. `_notify()` only ever bumped `_version`, so
/// `_versionSignal` never fired and none of the "Ultra" collection
/// widgets ever rebuilt when the list changed. Both APIs now share a
/// single signal.
class ReactiveList<T> {
  final List<T> _list = [];

  final Signal<int> _version;

  int get length => _list.length;

  ReactiveList({String? debugLabel})
      : _version = Signal<int>(0, debugLabel: debugLabel ?? 'ReactiveList<$T>');

  List<T> get value {
    _version(); // dependency read
    return List.unmodifiable(_list);
  }

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  T operator [](int index) {
    _version();
    return _list[index];
  }

  void operator []=(int index, T value) {
    if (_list[index] == value) return;
    _list[index] = value;
    _notify();
  }

  /// Subscribe to structural changes (add/remove/clear/etc).
  /// The callback receives the new version number.
  void subscribeCallback(void Function(int) listener) {
    _version.subscribeCallback(listener);
  }

  void unsubscribeCallback(void Function(int) listener) {
    _version.unsubscribeCallback(listener);
  }

  void add(T value) {
    _list.add(value);
    _notify();
    CapsaLogger.debug(
      CapsaLogCategory.signal,
      '${_version.label} list add',
      data: 'len=${_list.length}',
    );
  }

  void addAll(Iterable<T> values) {
    if (values.isEmpty) return;
    _list.addAll(values);
    _notify();
    CapsaLogger.debug(
      CapsaLogCategory.signal,
      '${_version.label} list addAll',
      data: 'len=${_list.length}',
    );
  }

  void clear() {
    if (_list.isEmpty) return;
    _list.clear();
    _notify();
    CapsaLogger.debug(CapsaLogCategory.signal, '${_version.label} list cleared');
  }

  bool remove(T value) {
    final removed = _list.remove(value);
    if (removed) {
      _notify();
      CapsaLogger.debug(
        CapsaLogCategory.signal,
        '${_version.label} list remove',
        data: 'len=${_list.length}',
      );
    }
    return removed;
  }

  void removeAt(int index) {
    _list.removeAt(index);
    _notify();
    CapsaLogger.debug(
      CapsaLogCategory.signal,
      '${_version.label} list removeAt($index)',
      data: 'len=${_list.length}',
    );
  }

  void insert(int index, T element) {
    _list.insert(index, element);
    _notify();
    CapsaLogger.debug(
      CapsaLogCategory.signal,
      '${_version.label} list insert($index)',
      data: 'len=${_list.length}',
    );
  }

  List<E> mapReactive<E>(E Function(T e) fn) {
    _version();
    return _list.map(fn).toList();
  }

  Iterable<T> whereReactive(bool Function(T e) fn) {
    _version();
    return _list.where(fn);
  }

  /// Run multiple mutations on the underlying list while only emitting
  /// a single notification at the end.
  void batch(void Function(List<T>) fn) {
    ReactiveScheduler.batch(() => fn(_list));
    _notify();
  }

  void _notify() {
    _version.value = _version.peek() + 1;
  }

  @override
  String toString() => 'ReactiveList(len=$length, version=${_version.peek()})';
}
