<table>
<tr>
<td width="50%"><img src="https://raw.githubusercontent.com/pishguy/capsa/main/screenshot.png" width="300" alt="Capsa"></td>
<td width="50%" valign="middle">

## Capsa

**Capsa** یک کتابخانه مدیریت state واکنش‌گرا (Reactive) برای Flutter است که از SolidJS الهام گرفته. این کتابخانه با Signal‌ها، Computed‌ها، Effect‌ها و ویجت‌های واکنش‌گرای غنی، مدیریت state را بدون boilerplate تغییرمی‌دهد.

</td>
</tr>
</table>

<div align="center">
  <a href="README.md">English</a> | <strong>فارسی</strong> | <a href="README.az.md">Azərbaycanca</a>
</div>

---

> **⚠️ اطلاعیه Alpha:** Capsa در حال توسعه فعال است. API ممکن است تغییر کند. برای محیط Production توصیه نمی‌شود.

## ویژگی‌ها

- **Reactivitiy دقیق** — `Signal<T>` / `Computed<T>` / `Effect` با انتشار push-based، بدون glitch، ارزیابی تنبل (lazy)
- **Batching** — `batch()` چند نوشتن signal را در یک notification گروه‌بندی می‌کند
- **ReactiveList** — `List<T>` قابل مشاهده که با `UltraFor` کار می‌کند
- **ویجت‌های واکنش‌گرا** — `XReactive`، `UltraBuilder`، `UltraObserver` فقط در تغییر signalهای tracked rebuild می‌شوند
- **X Helper API** — `X.text`، `X.show`، `X.opacity`، `X.container`، `X.button`، `X.transition` — helperهای دستوری واکنش‌گرا
- **منابع Async** — `CapsaResource<T>` با state‌های loading/error/data و ویجت `XSuspense`
- **معماری MVVM** — `ScreenModel`، `Business`، `Repository`، `Datasource` با مدیریت چرخه حیات
- **تزریق وابستگی** — `UltraDI` با singleton‌های محدوده‌ای (scoped)، factory‌ها، async singleton‌ها و تشخیص وابستگی حلقوی
- **انیمیشن Transition** — `XTransition` انیمیشن ویجت را مستقیماً از `Signal<double>` دریافت می‌کند
- **ویجت‌های Render Object** — `UltraReactiveBox`، `UltraReactiveFlex`، `UltraReactiveStack`، `ReactiveText` — واکنش‌گرا در سطح render object
- **کالکشن‌های واکنش‌گرا** — `UltraFor`، `UltraGrid`، `UltraWrap`، `UltraCollection` داده `ReactiveList` را نمایش می‌دهند
- **تولید کد** — `@Capsa(path)` annotation برای تولید capsule wiring و scaffolding
- **لاگینگ و DevTools** — `CapsaLogger` با دسته‌بندی و ring buffer؛ بازرس گراف واکنش‌گرا برای تشخیص نشتی
- **یکپارچگی با Router** — `ReactiveRouteObserver` مسیر فعلی را به عنوان `Signal` در معرض نمایش می‌گذارد

---

## نصب

```yaml
dependencies:
  capsa: ^1.0.0
```

```dart
import 'package:capsa/capsa.dart';
```

---

## شروع سریع

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
  final count = Signal(0);
  late final doubled = Computed(() => count() * 2);

  CounterScreen() {
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

## مفاهیم اصلی

### Signal

```dart
final name = Signal('Alice');
print(name());        // خواندن + tracking ← 'Alice'
name.value = 'Bob';   // نوشتن ← اطلاع‌رسانی به وابسته‌ها
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
  print('Name changed to ${name()}');
}, debugLabel: 'nameWatcher');

final fx = effect(() { ... });
fx.dispose();
```

### Batch

```dart
ReactiveScheduler.batch(() {
  first.value = 'Jane';
  last.value = 'Doe';  // فقط یک notification بعد از batch
});
```

---

## ویجت‌های واکنش‌گرا

### XReactive

وقتی signal خوانده شده در builder تغییر کند، rebuild می‌کند:

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

مشابه XReactive با دسترسی به `BuildContext`:

```dart
UltraBuilder(
  builder: (ctx) {
    final user = model.user();
    return Text('Hello, ${user.name}');
  },
)
```

### UltraObserver

برای بخش‌های دقیق درخت ویجت:

```dart
UltraObserver(
  builder: (_) {
    final hasError = model.error() != null;
    return hasError ? const Icon(Icons.warning) : const SizedBox.shrink();
  },
)
```

### XSuspense

مدیریت چرخه حیات loading → ready → error یک `CapsaResource`:

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

انیمیشن ویجت بر اساس `Signal<double>`:

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

نمایش `ReactiveList` به صورت `SliverList`:

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

Wrapperهای دستوری برای الگوهای رایج ویجت:

```dart
X.text(nameSignal)                          // Text واکنش‌گرا
X.show(visibleSignal, child)                // visibility شرطی
X.opacity(opacitySignal, child)             // opacity واکنش‌گرا
X.container(color: colorSignal, child: ...) // container واکنش‌گرا
X.button(child: ..., onTap: handleTap)      // دکمه واکنش‌گرا
X.transition(value: signal, builder: ...)   // transition واکنش‌گرا
```

---

## ReactiveList

یک لیست قابل مشاهده که با `UltraFor` یکپارچه است:

```dart
final items = ReactiveList<String>();

items.add('apple');
items.addAll(['banana', 'cherry']);
items.removeAt(0);
items[0] = 'blueberry';
items.batch((list) {
  list.add('one');
  list.add('two'); // یک notification
});
```

خواندن مقدار فعلی (tracking وابستگی):

```dart
XReactive(() => Text('Count: ${items.length}'));
XReactive(() => Text('Items: ${items.value.join(', ')}'));
```

---

## منابع Async

```dart
final resource = CapsaResource(() => fetchApiData());

print(resource.status());   // ResourceStatus.loading / .ready / .error
print(resource.data());     // T?
print(resource.error());    // Object?

await resource.reload();
```

---

## معماری MVVM

```dart
class MyBusiness extends Business {
  Future<List<User>> loadUsers() async { ... }
}

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

class MyScreen extends RearchConsumer {
  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final model = use(myScreenModelCapsule);
    return XReactive(() => Text(model.state.name()));
  }
}
```

---

## تزریق وابستگی (UltraDI)

```dart
final di = UltraDI();

di.registerSingleton<ApiClient>(ApiClient());
di.registerFactory<Repository>((d) => Repository(d.get<ApiClient>()));
di.registerLazySingleton<Service>((d) => Service(d.get<Repository>()));

final service = di.get<Service>();
```

DI محدوده‌ای:

```dart
di.pushScope();
di.registerFactory<ScreenModel>(...);
di.popScope();
```

---

## تولید کد

```dart
@Capsa(path: 'lib/screen/profile')
class Profile {}
```

اجرای builder، capsule wiring و scaffolding features را تولید می‌کند.

---

## معماری

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

## ویجت‌های اضافی

| ویجت | توضیحات |
|-------|---------|
| `UltraGrid<T>` | گرید واکنش‌گرا با `ReactiveList` |
| `UltraWrap<T>` | wrap واکنش‌گرا با `ReactiveList` |
| `UltraCollection<T>` | انتخاب خودکار list/grid/wrap بر اساس اندازه داده |
| `UltraReactiveListView<T>` | `ListView` واکنش‌گرا با `Signal<List<T>>` |
| `UltraReactiveBox` | container با props واکنش‌گرا در سطح render object |
| `UltraReactiveFlex` | flex واکنش‌گرا با direction/gap در سطح render object |
| `UltraReactiveStack` | استک واکنش‌گرا با alignment در سطح render object |
| `ReactiveText` | متن واکنش‌گرا با `Signal<String>` در سطح render object |
| `UltraReactiveOpacity` | opacity واکنش‌گرا با `Signal<double>` |
| `UltraReactiveAnimatedBox` | انیمیشن scale با `Signal<double>` |

---

## مجوز

MIT
