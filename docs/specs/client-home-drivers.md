# Spec — Client home screen (recent drivers)

## Context

The client-facing home screen is the first screen an authenticated client sees.
It greets the user, offers a search field, and lists the most recently registered
drivers as "suggestions near you". Navigation between the app's main areas is done
through a bottom navigation bar.

## Goals

- Greet the signed-in user by name.
- Show a search field in the top area of the screen.
- List the 3 most recently registered drivers with name, experience, city and rating.
- Provide a bottom navigation bar (Home, Vans, Notifications, Profile).

## Data source

The backend already exposes the data through `GET /api/drivers`
(`Page<DriverResponseDTO>`), which returns `name`, `experienceYears`, `city`,
`rating`, `photo` and `createdAt`. Recent drivers are fetched with
`?size=3&sort=createdAt,desc`.

The mockup's vehicle line ("Sprinter 2021") is intentionally omitted because vehicle
data lives in a separate resource (`/api/vehicles`) and is not part of the driver
list response.

## Non-goals (this change)

- Vans, Notifications and Profile tabs are placeholders (Profile reuses the existing
  sign-out screen).
- Server-side search by route/school (the search field filters the loaded suggestions
  by name/city on the client for now).

## Architecture (R01–R09)

New feature module `lib/modules/drivers/`:

- `domain/entities/driver.dart` — abstract `Driver`.
- `domain/failures/driver_failure.dart` — sealed failures.
- `domain/repositories/driver_repository.dart` — repository contract.
- `domain/usecases/list_recent_drivers.dart` — fetch recent drivers.
- `data/dtos/driver_dto.dart` — freezed DTO implementing `Driver`.
- `data/datasources/driver_remote_datasource.dart` — Dio call to `/api/drivers`.
- `data/repositories/driver_repository_impl.dart` — maps datasource → `Result`.
- `presentation/cubit/` — `DriversCubit` + `DriversState` (owns drivers + search query).
- `presentation/pages/client_home_page.dart` — scaffold + bottom nav.
- `presentation/widgets/` — driver card, search field, bottom nav, greeting header.
- `drivers_container.dart` — DI registration.

## Tasks

## Phase 1 (branch name: feat/client-home-drivers)
- [ ] 1.1 Tests: DTO parsing, repository impl, use case, cubit, widgets
- [ ] 1.2 Domain: entity, failure, repository contract, use case
- [ ] 1.3 Data: DTO, remote datasource, repository impl
- [ ] 1.4 Presentation: cubit/state, widgets, page, bottom nav
- [ ] 1.5 Localization strings (en + pt) and light design tokens
- [ ] 1.6 DI container + wire into `app.dart`
- [ ] 1.7 Run `make lint` and `make test`
- [ ] 1.8 Manual device verification, then open PR (after sign-off — R27a)
