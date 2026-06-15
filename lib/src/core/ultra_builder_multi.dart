part of 'reactive_core.dart';

class UltraBuilderMulti extends StatefulWidget {
  final List<Reactive> signals;

  final Widget Function(BuildContext context, List<Reactive> values) builder;

  const UltraBuilderMulti({
    super.key,
    required this.signals,
    required this.builder,
  });

  @override
  State<UltraBuilderMulti> createState() => _UltraBuilderMultiState();
}

class _UltraBuilderMultiState extends State<UltraBuilderMulti> {
  late final Effect _effect;

  late final ReactiveScope _scope;

  List<Reactive> _values = [];

  @override
  void initState() {
    super.initState();

    _scope = ReactiveScope();

    _effect = effect(() {
      // BUGFIX: `s` (the Reactive itself) was being collected without ever
      // calling `.read()`/`s()` on it, so no dependency was ever
      // registered with this effect's node — the widget never rebuilt
      // when any of `widget.signals` changed. We now read each value to
      // register it as a dependency.
      _values = widget.signals.map((s) {
        s.read();
        return s;
      }).toList();

      CapsaLogger.verbose(
        CapsaLogCategory.widget,
        'UltraBuilderMulti effect ran (${widget.signals.length} signal(s))',
      );

      if (mounted) {
        setState(() {});
      }
    }, scope: _scope, debugLabel: 'UltraBuilderMulti');
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _values);
  }
}
