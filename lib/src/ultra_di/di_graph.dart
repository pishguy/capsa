class DIGraph {

  static final DIGraph instance = DIGraph._();

  DIGraph._();

  final List<Type> _stack = [];

  final Map<Type, Set<Type>> _deps = {};

  void push(Type type) {

    if (_stack.contains(type)) {
      final chain = [..._stack, type];
      throw Exception('Circular dependency: $chain');
    }

    _stack.add(type);
  }

  void pop() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void addEdge(Type from, Type to) {
    _deps.putIfAbsent(from, () => {});
    _deps[from]!.add(to);
  }

  Map<Type, Set<Type>> get graph => _deps;
}
