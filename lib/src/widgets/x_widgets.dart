import 'package:flutter/material.dart';

import '../core/reactive_core.dart';
import 'x_reactive.dart';
import 'x_transition.dart';

class X {

  static Widget text(Signal<String> value,
      {Key? key, TextAlign? align, TextOverflow? overflow}) {
    return XReactive(() {
      return Text(
        value(),
        key: key,
        textAlign: align,
        overflow: overflow,
      );
    });
  }

  static Widget show(Signal<bool> visible, Widget child) {
    return XReactive(() => visible() ? child : const SizedBox.shrink());
  }

  static Widget opacity(Signal<double> opacity, Widget child,
      {Key? key, bool alwaysIncludeSemantics = false}) {
    return XReactive(() {
      return Opacity(
        key: key,
        opacity: opacity(),
        alwaysIncludeSemantics: alwaysIncludeSemantics,
        child: child,
      );
    });
  }

  static Widget container({
    Key? key,
    Signal<Color?>? color,
    Signal<EdgeInsetsGeometry?>? padding,
    Signal<EdgeInsetsGeometry?>? margin,
    Signal<AlignmentGeometry?>? alignment,
    required Widget child,
  }) {
    return XReactive(() {
      return Container(
        key: key,
        color: color?.call(),
        padding: padding?.call(),
        margin: margin?.call(),
        alignment: alignment?.call(),
        child: child,
      );
    });
  }

  static Widget button({
    Key? key,
    required Widget child,
    void Function()? onTap,
    void Function()? onLongPress,
    Signal<bool>? enabled,
  }) {
    return XReactive(() {
      final isEnabled = enabled?.call() ?? true;

      return GestureDetector(
        key: key,
        onTap: isEnabled ? onTap : null,
        onLongPress: isEnabled ? onLongPress : null,
        child: child,
      );
    });
  }

  static Widget transition({
    Key? key,
    required Signal<double> value,
    required Widget Function(BuildContext, double) builder,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    return XTransition(
      key: key,
      value: value,
      curve: curve,
      duration: duration,
      builder: builder,
    );
  }
}
