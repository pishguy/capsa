import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';

class ReactiveText extends LeafRenderObjectWidget {

  final Signal<String> signal;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection textDirection;

  const ReactiveText(
      this.signal,{
        super.key,
        this.style,
        this.textAlign = TextAlign.start,
        this.textDirection = TextDirection.ltr,
      });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UltraTextRenderObject(
      signal,
      style,
      textAlign,
      textDirection,
    );
  }

}

class _UltraTextRenderObject extends RenderBox
    with RenderObjectWithChildMixin<RenderParagraph> {

  Signal<String> signal;
  TextStyle? style;
  TextAlign textAlign;
  TextDirection direction;

  _UltraTextRenderObject(
      this.signal,
      this.style,
      this.textAlign,
      this.direction,
      ) {
    signal.subscribeCallback(_listener);
    _setup();
  }

  void _setup() {
    child = RenderParagraph(
      TextSpan(text: signal(), style: style),
      textAlign: textAlign,
      textDirection: direction,
    );
  }

  void _listener(String newValue) {
    final rp = child!;
    rp.text = TextSpan(text: newValue, style: style);
    markNeedsLayout();
  }

  @override
  void detach() {
    signal.unsubscribeCallback(_listener);
    super.detach();
  }

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    child!.paint(context, offset);
  }
}
