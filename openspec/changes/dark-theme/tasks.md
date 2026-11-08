### Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Design system: `VanepPalette` (light + dark), `VanepTypography(palette)`, `VanepTheme.dark()`, context extension | — | 3 |
| 2 | Migration of every widget to `context.palette` / `context.typography`, `onAction` split | 1 | 3 |
| 3 | `settings` module: domain, Hive data source, repository, use cases, cubit, DI | — | 1, 2 |
| 4 | Settings page, profile menu entry, `themeMode` at the app root, ARB | 2, 3 | — |

> Delivered on one branch (`VAN-79/dark-theme`) for manual testing first, at the developer's request. R27a: no commit before the developer validates on a device.

## Phase 1 — design system

- [x] 1.1 Tests: light palette keeps the previous values; dark palette differs; `lerp`; typography colors follow the palette; `VanepTheme.dark()` brightness and extension
- [x] 1.2 `VanepPalette` `ThemeExtension` with `light` and `dark`
- [x] 1.3 `VanepTypography` built from a palette
- [x] 1.4 `VanepTheme.light()` / `dark()` from one builder; `context.palette` / `context.typography`
- [x] 1.5 `VanepColors` keeps only brand tokens

## Phase 2 — migration

- [x] 2.1 Replace semantic `VanepColors.*` and `VanepTypography.*` call sites
- [x] 2.2 Context-free helpers and painters receive the palette
- [x] 2.3 Foregrounds on colored fills move from `card` to `onAction`
- [x] 2.4 Update affected tests

## Phase 3 — settings module

- [x] 3.1 Tests: data source (missing / unknown / stored), repository, use cases, cubit, container
- [x] 3.2 `ThemePreference`, repository contract, use cases
- [x] 3.3 `SettingsLocalDataSource` (Hive), repository impl, `settings_container.dart`
- [x] 3.4 `ThemePreferenceCubit`, `themeModeFor`

## Phase 4 — settings page

- [x] 4.1 Tests: settings page selects and dispatches; menu entry enabled; drawer opens settings
- [x] 4.2 `SettingsPage` with Appearance section (`VanepSegmentedControl`)
- [x] 4.3 Enable `ProfileMenuId.settings`, `openSettings` callback from the shell
- [x] 4.4 Root `BlocProvider` + `themeMode` / `darkTheme`; preload preference in `main()`
- [x] 4.5 ARB pt + en, `make translate`
- [x] 4.6 `make lint` and `make test`
- [x] 4.7 Developer validates on device (R27a)
