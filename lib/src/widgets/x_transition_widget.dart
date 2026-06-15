import 'package:flutter/widgets.dart';

class XTransitionWidget extends ImplicitlyAnimatedWidget {
  final double value;
  final Widget Function(BuildContext context, double value) builder;

  const XTransitionWidget({
    super.key,
    required this.value,
    required super.duration,
    required this.builder,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<XTransitionWidget> createState() => _XTransitionWidgetState();
}

class _XTransitionWidgetState extends AnimatedWidgetBaseState<XTransitionWidget> {
  Tween<double>? _valueTween;

  @override
  Widget build(BuildContext context) {
    final value = _valueTween?.evaluate(animation) ?? widget.value;

    return widget.builder(context, value);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween =
        visitor(_valueTween, widget.value, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;
  }
}
