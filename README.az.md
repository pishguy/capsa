<table>
<tr>
<td width="50%"><img src="https://raw.githubusercontent.com/pishguy/capsa/main/screenshot.png" width="300" alt="Capsa"></td>
<td width="50%" valign="middle">

## Capsa

**Capsa** — SolidJS-dən ilhamlanan, Flutter üçün reaktiv state idarəetmə kitabxanası. Signal, Computed, Effect və zəngin reaktiv vidjetlərlə state idarəsini boilerplate-siz həll edir.

Capsa, capsule əsaslı asılılıq inyeksiyası və vidjet həyat dövrü idarəsi üçün **flutter_rearch** üzərində qurulub. `RearchConsumer`, `WidgetHandle` və `capsule()` birbaşa re-export edilib — sadəcə `import 'package:capsa/capsa.dart'` kifayətdir.

</td>
</tr>
</table>

<div align="center">
  <a href="README.md">English</a> | <a href="README.fa.md">فارسی</a> | <strong>Azərbaycanca</strong>
</div>

---

> **⚠️ Alpha Bildirişi:** Capsa aktiv inkişaf mərhələsindədir. API dəyişə bilər. Production mühiti üçün tövsiyə edilmir.

## Xüsusiyyətlər

- **Incə dənəli Reaktivlik** — `Signal<T>` / `Computed<T>` / `Effect` push-based yayılma, glitch-siz, tənbəl (lazy) qiymətləndirmə
- **Batching** — `batch()` çoxsaylı signal yazmalarını tək bildirişdə qruplaşdırır
- **ReactiveList** — `UltraFor` ilə işləyən müşahidə olunan `List<T>`
- **Reaktiv Vidjetlər** — `XReactive`, `UltraBuilder`, `UltraObserver` yalnız izlənilən signal dəyişəndə rebuild edir
- **X Helper API** — `X.text`, `X.show`, `X.opacity`, `X.container`, `X.button`, `X.transition` — bəyannaməli reaktiv helperlər
- **Async Resurslar** — `CapsaResource<T>` loading/error/data state-ləri və `XSuspense` vidjeti
- **MVVM Arxitekturası** — `ScreenModel`, `Business`, `Repository`, `Datasource` həyat dövrü idarəsi ilə
- **Dependency Injection** — `UltraDI` scoped singletonlar, fabriklər, async singletonlar və tsiklik asılılıq aşkarlanması ilə
- **Animasiya keçidləri** — `XTransition` vidjet animasiyasını birbaşa `Signal<double>`-dan idarə edir
- **Render Object Vidjetləri** — `UltraReactiveBox`, `UltraReactiveFlex`, `UltraReactiveStack`, `ReactiveText` — render object səviyyəsində reaktiv
- **Reaktiv Kolleksiyalar** — `UltraFor`, `UltraGrid`, `UltraWrap`, `UltraCollection` `ReactiveList` məlumatlarını göstərir
- **Kod Generatoru** — `@Capsa(path)` annotasiyası capsule wiring və feature scaffolding yaradır
- **Logging və DevTools** — `CapsaLogger` kateqoriyalar və ring buffer ilə; sızma aşkarlanması üçün reaktiv qraf müfəttişi
- **Router İnteqrasiyası** — `ReactiveRouteObserver` cari marşrutu `Signal` kimi təqdim edir

---

## Quraşdırma

```yaml
dependencies:
  capsa: ^1.0.0
```

`rearch` və `flutter_rearch` avtomatik əlavə olunur — ayrıca əlavə etməyə ehtiyac yoxdur.

```dart
import 'package:capsa/capsa.dart';
```

Hər şey tək importdan əlçatandır: `RearchConsumer`, `WidgetHandle`, `capsule()`, `Signal`, `Computed`, `XReactive`, `UltraFor` və bütün digər API-lər.

---

## Sürətli Başlanğıc

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

## Əsas Konseptlər

### Signal

```dart
final name = Signal('Alice');
print(name());        // Oxu + tracking → 'Alice'
name.value = 'Bob';   // Yaz → asılılıqlara bildiriş
```

### Computed

```dart
final first = Signal('John');
final last = Signal('Doe');
final full = Computed(() => '${first()} ${last()}');

print(full()); // 'John Doe'
last.value = 'Smith';
print(full()); // 'John Smith' — avtomatik yeniləndi
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
  last.value = 'Doe';  // batch-dən sonra yalnız bir bildiriş
});
```

---

## Reaktiv Vidjetlər

### XReactive

Builder içində oxunan signal dəyişəndə rebuild edir:

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

Eyni konsept, `BuildContext` ilə:

```dart
UltraBuilder(
  builder: (ctx) {
    final user = model.user();
    return Text('Hello, ${user.name}');
  },
)
```

### UltraObserver

Vidjet ağacının incə hissələri üçün:

```dart
UltraObserver(
  builder: (_) {
    final hasError = model.error() != null;
    return hasError ? const Icon(Icons.warning) : const SizedBox.shrink();
  },
)
```

### XSuspense

`CapsaResource`-un loading → ready → error həyat dövrünü idarə edir:

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

`Signal<double>` əsasında vidjet animasiyası:

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

`ReactiveList`-i `SliverList` kimi göstərir:

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

Ümumi vidjet nümunələri üçün bəyannaməli wrappers:

```dart
X.text(nameSignal)                          // Reaktiv Text
X.show(visibleSignal, child)                // Şərti görünürlük
X.opacity(opacitySignal, child)             // Reaktiv opacity
X.container(color: colorSignal, child: ...) // Reaktiv container
X.button(child: ..., onTap: handleTap)      // Reaktiv düymə
X.transition(value: signal, builder: ...)   // Reaktiv keçid
```

---

## ReactiveList

`UltraFor` ilə işləyən müşahidə olunan siyahı:

```dart
final items = ReactiveList<String>();

items.add('apple');
items.addAll(['banana', 'cherry']);
items.removeAt(0);
items[0] = 'blueberry';
items.batch((list) {
  list.add('one');
  list.add('two'); // tək bildiriş
});
```

Cari dəyəri oxumaq (asılılıq tracking):

```dart
XReactive(() => Text('Count: ${items.length}'));
XReactive(() => Text('Items: ${items.value.join(', ')}'));
```

---

## Async Resurslar

```dart
final resource = CapsaResource(() => fetchApiData());

print(resource.status());   // ResourceStatus.loading / .ready / .error
print(resource.data());     // T?
print(resource.error());    // Object?

await resource.reload();
```

---

## MVVM Pattern

Capsa, hər təbəqənin **rearch capsule** ilə naqilləşdiyi laylı MVVM arxitekturasını izləyir. `@Capsa` annotasiyası ([Kod Generatoru](#kod-generatoru) bölməsinə baxın) capsule naqilləmə kodunu avtomatik yaradır.

### Arxitektura təbəqələri

| Təbəqə | Baza sinif | Vəzifə |
|--------|------------|--------|
| **ScreenModel** | `ScreenModel` | View state, business orchestration, həyat dövrü |
| **Business** | `Business` | Use case-lər, validasiya, biznes məntiq |
| **Repository** | `Repository` | Data access abstraksiyası, keş strategiyası |
| **Datasource** | `Datasource` | Xam API/DB çağırışları, şəbəkə və ya lokal depolama |
| **State** | (sadə sinif) | Reaktiv sahələr (Signal, ReactiveList, Computed) |
| **View** | `RearchConsumer` | Capsule DI girişi olan Flutter vidjetləri |

```dart
// State — yalnız reaktiv sahələr
class MyState {
  final users = ReactiveList<UserModel>();
  final isLoading = Signal<bool>(true);
  late final userCount = Computed(() => users.length);
}

// Business — use case-lər
class MyBusiness extends Business {
  final Repository repository;
  MyBusiness({required this.repository});

  Future<List<User>> loadUsers() async { ... }
}

// ScreenModel — orchestrasiya, avtomatik təmizləmə üçün ReactiveScope-u genişləndirir
class MyScreenModel extends ScreenModel {
  final state = MyState();
  final MyBusiness business;

  MyScreenModel({required this.business});

  @override
  void onInit() {
    loadData();
    track(effect(() { ... }));
  }

  Future<void> loadData() async { ... }
}

// Screen — capsule-lara giriş üçün RearchConsumer istifadə edir
class MyScreen extends RearchConsumer {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetHandle use) {
    final model = use(myScreenModelCapsule);
    return XReactive(() => Text(model.state.userCount()));
  }
}
```

### Capsule naqilləmə (əl ilə)

```dart
final myDatasourceCapsule = capsule((_) => MyDatasource());
final myRepositoryCapsule = capsule((use) =>
    MyRepository(use(myDatasourceCapsule)));
final myBusinessCapsule = capsule((use) =>
    MyBusiness(repository: use(myRepositoryCapsule)));
final myScreenModelCapsule = capsule((use) =>
    MyScreenModel(business: use(myBusinessCapsule)));
```

`@Capsa` istifadə edərkən bu capsule-lar avtomatik yaranır — [Kod Generatoru](#kod-generatoru) bölməsinə baxın.

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
di.pushScope();
di.registerFactory<ScreenModel>(...);
di.popScope();
```

---

## Kod Generatoru

Capsa iki kod yaratma aləti təqdim edir:

| Alət | Məqsəd |
|------|--------|
| `@Capsa` annotasiyası + `build_runner` | `.capsa.dart` faylı — capsule naqilləmə kodunun yaradılması |
| `dart run capsa` CLI | Tam feature qovluq strukturunun şablon fayllarla yaradılması |

### @Capsa annotasiyası + build_runner

Annotasiyanı feature qovluğunuzdakı hər hansı sinifin üzərinə qoyun:

```dart
import 'package:capsa/capsa.dart';

@Capsa(path: 'lib/screen/profile')
class Profile {}
```

**Quraşdırma:** Layihənizə `build.yaml` əlavə edin:

```yaml
targets:
  $default:
    builders:
      capsa|feature_builder:
        enabled: true
```

**Generatoru işə salın:**

```bash
dart run build_runner build
```

**Yaradılan çıxış** — `profile.capsa.dart`:

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

Yaradılan capsule-lar ciddi təbəqələnməyə əməl edir:
`DatasourceCapsule` → `RepositoryCapsule` → `BusinessCapsule`

`ScreenModel` təyin etdikdə əl ilə əlavə edə bilərsiniz:

```dart
final profileScreenModelCapsule = capsule((use) {
  return ProfileScreenModel(business: use(profileBusinessCapsule));
});
```

Bu capsule-lar `RearchConsumer` ekranları tərəfindən istifadə olunur:

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

Tək bir əmrlə tam feature strukturu yaradın:

```bash
# Format: dart run capsa <feature-adı> <hədəf-yol>
dart run capsa profile lib/screen/profile

# Və ya qovluq adı feature adı ilə eynidirsə:
dart run capsa lib/screen/profile
```

**Yaradılan struktur:**

```
lib/screen/profile/
├── profile.dart                          # @Capsa annotasiyası + re-exportlar
├── profile.capsa.dart                    # yaradılan capsule naqilləmə (build_runner-dan sonra)
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

Hər şablon faylı doldurmağa hazır ilkin implementasiyaya malikdir.

---

## Arxitektura

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

## Əlavə Vidjetlər

| Vidjet | Təsvir |
|--------|--------|
| `UltraGrid<T>` | `ReactiveList` ilə işləyən reaktiv grid |
| `UltraWrap<T>` | `ReactiveList` ilə işləyən reaktiv wrap |
| `UltraCollection<T>` | Məlumat ölçüsünə görə avtomatik list/grid/wrap seçimi |
| `UltraReactiveListView<T>` | `Signal<List<T>>` ilə işləyən reaktiv `ListView` |
| `UltraReactiveBox` | Reaktiv xüsusiyyətlərlə render object container |
| `UltraReactiveFlex` | Reaktiv direction/gap ilə render object flex |
| `UltraReactiveStack` | Reaktiv alignment ilə render object stack |
| `ReactiveText` | `Signal<String>` ilə işləyən render object text |
| `UltraReactiveOpacity` | `Signal<double>` ilə işləyən render object opacity |
| `UltraReactiveAnimatedBox` | `Signal<double>` ilə işləyən animasiyalı scale |

---

## Lisenziya

MIT
