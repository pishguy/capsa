part of 'reactive_core.dart';

class UltraWatch extends StatefulWidget {
  final void Function() listener;

  final Widget child;

  const UltraWatch({
    super.key,
    required this.listener,
    required this.child,
  });

  @override
  State<UltraWatch> createState() => _UltraWatchState();
}

class _UltraWatchState extends State<UltraWatch> {
  Effect? _effect;

  late final ReactiveScope _scope;

  bool _scheduled = false;

  @override
  void initState() {
    super.initState();

    _scope = ReactiveScope();

    _effect = effect(() {
      if (!_scheduled) {
        _scheduled = true;

        SchedulerBinding.instance.scheduleFrameCallback((_) {
          widget.listener();

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
    return widget.child;
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }
}
