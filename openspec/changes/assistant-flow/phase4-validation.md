# Phase 4 — PR #103 validation

## Current evidence

- Main integrated locally: `1fdd9772645710ed81bd1c6a8b8dbc306427bfa9`; no unresolved merge entries.
- Latest developer-reported full suite via FVM: **2,416 passed, zero failures**, in 16m18s.
- Latest developer-reported lint via FVM: **No issues found**, in 37.1s.
- Code generation completed successfully: 81 outputs; the removed `--delete-conflicting-outputs` option produced a non-fatal warning.
- The earlier two failures were negotiation route harnesses missing authentication providers. The corrected route tests and subsequent full suite both passed.
- Updated saved coverage: **17,932 / 19,377 relevant lines, 92.54%**, with the Makefile exclusions; exceeds the required 85%.
- The installed global SDK is Flutter 3.50.0 / Dart 3.14.0. `.fvmrc` and CI pin Flutter 3.47.2. FVM validation is now complete per the developer reports. The dependency lockfile resolved during FVM validation is included so the published branch uses the tested dependency versions; Windows generated files match the prepared merge.
- This agent's sandbox blocks the local sockets required by Flutter tests and ADB. Device discovery and recording must run in the developer terminal.

## Automated validation with the CI SDK

Use an isolated FVM installation of 3.47.2; do not replace the global SDK. If FVM is unavailable, install it in the developer terminal first. Run from the mobile repository:

```bash
fvm install 3.47.2
fvm flutter --version
fvm flutter pub get
make translate
make build
make lint
fvm flutter test --coverage --reporter expanded
```

Capture the final lint and test summaries. Inspect `git diff -- pubspec.lock windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake` after dependency resolution. Do not include unrelated SDK upgrades in this phase.

## Device validation and evidence

Run `fvm flutter devices`, then `fvm flutter run -d <device-id>` from the developer terminal. Use a test assistant account with existing van links.

| Scenario | Expected behavior |
|---|---|
| Assistant login | Assistant shell with Route, Students, and Profile tabs; no driver/client destinations. |
| One linked van | Active van selected automatically; no switch control. |
| Multiple linked vans | Card and switch control open the same selector; choosing a van updates active details. |
| Loading | Loading indicator shown while linked vans are fetched. |
| Failed van request | Localized load error and retry; no misleading unlinked message. Restore connectivity and retry. |
| No linked vans | Explicit unlinked state after a successful empty response. |
| Restricted navigation | Driver/client paths rejected with localized feedback; assistant shell retained. Automated tests cover programmatic paths. |
| Theme and tabs | Active van and selector readable in light/dark themes; route tab and page title agree. |
| Existing roles | Client and driver can still open negotiation chats. |

Capture screenshots and a video of the real app covering delivered states. Keep account secrets out of recordings. R13a requires publishing assets under `pr-assets/van-<task-number>/` and linking them in PR #103. The existing PR screenshots predate these review fixes.

## Publication gate

The developer explicitly authorized committing before device validation to unblock the team. This session instruction overrides R27a for this commit/push only. Device sign-off and updated screenshots/video remain pending and must not be reported as complete. Publish the prepared merge and review fixes, check CI (including 85% coverage), and obtain final reviewer approval before merging to main.
