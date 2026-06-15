part of '../core/reactive_core.dart';

/*
import 'package:flutter/material.dart';
import 'benchmark/benchmark_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BenchmarkPage(),
    );
  }
}
* */
/*class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key});

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  final counter = signal(0);

  String result = "Run benchmark";

  Future<void> runSignalBenchmark() async {
    final r = await BenchmarkRunner.run("10k signal updates", () {
      for (int i = 0; i < 10000; i++) {
        counter.value = i;
      }
    });

    setState(() {
      result = "${r.name}: ${r.microseconds} µs";
    });
  }

  Future<void> runSetStateBenchmark() async {
    int value = 0;

    final r = await BenchmarkRunner.run("10k setState updates", () async {
      for (int i = 0; i < 10000; i++) {
        value = i;
      }
    });

    setState(() {
      result = "${r.name}: ${r.microseconds} µs";
    });
  }

  Future<void> runListBenchmark() async {
    final list = List.generate(10000, (i) => i);

    final r = await BenchmarkRunner.run("10k list mutation", () {
      for (int i = 0; i < list.length; i++) {
        list[i] = list[i] + 1;
      }
    });

    setState(() {
      result = "${r.name}: ${r.microseconds} µs";
    });
  }

  Future<void> runAsyncBenchmark() async {
    final r = await BenchmarkRunner.run("async 1000 microtasks", () async {
      for (int i = 0; i < 1000; i++) {
        await Future.microtask(() {});
      }
    });

    setState(() {
      result = "${r.name}: ${r.microseconds} µs";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reactive Engine Benchmark")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(onPressed: runSignalBenchmark, child: const Text("Signal Benchmark (10k updates)")),
            ElevatedButton(onPressed: runSetStateBenchmark, child: const Text("setState Benchmark (10k updates)")),
            ElevatedButton(onPressed: runListBenchmark, child: const Text("List Stress Test")),
            ElevatedButton(onPressed: runAsyncBenchmark, child: const Text("Async Scheduler Test")),
            const SizedBox(height: 40),
            Text(result, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}*/
