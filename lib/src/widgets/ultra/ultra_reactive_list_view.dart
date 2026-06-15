import 'package:flutter/widgets.dart';

import '../../core/reactive_core.dart';

class UltraReactiveListView<T> extends StatefulWidget {
  final Signal<List<T>> items;
  final Widget Function(T item) builder;

  const UltraReactiveListView({
    super.key,
    required this.items,
    required this.builder,
  });

  @override
  State<UltraReactiveListView<T>> createState() =>
      _UltraReactiveListViewState<T>();
}

class _UltraReactiveListViewState<T> extends State<UltraReactiveListView<T>> {

  @override
  void initState() {
    super.initState();
    widget.items.subscribeCallback(_listener);
  }

  void _listener(List<T> _) {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant UltraReactiveListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      oldWidget.items.unsubscribeCallback(_listener);
      widget.items.subscribeCallback(_listener);
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    widget.items.unsubscribeCallback(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.items();

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (c, i) => widget.builder(list[i]),
    );
  }
}
