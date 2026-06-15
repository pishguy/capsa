import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';

class UltraReactiveFlex extends MultiChildRenderObjectWidget {

  final Signal<Axis>? direction;
  final Signal<double>? gap;

  const UltraReactiveFlex({
    super.key,
    this.direction,
    this.gap,
    required List<Widget> children,
  }) : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UltraFlexRender(direction, gap);
  }

  @override
  void updateRenderObject(
      BuildContext context,
      covariant _UltraFlexRender renderObject,
      ) {
    renderObject.updateSignals(direction, gap);
  }
}

class _UltraFlexRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {

  Signal<Axis>? _direction;
  Signal<double>? _gap;

  _UltraFlexRender(this._direction, this._gap) {
    _subscribe();
  }

  void _listener(dynamic _) {
    markNeedsLayout();
  }

  void _subscribe() {
    _direction?.subscribeCallback(_listener);
    _gap?.subscribeCallback(_listener);
  }

  void _unsubscribe() {
    _direction?.unsubscribeCallback(_listener);
    _gap?.unsubscribeCallback(_listener);
  }

  void updateSignals(Signal<Axis>? d, Signal<double>? g) {
    _unsubscribe();

    _direction = d;
    _gap = g;

    _subscribe();

    markNeedsLayout();
  }

  @override
  void detach() {
    _unsubscribe();
    super.detach();
  }

  @override
  void performLayout() {

    final axis = _direction?.call() ?? Axis.horizontal;
    final gap = _gap?.call() ?? 0.0;

    double main = 0;
    double cross = 0;

    RenderBox? child = firstChild;

    while (child != null) {

      child.layout(constraints, parentUsesSize: true);

      final sizeChild = child.size;

      if (axis == Axis.horizontal) {

        main += sizeChild.width;
        cross = cross > sizeChild.height ? cross : sizeChild.height;

      } else {

        main += sizeChild.height;
        cross = cross > sizeChild.width ? cross : sizeChild.width;

      }

      final parentData = child.parentData as FlexParentData;
      child = parentData.nextSibling;
    }

    int count = childCount;
    if (count > 1) main += gap * (count - 1);

    if (axis == Axis.horizontal) {
      size = constraints.constrain(Size(main, cross));
    } else {
      size = constraints.constrain(Size(cross, main));
    }

    double offset = 0;

    child = firstChild;

    while (child != null) {

      final parentData = child.parentData as FlexParentData;

      if (axis == Axis.horizontal) {
        parentData.offset = Offset(offset, 0);
        offset += child.size.width + gap;
      } else {
        parentData.offset = Offset(0, offset);
        offset += child.size.height + gap;
      }

      child = parentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
