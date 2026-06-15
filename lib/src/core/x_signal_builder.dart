part of 'reactive_core.dart';

class MemoizedValue<T> {
  final T Function() _compute;

  T? _cache;

  bool _dirty = true;

  MemoizedValue(this._compute);

  T get value {
    if (_dirty) {
      _cache = _compute();
      _dirty = false;
    }
    return _cache as T;
  }

  void invalidate() {
    _dirty = true;
  }
}

class XMemoized extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const XMemoized({
    super.key,
    required this.builder,
  });

  @override
  State<XMemoized> createState() => _XMemoizedState();
}

class _XMemoizedState extends State<XMemoized> {
  Widget? _cache;

  @override
  Widget build(BuildContext context) {
    _cache ??= widget.builder(context);
    return _cache!;
  }

  @override
  void didUpdateWidget(covariant XMemoized oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.builder != widget.builder) {
      _cache = widget.builder(context);
    }
  }
}
