part of 'reactive_core.dart';

class UltraBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const UltraBuilder({super.key, required this.builder});

  @override
  State<UltraBuilder> createState() => _UltraBuilderState();
}

class _UltraBuilderState extends State<UltraBuilder> {
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
          if (mounted) setState(() {});
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
