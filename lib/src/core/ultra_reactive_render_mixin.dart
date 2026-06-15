
import 'package:flutter/material.dart';
import 'reactive_core.dart';

mixin UltraReactiveRenderMixin on RenderObject {
  final List<void Function()> _unbinders = [];

  void bindSignal<T>(
      Object? candidate,
      void Function(T?) onChange, {
        bool needsLayout = true,
      }) {
    if (candidate is Signal<T>) {
      // مقدار اولیه را با صدا زدن .call() می‌خوانیم
      onChange(candidate());

      void listener(T value) { // تغییر: listener یک آرگومان (مقدار جدید) دریافت می‌کند
        if (!attached) return;
        onChange(value); // تغییر: اکنون value جدید را مستقیماً پاس می‌دهیم
        if (needsLayout) {
          markNeedsLayout();
        } else {
          markNeedsPaint();
        }
      }

      candidate.subscribeCallback(listener); // نیاز به Type Cast

      _unbinders.add(() {
        candidate.unsubscribeCallback(listener);
      });
    } else {
      // اگر سیگنال نبود، مستقیماً مقدار را نگه دار
      onChange(candidate as T?);
    }
  }

  @override
  void dispose() {
    for (final u in _unbinders) u();
    _unbinders.clear();
    super.dispose();
  }
}
