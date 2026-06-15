import 'di_auto_registry.dart';
import 'ultra_di.dart';

void autoFactory<T>(T Function(UltraDI di) factory) {
  DIAutoRegistry.register<T>(factory);
}

void autoSingleton<T>(T Function(UltraDI di) factory) {

  T? instance;

  DIAutoRegistry.register<T>((di) {

    instance ??= factory(di);

    return instance!;

  });

}
