import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';

class UltraReactiveOpacity extends SingleChildRenderObjectWidget {
  final Signal<double> value;

  const UltraReactiveOpacity({
    super.key,
    required this.value,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _UltraOpacityRenderObject(value);
  }
}

class _UltraOpacityRenderObject extends RenderProxyBox {
  Signal<double> signal;
  double opacity = 1;

  _UltraOpacityRenderObject(this.signal) {
    opacity = signal();
    signal.subscribeCallback(_listener);
  }

  void _listener(double v) {
    if (v != opacity) {
      opacity = v;
      markNeedsPaint();
    }
  }

  @override
  void detach() {
    signal.unsubscribeCallback(_listener);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushOpacity(offset, (opacity * 255).toInt(), super.paint);
  }
}
