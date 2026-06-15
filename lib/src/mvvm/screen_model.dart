import '../core/reactive_scope.dart';

abstract class ReactiveModel extends ReactiveScope {

  /// Called once after DI creation
  void onInit() {}

  /// Called when model disposed
  void onDispose() {}

  bool _initialized = false;

  void attach() {
    if (_initialized) return;

    _initialized = true;

    onInit();
  }

  @override
  void dispose() {

    onDispose();

    super.dispose();
  }
}
