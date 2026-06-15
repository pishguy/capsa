class DIException implements Exception {
  final String message;

  DIException(this.message);

  @override
  String toString() => 'UltraDI Error: $message';
}

class ServiceNotFound extends DIException {
  ServiceNotFound(Type type)
      : super('Service of type $type is not registered.');
}

class ServiceAlreadyRegistered extends DIException {
  ServiceAlreadyRegistered(Type type)
      : super('Service of type $type is already registered.');
}
