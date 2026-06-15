import 'dart:collection';
import 'package:flutter/scheduler.dart';

final Queue<VoidCallback> _queue = Queue();
bool _scheduled = false;

void scheduleEffect(VoidCallback fn) {

  _queue.add(fn);

  if (_scheduled) return;

  _scheduled = true;

  SchedulerBinding.instance.scheduleFrameCallback((_) {

    while (_queue.isNotEmpty) {
      final task = _queue.removeFirst();
      task();
    }

    _scheduled = false;

  });
}
