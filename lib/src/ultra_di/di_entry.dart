import '../core/reactive_scope.dart';
import 'ultra_di.dart';
import 'di_graph.dart';
import 'disposable.dart';

typedef FactoryFunc<T> = T Function(UltraDI di);
typedef AsyncFactoryFunc<T> = Future<T> Function(UltraDI di);

class DIEntry<T> {

  final FactoryFunc<T>? factory;
  final AsyncFactoryFunc<T>? asyncFactory;

  final bool singleton;
  final bool lazy;

  T? instance;
  Future<T>? future;

  DIEntry.singleton(T value)
      : instance = value,
        factory = null,
        asyncFactory = null,
        singleton = true,
        lazy = false;

  DIEntry.lazySingleton(this.factory)
      : singleton = true,
        lazy = true,
        asyncFactory = null;

  DIEntry.factory(this.factory)
      : singleton = false,
        lazy = false,
        asyncFactory = null;

  DIEntry.asyncSingleton(this.asyncFactory)
      : singleton = true,
        lazy = true,
        factory = null;

  T resolve(UltraDI di, Type type) {

    DIGraph.instance.push(type);

    try {

      if (singleton) {

        if (instance != null) return instance as T;

        if (factory != null) {
          instance = factory!(di);
          return instance as T;
        }

        throw Exception('Async service use getAsync');
      }

      return factory!(di);

    } finally {
      DIGraph.instance.pop();
    }
  }

  Future<T> resolveAsync(UltraDI di, Type type) async {

    DIGraph.instance.push(type);

    try {

      if (future != null) return future!;

      future = asyncFactory!(di);

      instance = await future;

      return instance as T;

    } finally {
      DIGraph.instance.pop();
    }
  }

  void dispose() {

    final obj = instance;

    if (obj is ReactiveScope) {
      obj.dispose();
    }

    if (obj is Disposable) {
      obj.dispose();
    }

    instance = null;
  }
}
