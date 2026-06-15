import 'package:flutter/widgets.dart';

class UltraReactiveGestureDetector extends StatelessWidget {

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const UltraReactiveGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
