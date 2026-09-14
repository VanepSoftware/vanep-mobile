## Why

A contract binds exactly one dependent (RN01), and a client cannot send a proposal without one. The backend has shipped the full dependent CRUD (`/api/dependent`, create/list/show/update/delete/restore, plus the RN12 default rules), and the client profile menu already carries a `Manage dependents` row — permanently disabled, wired to a `break`. The capability exists on both ends and is unreachable from the app, so the proposal flow (UC05/S10) has nothing to select.

## What Changes

- **New client screen — dependents (S14).** Lists the signed-in client's dependents, each card showing name, age and whether it is the default. Reached from the existing `Manage dependents` row in the client profile, which stops being disabled.
- **Add and edit a dependent.** One form for both, covering name, birth date and gender. Name is the only field the backend requires; the rest are optional and may be left empty.
- **Set the default dependent (RN12).** With a single dependent the backend already marks it default on create and the app shows it as such without offering a choice. With two or more, the client picks one and the app sends `isDefault: true` through `PATCH /api/dependent/{token}`; the backend clears the previous default.
- **Address on the dependent.** Chosen through Google Places autocomplete, reusing `lib/core/places/` and `VanepPlaceAutocompleteField` already in the tree. The app sends `placeId` + `sessionToken` and never address components.
- **`Gender` and the birth-date formatter become shared code.** Both live in `lib/modules/auth/` today and are needed verbatim by the dependent form. Per R02 and R06a they move to `lib/core/` and `auth` imports them from there, instead of a second copy under `dependents`.
- **BREAKING (backend prerequisite, other repo):** `POST/PATCH /api/dependent` takes the address as `AddressRequestDTO` — `cityToken`, `zipCode`, `street`, `number`, `complement`. The app cannot produce a `cityToken`: the CLIENT permission bundle grants only the dependent CRUD plus `list_drivers`/`show_driver` (`DataSeeder.clientPermissions()`), so `/api/cities` returns 403, and that endpoint has no search-by-name anyway. The dependent address must accept `placeId` + `sessionToken` the way `PUT /api/user/me/address` already does. See Impact.

## Capabilities

### New Capabilities

- `client-dependents`: a client lists, adds and edits their dependents, and chooses which one is the default; covers the entry point, the list, the form, validation and error handling.
- `dependent-address`: the address carried by a dependent — selected from Google Places, sent as `placeId` + `sessionToken`, displayed from what the backend resolves.

### Modified Capabilities

None. `openspec/specs/` in this repo is still empty, so every capability above is new.

## Impact

**New module** `lib/modules/dependents/`, laid out per R02: `data/{datasources,dtos,repositories}`, `domain/{entities,failures,repositories,usecases,value_objects}`, `presentation/{cubit,pages,widgets,formatters}`, plus `dependents_container.dart`.

**Shared code moved into `lib/core/`.** `Gender` (`lib/modules/auth/domain/value_objects/gender.dart`) and `formatProfileBirthDate` (`lib/modules/auth/presentation/formatters/profile_field_formatters.dart`) are consumed by both modules from the move onward. Moving them is a prerequisite, not a side effect: keeping them in `auth` would force a cross-module import that R02 forbids, and copying them would create the second source of truth R06a forbids.

**Existing code touched.** `lib/modules/auth/domain/builders/profile_menu_builder.dart` (the `dependents` entry becomes `enabled: true`), `lib/modules/auth/presentation/pages/profile_page.dart` (the `ProfileMenuId.dependents` case stops falling through to `break` and pushes the new page), `lib/main.dart` or wherever containers register (new `registerDependentsDependencies`), and `lib/l10n/app_pt.arb` + `app_en.arb` for all new copy, per R10. `profileDependents` already exists in both files and is reused as the screen title.

**Configuration.** None. Places keys, the authenticated Dio instance and `Environment` are already in place; `Environment` gains one `dependentsEndpoint` getter alongside the existing ones.

**Backend prerequisite — blocks `dependent-address` only.** `vanep-api-java` needs its own change before the address part of this one can ship:

1. `DependentCreateDTO.address` and `DependentUpdateDTO.address` accept `placeId` + optional `sessionToken`, `number`, `complement` — matching `PersonalAddressRequestDTO` — and resolve the place server-side through the existing geography tree, instead of requiring a client-supplied `cityToken`.
2. The response keeps returning the resolved `AddressResponseDTO`, so nothing changes on the read side.

This mirrors the decision already recorded in the `location-system` specs: the backend re-resolves every place and does not trust address components sent by a client. The dependent endpoint is the one place that still does.

**Out of scope.** Deleting a dependent (the backend supports `DELETE` and promotes a new default afterwards, but S14 and UC13 describe only add/edit/default), linking a dependent to a school via `schoolToken`, the `shift` field, `isSelf`, and pre-selecting the default dependent when sending a proposal (UC05/S10, a separate screen).
