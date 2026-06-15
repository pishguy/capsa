<table>
<tr>
<td width="50%"><img src="https://raw.githubusercontent.com/pishguy/capsa/main/screenshot.png" width="300" alt="Capsa"></td>
<td width="50%" valign="middle">

## Capsa

**Capsa** is a reactive state management library for Flutter, inspired by SolidJS. It provides fine-grained reactivity with Signals, Computed values, Effects, and a rich set of reactive widgets — all without the boilerplate of ChangeNotifier, BLoC, or Riverpod.

</td>
</tr>
</table>

<div align="center">
  <strong>English</strong> | <a href="README.fa.md">فارسی</a> | <a href="README.az.md">Azərbaycanca</a>
</div>

---

> **⚠️ Alpha Notice:** Capsa is under active development. The API may change. Not recommended for production use.

## Features

- **Fine-grained Reactivity** — `Signal<T>` / `Computed<T>` / `Effect` with push-based propagation, glitch-free, lazy evaluation
- **Batching** — `batch()` groups multiple signal writes into a single notification
- **ReactiveList** — Observable `List<T>` backed by a version signal; works with `UltraFor`
- **Reactive Widgets** — `XReactive`, `UltraBuilder`, `UltraObserver` rebuild only when tracked signals change
- **X Helper API** — `X.text`, `X.show`, `X.opacity`, `X.container`, `X.button`, `X.transition` — declarative reactive helpers
- **Async Resources** — `CapsaResource<T>` with reactive loading/error/data states & `XSuspense` widget
- **MVVM Architecture** — `ScreenModel`, `Business`, `Repository`, `Datasource` with lifecycle management
- **Dependency Injection** — `UltraDI` with scoped singletons, factories, async singletons, and circular dependency detection
- **Animated Transitions** — `XTransition` drives widget animations directly from a `Signal<double>`
- **Low-level Render Widgets** — `UltraReactiveBox`, `UltraReactiveFlex`, `UltraReactiveStack`, `ReactiveText` — reactive at the render-object level
- **Reactive Collections** — `UltraFor`, `UltraGrid`, `UltraWrap`, `UltraCollection` render `ReactiveList` data
- **Code Generator** — `@Capsa(path)` annotation generates capsule wiring and feature scaffolding
- **Logging & DevTools** — `CapsaLogger` with categories & ring buffer; reactive graph inspector for leak detection
- **Router Integration** — `ReactiveRouteObserver` exposes the current route as a `Signal`

---

## Getting Started

### Add dependency

```yaml
dependencies:
  capsa: ^1.0.0
```

### Import

```dart
import 'package:capsa/capsa.dart';
```

---

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:capsa/capsa.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CounterScreen());
  }
}

class CounterScreen extends StatelessWidget {
  // A reactive signal — reading triggers tracking, writing notifies dependents
  final count = Signal(0);
  // A derived value — auto-updates when its dependencies change
  late final doubled = Computed(() => count() * 2);

  CounterScreen() {
    // Effects run automatically and re-run when tracked signals change
    effect(() {
      CapsaLogger.info(CapsaLogCategory.effect, 'Count is now ${count()}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capsa Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // XReactive rebuilds only when the signals it reads change
            XReactive(() => Text('Count: ${count()}')),
            XReactive(() => Text('Doubled: ${doubled()}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => count.value = count() + 1,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Core Concepts

### Signal

```dart
final name = Signal('Alice');
print(name());     // Read + track → 'Alice'
name.value = 'Bob'; // Write → notifies dependents
```

### Computed

```dart
final first = Signal('John');
final last = Signal('Doe');
final full = Computed(() => '${first()} ${last()}');

print(full()); // 'John Doe'
last.value = 'Smith';
print(full()); // 'John Smith' — auto-recomputed
```

### Effect

```dart
effect(() {
  print('Name changed to ${name()}'); // re-runs whenever name changes
}, debugLabel: 'nameWatcher');

// Dispose manually if not using a ReactiveScope:
final fx = effect(() { ... });
fx.dispose();
```

### Batch

```dart
ReactiveScheduler.batch(() {
  first.value = 'Jane';
  last.value = 'Doe';  // only one notification after the batch
});
```

---

## Reactive Widgets

### XReactive

Rebuilds when any signal read inside the builder changes:

```dart
XReactive(
  () => Column(
    children: [
      Text('Name: ${user.name()}'),
      Text('Age: ${user.age()}'),
    ],
  ),
)
```

### UltraBuilder

Same concept, passes `BuildContext`:

```dart
UltraBuilder(
  builder: (ctx) {
    final user = model.user();
    return Text('Hello, ${user.name}');
  },
)
```

### UltraObserver

Runs a builder and rebuilds when tracked signals change. Useful for fine-grained parts of the tree:

```dart
UltraObserver(
  builder: (_) {
    final hasError = model.error() != null;
    return hasError ? const Icon(Icons.warning) : const SizedBox.shrink();
  },
)
```

### XSuspense

Handles the loading → ready → error lifecycle of a `CapsaResource`:

```dart
XSuspense<Map<String, int>>(
  resource: statsResource,
  fallback: const CircularProgressIndicator(),
  onError: (err, _) => TextButton(
    onPressed: reload,
    child: Text('Retry ($err)'),
  ),
  builder: (ctx, stats) => Text('Total: ${stats['total']}'),
)
```

### XTransition

Animates a widget based on a `Signal<double>`:

```dart
XTransition(
  value: headerOpacity,
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeInOut,
  builder: (ctx, opacity) => Opacity(
    opacity: opacity,
    child: Container(color: Colors.blue, height: 100),
  ),
)
```

### UltraFor

Renders a `ReactiveList` as a `SliverList`:

```dart
CustomScrollView(
  slivers: [
    UltraFor<UserModel>(
      list: state.users,
      builder: (user, index) => ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    ),
  ],
)
```

---

## X Helper API

Convenient declarative wrappers for common widget patterns:

```dart
X.text(nameSignal)                          // Reactive Text widget
X.show(visibleSignal, child)                // Conditional visibility
X.opacity(opacitySignal, child)             // Reactive opacity
X.container(color: colorSignal, child: ...) // Reactive container
X.button(child: ..., onTap: handleTap)      // Reactive button
X.transition(value: signal, builder: ...)   // Reactive transition
```

---

## ReactiveList

An observable list that integrates with `UltraFor`:

```dart
final items = ReactiveList<String>();

items.add('apple');
items.addAll(['banana', 'cherry']);
items.removeAt(0);
items[0] = 'blueberry';
items.batch((list) {
  list.add('one');
  list.add('two'); // single notification
});
```

Read the current value (tracks dependency):

```dart
XReactive(() => Text('Count: ${items.length}'));
XReactive(() => Text('Items: ${items.value.join(', ')}'));
```

---

## Async Resources

```dart
final resource = CapsaResource(() => fetchApiData());

// Reactive state
print(resource.status());   // ResourceStatus.loading / .ready / .error
print(resource.data());     // T? — the result when ready
print(resource.error());    // Object? — the error if failed

// Retry
await resource.reload();
```

---

## MVVM Pattern

```dart
// Business layer
class MyBusiness extends Business {
  Future<List<User>> loadUsers() async { ... }
}

// Screen model
class MyScreenModel extends ScreenModel {
  final state = MyState();
  final MyBusiness business;

  MyScreenModel({required this.business});

  @override
  void onInit() {
    loadData();
    track(effect(() { ... }, scope: this));
  }

  Future<void> loadData() async { ... }
}

// Screen
class MyScreen extends RearchConsumer {
  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final model = use(myScreenModelCapsule);
    return XReactive(() => Text(model.state.name()));
  }
}
```

---

## Dependency Injection (UltraDI)

```dart
final di = UltraDI();

di.registerSingleton<ApiClient>(ApiClient());
di.registerFactory<Repository>((d) => Repository(d.get<ApiClient>()));
di.registerLazySingleton<Service>((d) => Service(d.get<Repository>()));

final service = di.get<Service>();
```

Scoped DI:

```dart
di.pushScope();  // new child scope
di.registerFactory<ScreenModel>(...); // scoped
di.popScope();   // disposed with scope
```

---

## Code Generator

```dart
@Capsa(path: 'lib/screen/profile')
class Profile {}
```

Running the builder generates capsule wiring and feature scaffolding (`view/`, `screen_model/`, `business/`, `repository/`, `datasource/`, `state/`, `model/`).

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      Presentation                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ XReactive│  │UltraFor  │  │ XSuspense/XTransition│  │
│  └────┬─────┘  └────┬─────┘  └──────────┬───────────┘  │
│       │              │                   │              │
│  ┌────▼──────────────▼───────────────────▼───────────┐  │
│  │               Reactive Widgets                     │  │
│  └───────────────────────┬───────────────────────────┘  │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐  │
│  │              ScreenModel (MVVM)                    │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │  │
│  │  │  State   │ │ Business │ │  CapsaResource   │   │  │
│  │  └──────────┘ └────┬─────┘ └──────────────────┘   │  │
│  └───────────────────────┬───────────────────────────┘  │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐  │
│  │              Core Reactive Engine                   │  │
│  │  ┌──────┐ ┌────────┐ ┌────────┐ ┌──────────────┐  │  │
│  │  │Signal│ │Computed│ │ Effect │ │ ReactiveList │  │  │
│  │  └──────┘ └────────┘ └────────┘ └──────────────┘  │  │
│  │  ┌─────────────────────────────────────────────┐   │  │
│  │  │   Scheduler (batch, priority queue, flush)   │   │  │
│  │  └─────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────┘  │
│                          │                              │
│  ┌───────────────────────▼───────────────────────────┐  │
│  │              UltraDI Container                      │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │  │
│  │  │Singleton │ │ Factory  │ │    Scopes         │   │  │
│  │  └──────────┘ └──────────┘ └──────────────────┘   │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Additional Widgets

| Widget | Description |
|--------|-------------|
| `UltraGrid<T>` | Reactive grid layout backed by `ReactiveList` |
| `UltraWrap<T>` | Reactive wrap layout backed by `ReactiveList` |
| `UltraCollection<T>` | Auto-selects list/grid/wrap based on data size |
| `UltraReactiveListView<T>` | Reactive `ListView` backed by `Signal<List<T>>` |
| `UltraReactiveBox` | Render-object level container with reactive props |
| `UltraReactiveFlex` | Render-object level flex with reactive direction/gap |
| `UltraReactiveStack` | Render-object level stack with reactive alignment |
| `ReactiveText` | Render-object level text driven by `Signal<String>` |
| `UltraReactiveOpacity` | Render-object level opacity driven by `Signal<double>` |
| `UltraReactiveAnimatedBox` | Animated scale widget driven by a `Signal<double>` |

---

## License

MIT
