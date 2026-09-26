## Context

The backend ships the dependent CRUD in full: `POST/GET/PATCH/DELETE /api/dependent`, the RN12 default rules (`applyDefaultOnCreate`, `clearOtherDefaults`, `promoteDefaultAfterDelete`), and a one-to-one owned address per dependent. The CLIENT permission bundle grants exactly that CRUD plus `list_drivers`/`show_driver`. The app reaches none of it — `ProfileMenuId.dependents` exists, sits in the client menu with `enabled: false`, and falls through to a `break` in `handleProfileMenuSelection`.

The screen has a shape to follow. `personal_data_page.dart` plus `PersonalDataCubit` is the repo's only form-with-save precedent: a cubit holding drafts, per-field errors keyed by name, a dirty check before saving, and a patch built from the drafts against a snapshot. `DriverServiceAreasPage` is the precedent for a Places-backed screen. Both are worth copying in structure and neither is worth copying in code.

Two constraints come from outside this repo. `Gender` and `formatProfileBirthDate` live under `lib/modules/auth/` and are exactly what the dependent form needs — R02 forbids the cross-module import and R06a forbids the second copy. And the dependent address endpoint wants a `cityToken` the app has no way to obtain, which is the subject of the backend prerequisite in the proposal.

## Goals / Non-Goals

**Goals:**

- A client lists, adds and edits dependents, and picks the default, against the endpoints as they exist today.
- The dependent address uses the same Places path as every other address in the app.
- `Gender` and the birth-date formatter end up with one owner, shared by `auth` and `dependents`.
- Each phase lands with its own tests and a green `make lint` / `make test`, per R25 and R27.

**Non-Goals:**

- Deleting a dependent. The backend supports it and promotes a new default afterwards, but S14 and UC13 describe add, edit and default only. Whoever adds delete later inherits `promoteDefaultAfterDelete` for free.
- `schoolToken`, `shift`, `isSelf`, `document`, `phone` and `email`. The backend accepts them; UC13 asks for name, birth date, gender and address.
- Pre-selecting the default dependent when sending a proposal (UC05/S10). That screen consumes this one.
- Any caching or offline store. The list is read on open and after each write.

## Decisions

### The module owns its state in one cubit, not one per screen

`DependentsCubit` holds the list, the load status and the pending write. The form is a second cubit, `DependentFormCubit`, holding drafts and field errors for one dependent.

The alternative — a single cubit spanning list and form — was rejected because the form's draft state is per-dependent and short-lived while the list's is per-screen, and merging them means the list state carries fields that are null in every state but one. Splitting them keeps R06a intact as long as the form does not keep its own copy of the list: on save it returns the saved dependent and the list reloads.

Rejected alternative: the form mutating the list optimistically. The backend rewrites `isDefault` across other rows on a default change, so an optimistic list would be wrong for every dependent except the one being edited. Reloading after a write is one extra request and always correct.

### `isDefault` is read from the backend, never tracked in the app

RN12 lives in `DependentService`: the first dependent is default on create, a `isDefault: true` patch clears the previous one. The app's only job is to send the patch and re-read. The "single dependent is automatically default" half of RN12 becomes a display rule — with one dependent, show it as default and render no control — not a write the app performs.

Rejected alternative: the app sending `isDefault: true` when creating the first dependent. It is redundant (`applyDefaultOnCreate` already does it when `countByClientId == 0`) and it would put the rule in two places.

### `Gender` and the birth-date formatter move to `lib/core/`

`Gender` moves to `lib/core/domain/gender.dart` unchanged — it is a pure enum with `fromApi`/`toApi` and no Flutter dependency. `formatProfileBirthDate` moves to `lib/core/formatters/birth_date_formatter.dart`. `auth` updates its imports; no behaviour changes and its existing tests must still pass untouched, which is the check that the move was a move.

Rejected alternative: `dependents` importing from `lib/modules/auth/domain/`. R02 allows cross-module access only through domain contracts, and a value object is not a contract. Rejected alternative: duplicating the enum. R06a, and the two copies would drift the moment the backend adds a gender.

### The form builds a patch by diffing against a snapshot

`PATCH /api/dependent/{token}` merges by presence: an absent key is untouched, an explicit null erases. The form therefore cannot send its whole draft. It diffs the draft against the dependent it was opened with and emits three states per field — absent, a value, or an explicit null — following `buildProfilePatchFromDrafts` in `auth`.

`JsonNullable` on the backend means null and absent are genuinely different, so a DTO cannot model an optional field as a plain nullable. The domain expresses the difference as `DependentChanges` — a draft plus the `Set<DependentField>` the client actually touched — and the data layer turns that into the request body. An untouched field is absent from the body; a touched field carrying null is sent as an explicit null.

Rejected alternative: the domain emitting the `Map<String, Object?>` body directly. It is shorter, but it puts API field names in the domain layer, which R01 keeps free of external concerns, and it would make the patch builder untestable without asserting on wire strings.

Response DTOs stay freezed + `json_serializable`, as in `profile_summary_dto.dart`. Codegen runs per R15.

### The address is a `placeId`, and the backend change gates it

> **Superseded** by change `personal-address` (decision D14, phase 6): the dependent address is the shared IBGE postal form (`cityToken`, `street`, `zipCode`), not a `placeId`. The backend prerequisite described below was resolved the other way — the back accepts the catalog `cityToken`, and CLIENT can read `/api/cep`, `/api/states` and `/api/cities` with only the Bearer token. Kept as the record of the earlier decision.

The app sends `{placeId, sessionToken, number, complement}` as `address`. This is what `PUT /api/user/me/address` already accepts and what the `location-system` specs describe as the rule for every place the backend resolves. The dependent endpoint is the one that still asks for `cityToken`, and the CLIENT bundle cannot read `/api/cities` anyway, so the current contract is not implementable from the app regardless of which shape we prefer.

Consequence for sequencing: phases 1–4 depend on none of it and ship against today's backend. Phase 5 waits for the backend PR. Per R21 the phase-5 branch may be built against a mocked datasource, but it does not open until the backend change is merged.

Rejected alternative: granting the CLIENT bundle `list_cities` and adding search-by-name to `/api/cities`. It costs a backend PR too, keeps two address models in the product, and puts a city picker plus hand-typed zip code and street in a form that has one field everywhere else in the app.

### Failure mapping lives in the repository, as elsewhere in the module set

`DependentFailure` is an enum in `domain/failures/`, and `DependentRepositoryImpl` maps `DioException` to it, the way `serviceAreaFailureFrom` does. Field-level errors from the backend (a duplicate document, a name too long) carry a field name, so the failure type distinguishes `validation` with a field map from the flat cases, and the cubit routes the first to field errors and the rest to `VanepFeedback`.

## Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Move `Gender` and the birth-date formatter to `lib/core/`; update `auth` imports | — | — |
| 2 | `dependents` domain: entity, repository contract, failures, use cases | Phase 1 merged | — |
| 3 | `dependents` data: DTOs, remote datasource, repository implementation, container | Phase 2 merged | — |
| 4 | `dependents` presentation: list page, form page, cubits, profile entry point, l10n | Phase 3 merged | — |
| 5 | Dependent address through Places, in the form and on the card | Phase 4 merged **and** the backend `placeId` change merged | — |

Phase 1 is the only artifact with no internal dependency, so it is the first PR (R18). Phases 2 and 3 are separated because R20 forbids shipping the repository contract and its implementation together. No two phases are parallel: each layer consumes the one below.

| Phase | Layer | New files (cap 10, R23) |
|----|----------|---------------|
| 1 | core | 2 moved, 0 new |
| 2 | domain | ~7 |
| 3 | data | ~5 plus generated |
| 4 | presentation | ~9 |
| 5 | data + presentation | ~3 |

## Risks / Trade-offs

**The backend prerequisite may not be accepted** → Phases 1–4 deliver the list, the form for name/birth date/gender, and RN12 without touching an address. The acceptance criterion "endereço" is the only one left open, and it is open today regardless, because no `cityToken` is reachable from the app.

**Reloading the list after every write costs a round trip** → Accepted. The backend rewrites `isDefault` on other rows during a default change, so any optimistic list is wrong for rows the app did not touch. Correctness over one request.

**Moving `Gender` out of `auth` touches a module this change otherwise leaves alone** → The move is mechanical and phase 1 ships it alone, with `auth`'s existing tests unchanged as the proof. If those tests need edits beyond the import line, the move was not a move.

**Phase 4 is close to the R23 file cap** → If the form outgrows it, the field widgets split into their own PR ahead of the pages, in the same layer, which R22 permits since they do not depend on each other.

**The form and the list can disagree about a dependent while the form is open** → The form holds a snapshot taken when it opened. The list is not live behind it, and the app reloads on return, so the window closes at save. A concurrent edit from another device is lost, which the backend's last-write-wins already implies.

## Open Questions

- Does the S14 Figma show the default as a badge on the card, a radio control, or both? The spec requires only that it be visible and that no control appear with a single dependent. `vanep-project-overview/figma/` holds the plugin script, not the exported screen, so the layout is settled from the Figma file itself during phase 4.
- Should a dependent with no address be flagged in the list, given a proposal will likely need one? Deferred to UC05, which owns that requirement.
