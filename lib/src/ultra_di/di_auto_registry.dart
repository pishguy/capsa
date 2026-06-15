import 'ultra_di.dart';

typedef AutoFactory<T> = T Function(UltraDI di);

class DIAutoRegistry {

  static final Map<Type, AutoFactory> _factories = {};

  static void register<T>(AutoFactory<T> factory) {
    _factories[T] = factory;
  }

  static AutoFactory<T>? get<T>() {
    final f = _factories[T];
    if (f == null) return null;
    return f as AutoFactory<T>;
  }

  static bool contains(Type t) {
    return _factories.containsKey(t);
  }

}
