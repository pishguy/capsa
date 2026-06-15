import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../../core/reactive_core.dart';

class UltraReactiveAnimatedBox extends StatefulWidget {
  final Signal<double> value;
  final Duration duration;
  final Widget child;

  const UltraReactiveAnimatedBox({
    super.key,
    required this.value,
    required this.duration,
    required this.child,
  });

  @override
  State createState() => _UltraAnimState();
}

class _UltraAnimState extends State<UltraReactiveAnimatedBox>
    with SingleTickerProviderStateMixin {

  late Ticker ticker;

  double current = 0;
  double target = 0;

  @override
  void initState() {
    super.initState();

    current = widget.value();
    target = current;

    widget.value.subscribeCallback(_listener);

    ticker = createTicker(_tick);
  }

  void _listener(double v) {
    target = v;
    ticker.start();
  }

  void _tick(Duration d) {

    current += (target - current) * 0.15;

    if ((target - current).abs() < 0.001) {
      current = target;
      ticker.stop();
    }

    if (mounted) setState(() {});
  }


  @override
  void dispose() {
    widget.value.unsubscribeCallback(_listener);
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scale: current, child: widget.child);
  }
}
