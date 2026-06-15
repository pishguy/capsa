import 'package:flutter/widgets.dart';
import '../../collections/reactive_list.dart';
import '../x_for.dart';
import 'ultra_reactive_grid.dart';
import 'ultra_reactive_wrap.dart';

enum UltraLayout { list, grid, wrap }

class UltraCollection<T> extends StatelessWidget {
  final ReactiveList<T> list;
  final Widget Function(T item, int index) builder;

  final UltraLayout? layout;

  final int? crossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final double? childAspectRatio;

  final double? itemWidth;

  final bool auto;
  final int autoGridThreshold;

  const UltraCollection({
    super.key,
    required this.list,
    required this.builder,
    this.layout,
    this.crossAxisCount,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio,
    this.itemWidth,
    this.auto = false,
    this.autoGridThreshold = 50,
  });

  UltraLayout _decideLayout(List<T> items) {
    if (!auto) return layout ?? UltraLayout.list;

    if (itemWidth != null) return UltraLayout.wrap;
    if (crossAxisCount != null) return UltraLayout.grid;
    if (items.length >= autoGridThreshold) return UltraLayout.grid;

    return UltraLayout.list;
  }

  @override
  Widget build(BuildContext context) {
    final items = list.value;

    final mode = _decideLayout(items);

    switch (mode) {
      case UltraLayout.list:
        return UltraFor<T>(
          list: list,
          builder: builder,
        );

      case UltraLayout.grid:
        return CustomScrollView(
          slivers: [
            UltraGrid<T>(
              list: list,
              builder: builder,
              crossAxisCount: crossAxisCount ?? 2,
              mainAxisSpacing: mainAxisSpacing ?? 8,
              crossAxisSpacing: crossAxisSpacing ?? 8,
              childAspectRatio: childAspectRatio ?? 1,
            ),
          ],
        );

      case UltraLayout.wrap:
        return CustomScrollView(
          slivers: [
            UltraWrap<T>(
              list: list,
              builder: builder,
              itemWidth: itemWidth ?? 120,
              mainAxisSpacing: mainAxisSpacing ?? 8,
              crossAxisSpacing: crossAxisSpacing ?? 8,
            ),
          ],
        );
    }
  }
}
