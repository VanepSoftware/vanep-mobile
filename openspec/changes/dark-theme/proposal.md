## Why

The app only ships a light theme. Users who run their phone in dark mode get a bright white app at night, and there is no way to choose. The design system makes this hard to fix: every color is a `static const` in `VanepColors`, and every text style in `VanepTypography` bakes one of those colors in. So nothing in the UI can react to a theme.

## What Changes

- **Theme-aware design system.** Semantic color tokens (surfaces, text, borders, action, danger, warning, success, avatar tones, skeleton, schedule) move from `VanepColors` into a `VanepPalette` `ThemeExtension` with a `light` and a `dark` value. Widgets read them through `context.palette`. Typography becomes `VanepTypography(palette)`, read through `context.typography`, so text colors follow the theme.
- **Brand colors stay constant.** `VanepColors` keeps only the theme-invariant brand tokens (navy backdrop, `onBrand`, van illustration, rating star). The native splash and the intro must not change with the theme.
- **New `onAction` token.** Many widgets used `VanepColors.card` to mean "white on a colored fill" (filled button label, sent chat bubble, checkbox tick). In dark mode `card` is dark, so those call sites move to `onAction`.
- **`VanepTheme.dark()`.** `ThemeData` is built from a palette, so light and dark share one builder.
- **Theme preference: system, light or dark.** A new `settings` module stores the user's choice locally (Hive). Default is `system`. `system` follows the OS brightness live (`ThemeMode.system`).
- **Settings page.** The "Settings" entry of the profile menu (today disabled) opens a page with an "Appearance" section where the user picks System / Light / Dark.

## Capabilities

### New Capabilities

- `theme-preference`: the user's appearance choice (system, light, dark), its persistence, its default, and how it maps to the theme the app renders.
- `dark-theme`: the design system exposes a light and a dark palette, and every screen reads colors and text styles from the active one.

### Modified Capabilities

None. There are no archived specs under `openspec/specs/`.

## Impact

**Code.** `lib/core/design_system/` (palette, typography, theme, context extension). Every widget that reads `VanepColors` semantic tokens or `VanepTypography` (about 120 files across `core/ui`, `shell` and `modules`). Context-free color helpers (`avatarToneFor`, `assistantStatusColor`, custom painters) receive the palette as a parameter. `app.dart` and `main.dart` (cubit at the root, `darkTheme`, `themeMode`). New module `lib/modules/settings/`. Profile menu (`settings` entry enabled) and `AccountDrawer` (opens the page through a callback from the shell, so `auth` does not import `settings`). ARB pt + en.

**Not touched.** Native splash and launch screen colors. Brand intro and splash (they are always navy). Backend: the preference is device-local, no API.
