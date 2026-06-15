import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';
import '../../core/ultra_reactive_render_mixin.dart';
import 'stack_parent_data.dart';

class UltraReactiveStack extends MultiChildRenderObjectWidget {
  final Signal<AlignmentGeometry?>? alignment;
  final Signal<StackFit>? fit;
  final Signal<Clip>? clipBehavior;

  const UltraReactiveStack({
    super.key,
    this.alignment,
    this.fit,
    this.clipBehavior,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UltraReactiveStackRender(
      alignmentSignal: alignment,
      fitSignal: fit,
      clipSignal: clipBehavior,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final r = renderObject as _UltraReactiveStackRender;

    r.updateProps(
      alignmentSignal: alignment,
      fitSignal: fit,
      clipSignal: clipBehavior,
      textDirection: Directionality.of(context),
    );
  }
}

class _UltraReactiveStackRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, UltraStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, UltraStackParentData>,
        UltraReactiveRenderMixin {

  AlignmentGeometry? _alignment;
  StackFit _fit = StackFit.loose;
  Clip _clip = Clip.none;
  TextDirection _textDirection;

  _UltraReactiveStackRender({
    Signal<AlignmentGeometry?>? alignmentSignal,
    Signal<StackFit>? fitSignal,
    Signal<Clip>? clipSignal,
    required TextDirection textDirection,
  }) : _textDirection = textDirection {

    bindSignal<AlignmentGeometry?>(alignmentSignal, (v) {
      _alignment = v;
      markNeedsLayout();
    });

    bindSignal<StackFit>(fitSignal, (v) {
      _fit = v!;
      markNeedsLayout();
    });

    bindSignal<Clip>(clipSignal, (v) {
      _clip = v!;
      markNeedsPaint();
    });
  }

  void updateProps({
    Signal<AlignmentGeometry?>? alignmentSignal,
    Signal<StackFit>? fitSignal,
    Signal<Clip>? clipSignal,
    required TextDirection textDirection,
  }) {
    _textDirection = textDirection;

    bindSignal<AlignmentGeometry?>(alignmentSignal, (v) {
      _alignment = v;
      markNeedsLayout();
    });

    bindSignal<StackFit>(fitSignal, (v) {
      _fit = v!;
      markNeedsLayout();
    });

    bindSignal<Clip>(clipSignal, (v) {
      _clip = v!;
      markNeedsPaint();
    });
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! UltraStackParentData) {
      child.parentData = UltraStackParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    final resolved =
    (_alignment ?? Alignment.topLeft).resolve(_textDirection);

    RenderBox? child = firstChild;

    while (child != null) {
      final parentData = child.parentData as UltraStackParentData;

      if (parentData.isPositioned) {
        final c = constraints;

        final width = parentData.width ??
            (parentData.left != null && parentData.right != null
                ? size.width - parentData.left! - parentData.right!
                : null);

        final height = parentData.height ??
            (parentData.top != null && parentData.bottom != null
                ? size.height - parentData.top! - parentData.bottom!
                : null);

        child.layout(
          BoxConstraints(
            minWidth: width ?? 0,
            maxWidth: width ?? c.maxWidth,
            minHeight: height ?? 0,
            maxHeight: height ?? c.maxHeight,
          ),
          parentUsesSize: true,
        );

        double dx = parentData.left ??
            (parentData.right != null
                ? size.width - parentData.right! - child.size.width
                : 0);

        double dy = parentData.top ??
            (parentData.bottom != null
                ? size.height - parentData.bottom! - child.size.height
                : 0);

        parentData.offset = Offset(dx, dy);
      } else {
        child.layout(constraints.loosen(), parentUsesSize: true);

        final offset =
        resolved.alongSize(size - child.size as Size);
        parentData.offset = offset;
      }

      child = parentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_clip != Clip.none) {
      context.pushClipRect(
        needsCompositing,
        offset,
        offset & size,
        _paintChildren,
        clipBehavior: _clip,
      );
    } else {
      _paintChildren(context, offset);
    }
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
