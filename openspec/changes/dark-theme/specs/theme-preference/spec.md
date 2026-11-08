## Purpose

Lets the user choose how the app looks: follow the phone (system), always light, or always dark. The choice is stored on the device.

## ADDED Requirements

### Requirement: Three appearance options with system as default

The app SHALL offer three theme preferences: `system`, `light` and `dark`. When no preference has been stored, or the stored value is unknown, the app MUST use `system`.

#### Scenario: First launch

- **WHEN** the app starts and no preference is stored
- **THEN** the theme preference is `system`

#### Scenario: Corrupted value

- **WHEN** the stored value is not one of `system`, `light`, `dark`
- **THEN** the theme preference is `system`

### Requirement: System follows the OS brightness live

With `system`, the app SHALL render the dark theme when the OS is in dark mode and the light theme otherwise. A change of OS brightness while the app is open MUST switch the theme without a restart.

#### Scenario: OS switches to dark

- **WHEN** the preference is `system`
- **AND** the OS brightness changes to dark
- **THEN** the app renders the dark theme

### Requirement: Light and dark override the OS

With `light` the app MUST render the light theme regardless of the OS. With `dark` the app MUST render the dark theme regardless of the OS.

#### Scenario: Forced dark on a light phone

- **WHEN** the preference is `dark`
- **AND** the OS is in light mode
- **THEN** the app renders the dark theme

### Requirement: Choice is persisted and applied immediately

Changing the preference SHALL apply the new theme immediately and store it on the device. On the next launch the stored preference MUST be applied before the first frame.

#### Scenario: Change and relaunch

- **WHEN** the user picks `dark` in Settings
- **THEN** the app switches to the dark theme right away
- **AND** after a restart the app opens in the dark theme

### Requirement: Settings page exposes the choice

The profile menu "Settings" entry SHALL be enabled for every user type and open a Settings page. The page MUST have an "Appearance" section with a control showing the three options and the current one selected. All copy MUST come from the ARB files.

#### Scenario: Open settings

- **WHEN** the user taps "Settings" in the profile drawer
- **THEN** the Settings page opens
- **AND** the current preference is selected in the Appearance control
