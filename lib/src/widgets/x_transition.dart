import 'package:flutter/widgets.dart';

import '../core/reactive_core.dart';
import 'x_reactive.dart';
import 'x_transition_widget.dart';

class XTransition extends StatelessWidget {
  final Signal<double> value;
  final Curve curve;
  final Duration duration;
  final Widget Function(BuildContext context, double value) builder;

  const XTransition({
    super.key,
    required this.value,
    required this.builder,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return XReactive(() {
      final v = value();

      return XTransitionWidget(value: v, duration: duration, curve: curve, builder: builder);
    });
  }
}
