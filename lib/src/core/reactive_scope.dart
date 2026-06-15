import 'capsa_logger.dart';
import 'reactive_core.dart';

typedef Disposer = void Function();

class ReactiveScope {
  final List<Disposer> _disposers = [];

  bool _disposed = false;

  final int id = CapsaLogger.nextId();

  void keepAlive(Disposer disposer) {
    if (_disposed) {
      disposer();
      return;
    }

    _disposers.add(disposer);
  }

  T track<T>(T disposable) {
    if (disposable is Effect) {
      keepAlive(disposable.dispose);
    }

    return disposable;
  }

  void dispose() {
    if (_disposed) return;

    _disposed = true;

    CapsaLogger.debug(
      CapsaLogCategory.mvvm,
      'ReactiveScope#$id disposing ${_disposers.length} disposer(s)',
    );

    for (final d in _disposers.reversed) {
      try {
        d();
      } catch (e, st) {
        // BUGFIX: errors thrown while disposing were silently swallowed,
        // which made leaked effects / failed cleanups invisible. They are
        // now reported through the logger (still without interrupting the
        // disposal of remaining entries).
        CapsaLogger.error(
          CapsaLogCategory.mvvm,
          'ReactiveScope#$id disposer threw',
          data: '$e\n$st',
        );
      }
    }

    _disposers.clear();
  }

  bool get isDisposed => _disposed;
}
