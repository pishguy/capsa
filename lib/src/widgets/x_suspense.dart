import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../async/resource.dart';
import '../core/reactive_core.dart' hide ResourceStatus, Resource;
import '../core/reactive_scope.dart';

typedef XSuspenseBuilder<T> = Widget Function(
    BuildContext context,
    T data,
    );

class XSuspense<T> extends StatefulWidget {
   final CapsaResource<T> resource;
  final XSuspenseBuilder<T> builder;
  final Widget? fallback;
  final Widget Function(Object error, StackTrace? stack)? onError;

  const XSuspense({
    super.key,
    required this.resource,
    required this.builder,
    this.fallback,
    this.onError,
  });

  @override
  State<XSuspense<T>> createState() => _XSuspenseState<T>();
}

class _XSuspenseState<T> extends State<XSuspense<T>> {
  late final ReactiveScope _scope;

  Effect? _effect;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();

    _scope = ReactiveScope();

    _effect = effect(
      () {
        widget.resource.status();
        widget.resource.error();
        widget.resource.data();
        if (!_scheduled) {
          _scheduled = true;
          SchedulerBinding.instance.scheduleFrameCallback((_) {
            if (!mounted) return;
            setState(() {});
            _scheduled = false;
          });
        }
      },
      scope: _scope,
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.resource;

    switch (res.status()) {
      case ResourceStatus.loading:
        return widget.fallback ?? const SizedBox.shrink();

      case ResourceStatus.error:
        final err = res.error();
        final st = res.stack();
        final onError = widget.onError;
        if (onError != null) return onError(err!, st);
        return Text('Error: $err', textAlign: TextAlign.center);

      case ResourceStatus.ready:
        final data = res.data();
        return (data != null)
            ? widget.builder(context, data)
            : widget.fallback ?? const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }
}
