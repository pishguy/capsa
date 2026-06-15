import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../core/reactive_core.dart';
import '../core/reactive_scope.dart';

class XReactive extends StatefulWidget {
  final Widget Function() builder;

  const XReactive(this.builder, {super.key});

  @override
  State<XReactive> createState() => _XReactiveState();
}

class _XReactiveState extends State<XReactive> {
  late final ReactiveScope _scope;

  Effect? _effect;

  bool _scheduled = false;

  @override
  void initState() {
    super.initState();

    _scope = ReactiveScope();

    _effect = effect(
      () {
        widget.builder();
        if (_scheduled) return;

        _scheduled = true;

        SchedulerBinding.instance.scheduleFrameCallback((_) {
          if (!mounted) return;

          setState(() {});

          _scheduled = false;
        });
      },
      scope: _scope,
    );
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }
}
