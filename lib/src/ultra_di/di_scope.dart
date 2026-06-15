import 'di_entry.dart';

class DIScope {

  final Map<Type, DIEntry> _entries = {};

  bool contains(Type type) {
    return _entries.containsKey(type);
  }

  DIEntry? get(Type type) {
    return _entries[type];
  }

  void register(Type type, DIEntry entry) {
    _entries[type] = entry;
  }

  void remove(Type type) {
    final entry = _entries.remove(type);
    entry?.dispose();
  }

  void disposeAll() {

    for (final entry in _entries.values) {
      entry.dispose();
    }

    _entries.clear();
  }
}
