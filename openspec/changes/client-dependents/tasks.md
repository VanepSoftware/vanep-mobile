## 1. Phase 1 — shared value object and formatter (branch name: chore/8-share-gender-and-birth-date)

- [x] 1.1 Run the existing `auth` tests that cover `Gender` and `formatProfileBirthDate` and record them green, so the move has a before state to compare against
- [x] 1.2 Move `Gender` from `lib/modules/auth/domain/value_objects/gender.dart` to `lib/core/domain/gender.dart` unchanged
- [x] 1.3 Move `formatProfileBirthDate` from `lib/modules/auth/presentation/formatters/profile_field_formatters.dart` to `lib/core/formatters/birth_date_formatter.dart` as `formatBirthDate`, leaving the profile-specific formatters where they are. The `Profile` prefix is dropped because the function is now shared with `dependents` and the old name would misname it there (R31, R39)
- [x] 1.4 Update every import in `auth` to the new locations, and the single `formatProfileBirthDate` call site in `personal_data_page.dart` to the new name
- [x] 1.5 Confirm the `auth` tests from 1.1 still pass; the gender test moves to `test/core/domain/` and the birth-date test to `test/core/formatters/` to mirror the code, with their assertions unchanged
- [x] 1.6 Run `make lint` and `make test`
- [ ] 1.7 Open PR — blocked on developer sign-off after manual testing (R27a)

## 2. Phase 2 — dependents domain (branch name: feat/8-dependents-domain)

- [x] 2.1 Write tests for the draft and for `buildDependentChangesForCreate` / `buildDependentChangesForUpdate`, covering untouched / value / explicit-null per field and the "nothing changed" case
- [x] 2.2 Write tests for `FindMyDependents`, `CreateDependent`, `UpdateDependent` and `SetDefaultDependent` against a mocked `DependentRepository`
- [x] 2.3 Add `domain/entities/dependent.dart` with `Dependent` and `DependentAddress` as abstract entities, implemented by the DTOs in phase 3
- [x] 2.4 Add `domain/value_objects/dependent_draft.dart` holding the editable fields, the `DependentField` identity and `validateDependentDraft`
- [x] 2.5 Add `domain/failures/dependent_failure.dart` as a sealed type covering validation with a field map, not found, network and unexpected
- [x] 2.6 Add `domain/repositories/dependent_repository.dart` returning `Result<DependentFailure, T>`
- [x] 2.7 Add `domain/usecases/find_my_dependents.dart`, `create_dependent.dart`, `update_dependent.dart` and `set_default_dependent.dart`
- [x] 2.8 Add `domain/value_objects/dependent_changes.dart` carrying the draft plus the touched-field set, instead of the `Map<String, Object?>` first sketched: API field names belong to the data layer, not the domain (R01). design.md updated
- [x] 2.9 Run `make lint` and `make test`
- [ ] 2.10 Open PR — deferred by developer request; branch is committed and pushed

## 3. Phase 3 — dependents data (branch name: feat/8-dependents-data)

- [x] 3.1 Write tests for `DependentDto.fromJson` against a fixture matching `DependentResponseDTO`, including a dependent with null `birthDate`, null `gender` and null `address`
- [x] 3.2 Write tests for `DependentRepositoryImpl` mapping `DioException` to each `DependentFailure`, including a 400 carrying the backend detail
- [x] 3.3 Add `data/dtos/dependent_dto.dart` with freezed + `json_annotation`, holding `DependentDto` and `DependentAddressDto` implementing the domain entities
- [x] 3.4 Add `dependentsEndpoint` to `Environment`
- [x] 3.5 Add `data/datasources/dependent_remote_datasource.dart` calling `GET`, `POST` and `PATCH` on `/api/dependent` through the authenticated Dio instance
- [x] 3.6 Add `data/repositories/dependent_repository_impl.dart` with the `DioException` to `DependentFailure` mapping, and `data/dtos/dependent_request_body.dart` turning `DependentChanges` into the wire body
- [x] 3.7 Add `dependents_container.dart` registering the datasource, repository and use cases, and call `registerDependentsDependencies` from `lib/main.dart`
- [x] 3.8 Run `dart run build_runner build --delete-conflicting-outputs`
- [x] 3.9 Run `make lint` and `make test`
- [ ] 3.10 Open PR — deferred by developer request; branch is committed and pushed

## 4. Phase 4 — dependents screens (branch name: feat/8-dependents-screens)

- [ ] 4.1 Write `bloc_test` cases for `DependentsCubit`: load success, load failure leaving a retryable state, empty list, reload after a write, and setting the default
- [ ] 4.2 Write `bloc_test` cases for `DependentFormCubit`: blank name blocked before any request, future birth date blocked, save sending only changed fields, clearing a field sending explicit null, and backend field errors landing on the matching field
- [ ] 4.3 Write widget tests for the list page covering the empty state, a card with and without an age, and the default mark
- [ ] 4.4 Add `presentation/cubit/dependents_cubit.dart` and `dependents_state.dart`
- [ ] 4.5 Add `presentation/cubit/dependent_form_cubit.dart` and `dependent_form_state.dart`
- [ ] 4.6 Add `presentation/formatters/dependent_failure_label.dart` and an age formatter derived from `birthDate`
- [ ] 4.7 Add `presentation/widgets/dependent_card.dart` using existing design-system tokens and `lib/core/ui/` widgets, with no one-off chrome
- [ ] 4.8 Add `presentation/pages/dependents_page.dart` with the list, the empty state, the retry state and the add control
- [ ] 4.9 Add `presentation/pages/dependent_form_page.dart` for create and edit, built from `VanepTextField`, the gender chips pattern and a birth date picker
- [ ] 4.10 Render the default as visible on the card, and offer the choice control only when there are two or more dependents
- [ ] 4.11 Flip the `dependents` entry to `enabled: true` in `profile_menu_builder.dart` and push the page from the `ProfileMenuId.dependents` case in `profile_page.dart`
- [ ] 4.12 Add every new string to `lib/l10n/app_pt.arb` and `lib/l10n/app_en.arb`, reusing the existing `profileDependents` key as the screen title
- [ ] 4.13 Confirm the S14 layout against the Figma file and settle how the default is presented
- [ ] 4.14 Run `make lint` and `make test`
- [ ] 4.15 Open PR

## 5. Phase 5 — dependent address (branch name: feat/8-dependent-address)

- [ ] 5.1 Confirm the backend change accepting `placeId` + `sessionToken` on `POST/PATCH /api/dependent` is merged; do not open this PR before it is
- [ ] 5.2 Write tests asserting the save body carries `placeId`, `sessionToken`, `number` and `complement` and no city, state, district, zip code or street
- [ ] 5.3 Write tests for saving without an address, for replacing an existing address, and for a place the backend cannot resolve landing on the address field
- [ ] 5.4 Add the address fields to `DependentDraft` and to `buildDependentPatch`
- [ ] 5.5 Add the Places field to the form using `VanepPlaceAutocompleteField` and a `PlaceAutocompleteController` resolved from the container, disposed when the form closes
- [ ] 5.6 Render the resolved address on the form and on the card from `AddressResponseDTO`, with a localized "no address" state
- [ ] 5.7 Add the address strings to both ARB files
- [ ] 5.8 Run `make lint` and `make test`
- [ ] 5.9 Open PR
