# Phase 5 — PR #104 review and release readiness

## Scope

The developer explicitly authorized publishing the Phase 5 mobile base with the route/checklist backend dependency documented, while deferring the Android account/email investigation and device validation. This change unblocks dependent mobile development; it does not claim that the route/checklist backend integration is operational. Focused tests remain unexecuted in this sandbox, and CI/reviewer validation must determine merge readiness.

Phase 4 PR #103 is merged into main as `72330c22f0d95d233a41d6522439a1efc57decc9`. This branch integrates that main, including its navigation guards, van load failure handling, shared shift formatter, and theme changes.

## Review fixes

- Only `revokedInvite` revokes the checklist view; an authentication error does not masquerade as revocation.
- Only boarded students can be selected for bulk drop-off; the submitted set is checked against current boarding status and captured for the response update.
- All three mutation actions reject repeated taps while updating. Selection is frozen during a mutation.
- A van change or clear invalidates outstanding route/mutation responses and clears stale state.
- Route failures display localized errors and retry rather than a misleading empty list.
- New widgets use the current theme palette and typography. Helper methods no longer have private names.

## API contract — unresolved integration dependency

Checked `VanepSoftware/vanep-api-java` main, including `AssistantController`, `TripController`, and `DriverTripController`. No matching handlers exist for the mobile calls below:

| Mobile request | Backend main |
|---|---|
| `GET /api/assistants/me/vans` | Missing (inherited Phase 4 dependency). |
| `GET /api/assistants/me/vans/{vanToken}/route` | Missing. |
| `POST /api/assistants/me/vans/{vanToken}/checklist/status` | Missing. |
| `POST /api/assistants/me/vans/{vanToken}/checklist/no-show` | Missing. |

Existing `/api/drivers/me/trips/today` and administrative `/api/trips` endpoints do not provide assistant checklist operations and must not be substituted without a contract.

The proposed mobile payload uses `student_tokens`, `status`, `confirmed_by` for status updates, and `student_token`, `reason`, `confirmed_by` for no-show. These are the existing mobile assumptions, not an approved backend contract. The backend work must confirm authorization, trip identity, stop ordering, idempotency, allowed transitions, revocation responses, and shared driver synchronization. Do not mark review comment 4 or end-to-end integration as resolved until that work lands.

## Dependent partner work

- VAN-68 PR #121 adds van overview UI with mocked data and its own use cases/cubits. Its future merge must extend the existing `registerAssistantDependencies` composition root rather than replacing Phase 4/5 registrations.
- VAN-73 introduces `AssistantStudentsPage` for the general student catalog, while this phase's `AssistantStudentsListPage` uses the active trip checklist. Agree which page occupies the shell Students tab and reuse the existing card/search/filter patterns when combining them. Do not mount two competing owners of the same student list state.
- Main retains the existing Route/Students/Profile navigation. Changes to Home/Vans/Students navigation require an explicit follow-up decision.

## Verification

Static analysis passed with **No issues found** using the copied pinned Flutter 3.47.2 SDK in the agent sandbox (15.8s). Flutter test execution is blocked by the sandbox: creating a server socket on `127.0.0.1` fails with `Operation not permitted`. This is not a test pass.

Run from the mobile repository in the developer terminal:

```bash
fvm flutter test --no-pub test/modules/assistant test/shell/assistant_shell_test.dart test/widget_test.dart test/app_negotiation_routes_test.dart --reporter expanded
```

If `fvm` is not on PATH, use `/home/matheus/.pub-cache/bin/fvm` instead. No DTO/entity regeneration is needed for the review fixes. Full CI tests/coverage still need to pass on the published branch. The Phase 4 test and coverage results do not validate Phase 5.

Device testing and updated evidence are deferred at the developer's request. Do not mark them complete or replace them with mocked screenshots. Remote publication also depends on using the developer terminal: the agent Git transport is network-restricted and the GitHub connector previously rejected writes with HTTP 403.
