import 'dart:collection';

/// -----------------------------------------------------------------------
/// Capsa Advanced Logging System
/// -----------------------------------------------------------------------
///
/// A lightweight, zero-dependency logger that gives visibility into
/// everything happening inside the reactive system, the scheduler,
/// dependency injection and the MVVM layer.
///
/// Usage:
/// ```dart
/// CapsaLogger.enable(); // turn logging on (off by default in release)
/// CapsaLogger.level = CapsaLogLevel.debug;
/// CapsaLogger.categories = {CapsaLogCategory.signal, CapsaLogCategory.effect};
/// ```
///
/// All log records are also kept in an in-memory ring buffer
/// (`CapsaLogger.history`) so you can inspect/print them at any time,
/// e.g. inside a debug overlay or `CapsaLogger.printSummary()`.

/// Severity levels, ordered from most to least verbose.
enum CapsaLogLevel {
  verbose,
  debug,
  info,
  warn,
  error,
  none, // disables all logging
}

extension on CapsaLogLevel {
  int get _priority => index;
}

/// Logical subsystems that can be enabled/disabled independently.
enum CapsaLogCategory {
  signal,
  computed,
  effect,
  scheduler,
  di,
  mvvm,
  widget,
}

/// A single captured log entry.
class CapsaLogRecord {
  final DateTime time;
  final CapsaLogCategory category;
  final CapsaLogLevel level;
  final String message;
  final Object? data;

  CapsaLogRecord({
    required this.time,
    required this.category,
    required this.level,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    final cat = category.name.toUpperCase().padRight(9);
    final lvl = level.name.toUpperCase().padRight(7);
    final ts =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';

    final suffix = data != null ? ' | $data' : '';
    return '[$ts] $lvl $cat $message$suffix';
  }
}

/// Central logging facility used across the whole Capsa library.
class CapsaLogger {
  CapsaLogger._();

  /// Master on/off switch. Logging is OFF by default so it never affects
  /// production performance unless explicitly enabled.
  static bool enabled = false;

  /// Minimum level that will be processed.
  static CapsaLogLevel level = CapsaLogLevel.info;

  /// Categories that are allowed to log. Defaults to "all".
  static Set<CapsaLogCategory> categories = {
    CapsaLogCategory.signal,
    CapsaLogCategory.computed,
    CapsaLogCategory.effect,
    CapsaLogCategory.scheduler,
    CapsaLogCategory.di,
    CapsaLogCategory.mvvm,
    CapsaLogCategory.widget,
  };

  /// Optional custom sink (e.g. to forward logs to Sentry, a file,
  /// or a custom in-app console). If null, [print] is used.
  static void Function(CapsaLogRecord record)? sink;

  /// In-memory ring buffer of recent log records, useful for debug
  /// overlays / `CapsaLogger.history`.
  static int maxHistory = 1000;

  static final Queue<CapsaLogRecord> _history = Queue();

  static UnmodifiableListView<CapsaLogRecord> get history =>
      UnmodifiableListView(_history);

  /// Auto-incrementing ids, used so log lines can refer to a specific
  /// Signal/Computed/Effect instance even without a debugLabel.
  static int _nextId = 0;

  static int nextId() => _nextId++;

  // ---------------------------------------------------------------------
  // Configuration helpers
  // ---------------------------------------------------------------------

  /// Enable logging. Optionally restrict to a set of categories and/or
  /// set a minimum level in one call.
  static void enable({
    CapsaLogLevel level = CapsaLogLevel.debug,
    Set<CapsaLogCategory>? categories,
  }) {
    enabled = true;
    CapsaLogger.level = level;
    if (categories != null) CapsaLogger.categories = categories;
  }

  static void disable() => enabled = false;

  static void clearHistory() => _history.clear();

  // ---------------------------------------------------------------------
  // Core log function
  // ---------------------------------------------------------------------

  static void log(
    CapsaLogCategory category,
    CapsaLogLevel level,
    String message, {
    Object? data,
  }) {
    if (!enabled) return;
    if (level._priority < CapsaLogger.level._priority) return;
    if (!categories.contains(category)) return;

    final record = CapsaLogRecord(
      time: DateTime.now(),
      category: category,
      level: level,
      message: message,
      data: data,
    );

    _history.add(record);
    while (_history.length > maxHistory) {
      _history.removeFirst();
    }

    if (sink != null) {
      sink!(record);
    } else {
      // ignore: avoid_print
      print(record);
    }
  }

  // Convenience helpers -----------------------------------------------

  static void verbose(CapsaLogCategory c, String m, {Object? data}) =>
      log(c, CapsaLogLevel.verbose, m, data: data);

  static void debug(CapsaLogCategory c, String m, {Object? data}) =>
      log(c, CapsaLogLevel.debug, m, data: data);

  static void info(CapsaLogCategory c, String m, {Object? data}) =>
      log(c, CapsaLogLevel.info, m, data: data);

  static void warn(CapsaLogCategory c, String m, {Object? data}) =>
      log(c, CapsaLogLevel.warn, m, data: data);

  static void error(CapsaLogCategory c, String m, {Object? data}) =>
      log(c, CapsaLogLevel.error, m, data: data);

  // ---------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------

  /// Prints a summary of how many log entries were captured per
  /// category/level - handy after running a test scenario.
  static void printSummary() {
    final byCategory = <CapsaLogCategory, int>{};
    final byLevel = <CapsaLogLevel, int>{};

    for (final r in _history) {
      byCategory[r.category] = (byCategory[r.category] ?? 0) + 1;
      byLevel[r.level] = (byLevel[r.level] ?? 0) + 1;
    }

    print('------ Capsa Log Summary (${_history.length} entries) ------');
    for (final c in CapsaLogCategory.values) {
      if (byCategory[c] != null) {
        print('  ${c.name.padRight(10)}: ${byCategory[c]}');
      }
    }
    print('  ----');
    for (final l in CapsaLogLevel.values) {
      if (byLevel[l] != null) {
        print('  ${l.name.padRight(10)}: ${byLevel[l]}');
      }
    }
    print('---------------------------------------------------------');
  }
}
