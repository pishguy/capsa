import '../core/reactive_scope.dart';

abstract class ScreenModel extends ReactiveScope {
  bool _initialized = false;

  bool _disposed = false;

  void onInit() {}

  void onDispose() {}

  void attach() {
    if (_initialized) return;

    _initialized = true;

    onInit();
  }

  @override
  void dispose() {
    if (_disposed) return;

    _disposed = true;

    onDispose();

    super.dispose();
  }
}