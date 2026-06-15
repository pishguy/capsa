class ReactiveDebug {

  static bool enabled = false;

  static void log(String message) {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Reactive] $message');
  }

}
