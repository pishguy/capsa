import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import 'reactive_core.dart';
import 'reactive_scope.dart';

class UltraObserver extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const UltraObserver({super.key, required this.builder});

  @override
  State<UltraObserver> createState() => _UltraObserverState();
}

class _UltraObserverState extends State<UltraObserver> {
  Effect? _effect;

  late final ReactiveScope _scope;

  bool _scheduled = false;

  @override
  void initState() {
    super.initState();

    _scope = ReactiveScope();

    _effect = effect(() {
      widget.builder(context);
      if (!_scheduled) {
        _scheduled = true;

        SchedulerBinding.instance.scheduleFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }

          _scheduled = false;
        });
      }
    }, scope: _scope);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }
}
