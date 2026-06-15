import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'stack_parent_data.dart';
import 'ultra_reactive_stack.dart';

class UltraReactivePositioned extends ParentDataWidget<UltraStackParentData> {
  final Object? left;
  final Object? right;
  final Object? top;
  final Object? bottom;
  final Object? width;
  final Object? height;

  const UltraReactivePositioned({
    super.key,
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.width,
    this.height,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parent = renderObject.parentData as UltraStackParentData;

    bool needsLayout = false;

    void setField<T>(T? current, T? newValue, void Function(T?) setter) {
      if (current != newValue) {
        setter(newValue);
        needsLayout = true;
      }
    }

    setField(parent.left, left as double?, (v) => parent.left = v);
    setField(parent.right, right as double?, (v) => parent.right = v);
    setField(parent.top, top as double?, (v) => parent.top = v);
    setField(parent.bottom, bottom as double?, (v) => parent.bottom = v);
    setField(parent.width, width as double?, (v) => parent.width = v);
    setField(parent.height, height as double?, (v) => parent.height = v);

    if (needsLayout) {
      final parentRender = renderObject.parent;
      parentRender?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => UltraReactiveStack;
}
