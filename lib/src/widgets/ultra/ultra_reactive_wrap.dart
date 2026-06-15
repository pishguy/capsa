import 'package:flutter/widgets.dart';
import '../../collections/reactive_list.dart';

class UltraWrap<T> extends StatefulWidget {
  final ReactiveList<T> list;
  final Widget Function(T item, int index) builder;

  final double itemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const UltraWrap({
    super.key,
    required this.list,
    required this.builder,
    required this.itemWidth,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
  });

  @override
  State<UltraWrap<T>> createState() => _UltraWrapState<T>();
}

class _UltraWrapState<T> extends State<UltraWrap<T>> {
  late List<T> _items;

  @override
  void initState() {
    super.initState();

    _items = widget.list.value;

    widget.list.subscribeCallback(_listener);
  }

  void _listener(int _) {
    _items = widget.list.value;

    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant UltraWrap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.list != widget.list) {
      oldWidget.list.unsubscribeCallback(_listener);
      widget.list.subscribeCallback(_listener);
      _items = widget.list.value;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    widget.list.unsubscribeCallback(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.itemWidth,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item = _items[index];
          return widget.builder(item, index);
        },
        childCount: _items.length,
      ),
    );
  }
}
