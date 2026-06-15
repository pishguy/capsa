import 'package:flutter/widgets.dart';
import '../collections/reactive_list.dart';

class UltraFor<T> extends StatefulWidget {

  final ReactiveList<T> list;
  final Widget Function(T item, int index) builder;

  const UltraFor({
    super.key,
    required this.list,
    required this.builder,
  });

  @override
  State<UltraFor<T>> createState() => _UltraForState<T>();
}

class _UltraForState<T> extends State<UltraFor<T>> {

  late List<T> _items;

  @override
  void initState() {
    super.initState();

    _items = List.from(widget.list.value);

    widget.list.subscribeCallback(_listener);
  }

  @override
  void didUpdateWidget(covariant UltraFor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.list != widget.list) {

      oldWidget.list.unsubscribeCallback(_listener);

      widget.list.subscribeCallback(_listener);

      _items = List.from(widget.list.value);

      setState(() {});
    }
  }

  void _listener(int _) {

    final newItems = widget.list.value;

    if (identical(newItems, _items)) return;

    _items = List.from(newItems);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.list.unsubscribeCallback(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final items = _items;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {

          final item = items[index];

          return KeyedSubtree(
            key: ValueKey(item),
            child: widget.builder(item, index),
          );

        },
        childCount: items.length,
      ),
    );
  }
}
