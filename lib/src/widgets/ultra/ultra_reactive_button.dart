import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';
import '../x_reactive.dart';

class UltraReactiveButton extends StatelessWidget {
  final VoidCallback onTap;
  final Signal<Color> color;
  final Widget child;

  const UltraReactiveButton({super.key, required this.onTap, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return XReactive(() {
      final c = color();

      return GestureDetector(
        onTap: onTap,
        child: Container(padding: const EdgeInsets.all(12), color: c, child: child),
      );
    });
  }
}
