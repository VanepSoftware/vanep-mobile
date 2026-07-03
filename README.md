# Vanep Mobile

Vanep Flutter mobile application.

---

## Requirements

- Flutter (pinned via `.fvmrc`)
- FVM (Flutter Version Manager)
- Android SDK + Android Studio (for Android)

---

## How to install

### Install fvm

```bash
dart pub global activate fvm
fvm install
```

`fvm install` uses the Flutter version pinned in `.fvmrc`.

---

### Setup the application

```bash
make install
```

### Run the app

```bash
fvm flutter run
```

---

## Available commands

Use the `Makefile` as the primary way to run Flutter tasks.

| Command | Description |
| --- | --- |
| `make install` | Clean + `flutter pub get` |
| `make clean` | `flutter clean` |
| `make pub_get` | `flutter pub get` |
| `make lint` | `flutter analyze --fatal-infos` |
| `make lint_fix` | `dart fix --apply` |
| `make test` | `flutter test` |
| `make coverage` | Test with coverage + enforce >= 85% threshold |
| `make coverage_open` | `make coverage` + open HTML report |

---

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every PR and push to `main`:

1. `flutter pub get`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. Enforce minimum coverage of 85%
