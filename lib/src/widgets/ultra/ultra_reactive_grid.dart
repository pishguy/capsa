import 'package:flutter/widgets.dart';
import '../../collections/reactive_list.dart';

class UltraGrid<T> extends StatefulWidget {
  final ReactiveList<T> list;
  final Widget Function(T item, int index) builder;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const UltraGrid({
    super.key,
    required this.list,
    required this.builder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.childAspectRatio = 1,
  });

  @override
  State<UltraGrid<T>> createState() => _UltraGridState<T>();
}

class _UltraGridState<T> extends State<UltraGrid<T>> {
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
  void didUpdateWidget(covariant UltraGrid<T> oldWidget) {
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
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
