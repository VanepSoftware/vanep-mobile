# Driver home — VAN-66 / imported VAN-120

## Scope

Implement the base Driver → Home page (`moto-home-1` through `moto-home-8`). The task description supplied by the developer is authoritative. The linked Linear issue is not accessible from this environment, and the design frames have not been supplied; visual fidelity to those frames remains unverified.

Only the main card changes with the driver's state. Keep these six shortcuts in this order, in two rows: Students, Route and stops, Absences and adjustments / Finances, Assistants, Documents. Route start, checklist and contact actions belong inside the main card. Boarding and disembarking require a complete slide gesture; tapping or a partial drag must not confirm.

Full destination screens are separate features. Existing destinations may remain pending navigation integrations, explicitly recorded as TODO(VAN-66); rendering a pending destination is not evidence that the feature works.

## State resolution

1. Subscription or expired-document block. During an active trip it becomes a warning banner and must not interrupt operations.
2. Incomplete registration: only Documents is enabled among the six shortcuts.
3. UNDER_REVIEW registration.
4. REJECTED registration: the same card structure as under review, error colors, reason and Correct and resubmit action.
5. IN_PROGRESS trip.
6. Today's scheduled trip, before departure.
7. Completed shift with another shift later today.
8. Approved registration with no students, building the route.
9. No route today, business panel.

An active trip keeps its operational card even if stale registration or blocking information is returned. Route start must revalidate APPROVED against fresh data (RN-02). Outside working hours is advisory, never a start prohibition. Show the family counter when known, including 100% (D12); do not fabricate family membership when the API does not provide it.

## API integration and remaining dependencies

Production uses onboarding, today's trips, route start and client links. Route start accepts the shift associated with the returned trip token; unknown shifts fail before HTTP mutation.

The current TripResponseDTO has no next stop or contact. DriverTripController has only today, start and finish. Stop confirmation, next-stop/contact mapping and real family membership remain backend dependencies. The production UI must not simulate successful confirmation or display invented counts.

Active client-link count is currently used as the route-building signal; it is not a verified count of transported children. A driver-students contract is still needed to establish that distinction.

Google Places setup and full shortcut destinations are outside the base Home acceptance scope.

## Verification

- Domain tests: nine states, active-trip block banner, incomplete-registration shortcuts and D12.
- Cubit tests: RN-02 fresh-data validation, concurrency, unavailable repository, refresh errors and stop identity validation.
- Widget tests: all nine card states, shared card structure, fixed shortcut order, contact/slide placement, D12 at 100%, outside-hours advisory and both slide actions.
- ARB localization for Portuguese and English; generated localization code is not versioned.
- `test/previews/driver_home_preview.dart` is an explicitly simulated, alternate entrypoint for device validation. It never replaces the production repository and must not be presented as real API evidence.
- Production evidence: successful login and IN_PROGRESS card verified on USB device. The developer recorded the nine preview states on the device and will attach the video; those scenarios use simulated test data.

## Delivery

Follow the approved domain → data → presentation dependency order recorded in `docs/reviews/VAN-66-pr-146.md`. Each PR must remain within 600 productive lines and 10 new files. Subdivide presentation before publication. No commit/push before manual developer validation (R27a).
