import 'di_auto_registry.dart';
import 'di_scope.dart';
import 'di_entry.dart';
import 'di_exceptions.dart';
import 'di_graph.dart';
import '../core/capsa_logger.dart';

class UltraDI {

  static final UltraDI _global = UltraDI._internal();

  factory UltraDI() => _global;

  UltraDI._internal() {
    _scopes.add(DIScope());
  }

  final List<DIScope> _scopes = [];

  DIScope get _currentScope => _scopes.last;

  // -------------------------
  // Register
  // -------------------------
  void registerAutoFactory<T>() {

    final factory = DIAutoRegistry.get<T>();

    if (factory == null) {
      throw DIException('No auto factory registered for $T');
    }

    registerFactory<T>((di) => factory(di));
  }

  void registerAutoLazySingleton<T>() {

    final factory = DIAutoRegistry.get<T>();

    if (factory == null) {
      throw DIException('No auto factory registered for $T');
    }

    registerLazySingleton<T>((di) => factory(di));
  }

  void registerSingleton<T>(T instance) {

    final type = T;

    if (_currentScope.contains(type)) {
      throw ServiceAlreadyRegistered(type);
    }

    _currentScope.register(type, DIEntry.singleton(instance));

    CapsaLogger.info(CapsaLogCategory.di, 'registered singleton $type (scope ${_scopes.length - 1})');
  }

  void registerLazySingleton<T>(FactoryFunc<T> factory) {

    final type = T;

    if (_currentScope.contains(type)) {
      throw ServiceAlreadyRegistered(type);
    }

    _currentScope.register(type, DIEntry.lazySingleton(factory));

    CapsaLogger.info(CapsaLogCategory.di, 'registered lazy singleton $type (scope ${_scopes.length - 1})');
  }

  void registerFactory<T>(FactoryFunc<T> factory) {

    final type = T;

    if (_currentScope.contains(type)) {
      throw ServiceAlreadyRegistered(type);
    }

    _currentScope.register(type, DIEntry.factory(factory));

    CapsaLogger.info(CapsaLogCategory.di, 'registered factory $type (scope ${_scopes.length - 1})');
  }

  void registerAsyncSingleton<T>(AsyncFactoryFunc<T> factory) {

    final type = T;

    if (_currentScope.contains(type)) {
      throw ServiceAlreadyRegistered(type);
    }

    _currentScope.register(type, DIEntry.asyncSingleton(factory));

    CapsaLogger.info(CapsaLogCategory.di, 'registered async singleton $type (scope ${_scopes.length - 1})');
  }

  // -------------------------
  // Resolve
  // -------------------------

  T get<T>() {

    final type = T;

    for (var i = _scopes.length - 1; i >= 0; i--) {

      final scope = _scopes[i];

      final entry = scope.get(type);

      if (entry != null) {

        CapsaLogger.debug(CapsaLogCategory.di, 'resolving $type from scope $i');

        return entry.resolve(this, type) as T;
      }
    }

    /// ---------- AUTO FACTORY ----------
    final autoFactory = DIAutoRegistry.get<T>();

    if (autoFactory != null) {

      CapsaLogger.debug(CapsaLogCategory.di, 'resolving $type via auto-factory');

      final instance = autoFactory(this);

      return instance;
    }

    CapsaLogger.error(CapsaLogCategory.di, 'service not found: $type');

    throw ServiceNotFound(type);
  }


  Future<T> getAsync<T>() async {

    final type = T;

    for (var i = _scopes.length - 1; i >= 0; i--) {

      final scope = _scopes[i];

      final entry = scope.get(type);

      if (entry != null) {
        return await entry.resolveAsync(this, type);
      }
    }

    throw ServiceNotFound(type);
  }

  // -------------------------
  // Scope
  // -------------------------

  void pushScope() {
    _scopes.add(DIScope());
    CapsaLogger.debug(CapsaLogCategory.di, 'pushed scope, depth=${_scopes.length}');
  }

  void popScope() {

    if (_scopes.length == 1) {
      throw DIException('Cannot remove root scope');
    }

    final scope = _scopes.removeLast();

    CapsaLogger.debug(CapsaLogCategory.di, 'popping scope, depth=${_scopes.length}');

    scope.disposeAll();
  }

  // -------------------------
  // Reset
  // -------------------------

  void reset() {

    for (final scope in _scopes) {
      scope.disposeAll();
    }

    _scopes.clear();

    _scopes.add(DIScope());

    CapsaLogger.info(CapsaLogCategory.di, 'UltraDI reset');
  }
}



/*
ReactiveRouter integration
DevTools Graph UI
ReactiveList diff engine
automatic ViewModel injection
store system شبیه Pinia/Vuex*/