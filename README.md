<table>
<tr>
<td width="50%"><img src="https://raw.githubusercontent.com/pishguy/capsa/main/screenshot.png" width="300" alt="Capsa"></td>
<td width="50%" valign="middle">

## Capsa

**Capsa** is a reactive state management library for Flutter, inspired by SolidJS. It provides fine-grained reactivity with Signals, Computed values, Effects, and a rich set of reactive widgets — all without the boilerplate of ChangeNotifier, BLoC, or Riverpod.

Capsa builds on top of **flutter_rearch** for capsule-based dependency injection and widget lifecycle management. `RearchConsumer`, `WidgetHandle`, and `capsule()` are re-exported directly — you only need `import 'package:capsa/capsa.dart'`.

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

`rearch` and `flutter_rearch` are included automatically — no need to add them separately.

### Import

```dart
import 'package:capsa/capsa.dart';
```

Everything is available from a single import: `RearchConsumer`, `WidgetHandle`, `capsule()`, `Signal`, `Computed`, `XReactive`, `UltraFor`, and all other APIs.

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

Capsa follows a layered MVVM architecture where each layer is wired via **rearch capsules**. The `@Capsa` annotation (see [Code Generator](#code-generator)) generates capsule wiring code automatically.

### Architecture layers

| Layer | Base class | Responsibility |
|-------|-----------|----------------|
| **ScreenModel** | `ScreenModel` | View state, business orchestration, lifecycle |
| **Business** | `Business` | Use cases, validation, business logic |
| **Repository** | `Repository` | Data access abstraction, caching strategy |
| **Datasource** | `Datasource` | Raw API/DB calls, network or local storage |
| **State** | (plain class) | Reactive fields (Signal, ReactiveList, Computed) |
| **View** | `RearchConsumer` | Flutter widgets with capsule DI access |

```dart
// State — reactive fields only
class MyState {
  final users = ReactiveList<UserModel>();
  final isLoading = Signal<bool>(true);
  late final userCount = Computed(() => users.length);
}

// Business — use cases
class MyBusiness extends Business {
  final Repository repository;
  MyBusiness({required this.repository});

  Future<List<User>> loadUsers() async { ... }
}

// ScreenModel — orchestrator, extends ReactiveScope for auto-disposal
class MyScreenModel extends ScreenModel {
  final state = MyState();
  final MyBusiness business;

  MyScreenModel({required this.business});

  @override
  void onInit() {
    loadData();
    // auto-disposed when ScreenModel is disposed
    track(effect(() { ... }));
  }

  Future<void> loadData() async { ... }
}

// Screen — uses RearchConsumer to access capsules
class MyScreen extends RearchConsumer {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final model = use(myScreenModelCapsule);
    return XReactive(() => Text(model.state.userCount()));
  }
}
```

### Capsule wiring (hand-written)

```dart
final myDatasourceCapsule = capsule((_) => MyDatasource());
final myRepositoryCapsule = capsule((use) =>
    MyRepository(use(myDatasourceCapsule)));
final myBusinessCapsule = capsule((use) =>
    MyBusiness(repository: use(myRepositoryCapsule)));
final myScreenModelCapsule = capsule((use) =>
    MyScreenModel(business: use(myBusinessCapsule)));
```

When using `@Capsa`, these capsules are generated automatically — see the [Code Generator](#code-generator) section below.

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

Capsa provides two code generation tools:

| Tool | Purpose |
|------|---------|
| `@Capsa` annotation + `build_runner` | Generates `.capsa.dart` capsule wiring files |
| `dart run capsa` CLI | Scaffolds a full feature folder structure with template files |

### @Capsa annotation + build_runner

Place the annotation on any class inside your feature folder:

```dart
import 'package:capsa/capsa.dart';

@Capsa(path: 'lib/screen/profile')
class Profile {}
```

**Setup:** Add to your project's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      capsa|feature_builder:
        enabled: true
```

**Run the generator:**

```bash
dart run build_runner build
```

**What it generates** — `profile.capsa.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:rearch/rearch.dart';
import 'business/profile_business.dart';
import 'repository/profile_repository.dart';
import 'datasource/profile_datasource.dart';

final profileBusinessCapsule = capsule((use) {
  return ProfileBusiness(repository: use(profileRepositoryCapsule));
});

final profileRepositoryCapsule = capsule((use) {
  return ProfileRepository(use(profileDatasourceCapsule));
});

final profileDatasourceCapsule = capsule((use) {
  return ProfileDatasource();
});
```

The generated capsules follow a strict layering:
`DatasourceCapsule` → `RepositoryCapsule` → `BusinessCapsule`

When you also define a `ScreenModel` and register it in the feature file, you can add:

```dart
final profileScreenModelCapsule = capsule((use) {
  return ProfileScreenModel(business: use(profileBusinessCapsule));
});
```

These capsules are consumed by `RearchConsumer` screens:

```dart
class ProfileScreen extends RearchConsumer {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final model = use(profileScreenModelCapsule);
    return XReactive(() => Text(model.state.userCount()));
  }
}
```

### CLI feature scaffolder

Scaffold a complete feature folder with a single command:

```bash
# Format: dart run capsa <feature-name> <target-path>
dart run capsa profile lib/screen/profile

# Or when the folder name matches the feature:
dart run capsa lib/screen/profile
```

**Creates the following structure:**

```
lib/screen/profile/
├── profile.dart                          # @Capsa annotation + re-exports
├── profile.capsa.dart                    # generated capsule wiring (after build_runner)
├── business/
│   └── profile_business.dart
├── repository/
│   └── profile_repository.dart
├── datasource/
│   └── profile_datasource.dart
├── model/
│   └── profile_model.dart
├── state/
│   └── profile_state.dart
├── screen_model/
│   └── profile_screen_model.dart
└── view/
    └── profile_screen.dart
```

Each template file has a minimal starting implementation ready for you to fill in.

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
