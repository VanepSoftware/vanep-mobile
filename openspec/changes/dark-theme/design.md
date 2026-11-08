## Context

`VanepColors` holds ~55 `static const Color` tokens used ~600 times in ~120 files. `VanepTypography` holds `static const TextStyle`s with baked colors, used ~320 times. Many call sites sit inside `const` widget trees. `MaterialApp` only receives `theme: VanepTheme.light()`.

## Decisions

### D1. Palette as a `ThemeExtension`, read from `BuildContext`

`VanepPalette extends ThemeExtension<VanepPalette>` with one field per semantic token and two `const` values, `VanepPalette.light` and `VanepPalette.dark`. `lerp` interpolates every color so the `MaterialApp` theme animation also animates custom tokens.

Access: `extension VanepThemeContext on BuildContext` exposes `palette` and `typography`. When the extension is absent (widget tests that pump a bare `MaterialApp`) it falls back to `VanepPalette.light`, which is the current look.

Rejected: keeping `VanepColors.x` as static getters reading a global "current palette". It needs the same `const` removal, adds mutable global state, and widgets would not rebuild on theme change without a forced full rebuild.

### D2. Brand tokens stay in `VanepColors`

Tokens that never change with the theme stay `static const` in `VanepColors`: `brandNavyDeep`, `brandNavy`, `brandNavyBright`, `brandSheen`, `onBrand`, `brandMeter`, `successOnBrand`, `successDotOnBrand`, `ratingStar`, `van*`. Each token has exactly one owner (R06a): semantic tokens live only in the palette, brand tokens only in `VanepColors`.

### D3. Typography derives color from the palette

`VanepTypography` becomes an immutable class built from a `VanepPalette`. Each style is a getter. Sizes and weights are unchanged. `context.typography.cardTitle` replaces `VanepTypography.cardTitle`.

### D4. `onAction` token

`card` meant both "card surface" and "white foreground on a colored fill". These split: `card` is the surface; `onAction` (white in both themes) is the foreground on `action`, `danger` and other saturated fills.

### D4a. Other tokens found during the migration

- `raisedSurface`: the selected segment of `VanepSegmentedControl`. In light it is white (same as before); in dark it is lighter than the track, so the selection still reads as raised. `card` would look sunken.
- `shadow`: base color for shadows (`#0B2038` light, black dark). Shadows tinted with `textPrimary` would glow in dark mode.
- `successSurface`: replaces the hardcoded `0x1A1E8E5A` in the person avatar tones.
- `VanepColors.photoScrim` (brand, constant): dark scrim over photos (cover background, upload overlay). It used `textPrimary`, which turns light in dark mode.
- `context.surfaceOverlayStyle`: status bar icon brightness derived from the theme, for screens that set it explicitly (login).

### D5. Theme preference lives in a `settings` module

- Domain: `enum ThemePreference { system, light, dark }`, `ThemePreferenceRepository` contract, use cases `GetThemePreference` and `ChangeThemePreference`. No Flutter import.
- Data: `SettingsLocalDataSource` over a Hive box `settings`, key `theme_preference`, stored as the enum name. Unknown or missing value → `system`.
- Presentation: `ThemePreferenceCubit` (state = `ThemePreference`) and a mapper `themeModeFor(ThemePreference) → ThemeMode`.

The cubit is provided above `MaterialApp`, so it is the single owner of the choice (R06a). The settings page reads and dispatches to the same instance.

### D6. No light flash on cold start

`main()` opens the box and reads the stored preference before `runApp`. The cubit starts with that value, so the first frame is already in the right theme.

### D7. Settings entry without a cross-module import

`AccountDrawer` (module `auth`) gets an `openSettings` callback. `ShellAccountDrawer` (composition root) passes a function that pushes `SettingsPage`. `auth` never imports `settings` (R02).

### D8. Dark palette values

No Figma reference exists yet. Values are derived from the brand navy so dark mode still reads as Vanep: navy-tinted near-black surfaces, light blue-gray text, `action` lifted to `#3D8BE8` for contrast on dark surfaces, and tinted (not pastel) danger / warning / success surfaces. Tokens are centralized, so a design pass only edits `VanepPalette.dark`.

## Risks

- **Mass migration.** ~900 call sites. Done mechanically (replace, then remove now-invalid `const`, then `dart fix` re-adds valid `const`), then reviewed for context-free helpers and painters. Analyzer with `--fatal-infos` plus the full test suite guard it.
- **Missed "white on color" call sites.** A `card` used as foreground renders dark text on blue in dark mode. Mitigation: every `card` used as a foreground color was reviewed and moved to `onAction`.
