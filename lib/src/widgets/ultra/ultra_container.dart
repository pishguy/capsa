import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../core/ultra_reactive_render_mixin.dart';

class UltraReactiveBox extends SingleChildRenderObjectWidget {
  final Object? color;
  final Object? padding;
  final Object? margin;

  final Object? width;
  final Object? height;

  final Object? alignment;
  final Object? decoration;

  const UltraReactiveBox({
    super.key,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.decoration,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UltraReactiveBoxRender(
      color,
      padding,
      margin,
      width,
      height,
      alignment,
      decoration,
      Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context,
      covariant _UltraReactiveBoxRender r,
      ) {
    r.updateProps(
      color,
      padding,
      margin,
      width,
      height,
      alignment,
      decoration,
      Directionality.of(context),
    );
  }
}


class _UltraReactiveBoxRender extends RenderShiftedBox
    with UltraReactiveRenderMixin {
  Color? _color;
  EdgeInsets? _padding;
  EdgeInsets? _margin;
  double? _width;
  double? _height;
  AlignmentGeometry? _alignment;
  BoxDecoration? _decoration;
  TextDirection textDirection;

  _UltraReactiveBoxRender(
      Object? color,
      Object? padding,
      Object? margin,
      Object? width,
      Object? height,
      Object? alignment,
      Object? decoration,
      this.textDirection,
      ) : super(null) {
    bindColor(color);
    bindPadding(padding);
    bindMargin(margin);
    bindWidth(width);
    bindHeight(height);
    bindAlignment(alignment);
    bindDecoration(decoration);
  }

  void updateProps(
      Object? color,
      Object? padding,
      Object? margin,
      Object? width,
      Object? height,
      Object? alignment,
      Object? decoration,
      TextDirection td,
      ) {
    this.textDirection = td;

    bindColor(color);
    bindPadding(padding);
    bindMargin(margin);
    bindWidth(width);
    bindHeight(height);
    bindAlignment(alignment);
    bindDecoration(decoration);

    markNeedsLayout();
  }

  void bindColor(Object? c) =>
      bindSignal<Color>(c, (v) => _color = v, needsLayout: false);

  void bindPadding(Object? p) =>
      bindSignal<EdgeInsets>(p, (v) => _padding = v);

  void bindMargin(Object? m) =>
      bindSignal<EdgeInsets>(m, (v) => _margin = v);

  void bindWidth(Object? w) =>
      bindSignal<double>(w, (v) => _width = v);

  void bindHeight(Object? h) =>
      bindSignal<double>(h, (v) => _height = v);

  void bindAlignment(Object? a) =>
      bindSignal<AlignmentGeometry>(a, (v) => _alignment = v);

  void bindDecoration(Object? d) =>
      bindSignal<BoxDecoration>(d, (v) => _decoration = v);
}
