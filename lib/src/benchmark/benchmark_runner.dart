import 'dart:async';

class BenchmarkResult {
  final String name;
  final int microseconds;

  BenchmarkResult(this.name, this.microseconds);
}

class BenchmarkRunner {
  static Future<BenchmarkResult> run(
      String name,
      FutureOr<void> Function() task,
      ) async {
    final sw = Stopwatch()..start();

    await task();

    sw.stop();

    return BenchmarkResult(name, sw.elapsedMicroseconds);
  }
}
