# Flutter Patterns — MVVM & Clean Architecture

Sample Flutter app that mirrors the Swift `mvvm_clean_arc` project. It shows
the same Task Manager feature implemented twice:

1. **MVVM** — View + ViewModel + Service over a shared store
2. **Clean Architecture** — Domain / Data / Presentation with use cases, repository, and DI

Both patterns are widely used in production Flutter apps. This sample keeps
them side by side so you can compare structure and trade-offs.

## Run

```bash
cd flutter
flutter pub get
flutter run
flutter test
```

## Structure

```
lib/
  app/                 Root navigation
  shared/              Shared models, store, and UI row
  mvvm/                MVVM example
  clean/
    domain/            Entities, repository contract, use cases
    data/              Data source + repository implementation
    presentation/      Mapper, ViewModel, View
    di/                Composition root
```

## Notes

- ViewModels use Flutter's built-in `ChangeNotifier` + `ListenableBuilder`
  (equivalent role to Swift's `ObservableObject` / `@Published`).
- Storage is an in-memory shared store (Swift sample uses SwiftData). Both
  demos share the same store so changes are visible across patterns.
- No third-party state-management packages on purpose: the goal is the pattern,
  not a specific library (Provider, Riverpod, Bloc, etc.).
