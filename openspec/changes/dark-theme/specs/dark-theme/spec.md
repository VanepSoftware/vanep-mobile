## Purpose

Defines how the design system supports a light and a dark look.

## ADDED Requirements

### Requirement: Semantic tokens come from the active palette

Widgets SHALL read semantic colors (surfaces, text, borders, action, danger, warning, success, avatar tones, skeleton, schedule) from the active `VanepPalette` through `BuildContext`. Widgets MUST NOT read semantic colors from a static constant.

#### Scenario: Card in dark mode

- **WHEN** the dark theme is active
- **THEN** cards use `VanepPalette.dark.card` and text uses `VanepPalette.dark.textPrimary`

### Requirement: Text styles follow the palette

Design-system text styles SHALL take their color from the active palette. Size, weight and spacing MUST be the same in both themes.

#### Scenario: Subtitle color

- **WHEN** the dark theme is active
- **THEN** `cardSubtitle` uses `VanepPalette.dark.textSecondary`

### Requirement: Brand surfaces do not change with the theme

The brand intro, the splash and other brand-navy surfaces SHALL use the theme-invariant brand tokens, identical in light and dark.

#### Scenario: Splash in dark mode

- **WHEN** the dark theme is active
- **THEN** the splash background is still the brand navy

### Requirement: Foreground on colored fills stays legible

Text and icons on `action`, `danger` or other saturated fills SHALL use `onAction`, which is white in both themes.

#### Scenario: Primary button in dark mode

- **WHEN** the dark theme is active
- **THEN** the primary button label is white on the action color

### Requirement: Light theme looks unchanged

`VanepPalette.light` MUST keep the color values the app used before this change.

#### Scenario: Light values preserved

- **WHEN** the light theme is active
- **THEN** `surface` is `#F4F6F8`, `textPrimary` is `#0B2038` and `action` is `#0B6BD3`
