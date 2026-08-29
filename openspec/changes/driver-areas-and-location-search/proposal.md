## Why

The backend now owns a real geographic tree (`country → state → city → district ⟲`) fed by Google Places, plus `driver_service_area` rows that say where each driver works. Nothing in the app reaches any of it: a driver has no way to declare where they drive, and a client has no way to find a driver by place. The whole capability exists server-side and is unreachable.

Without the driver-side screen the tree stays empty, and an empty tree makes the client search return nothing for every query. The driver flow must ship first, or the search ships broken.

## What Changes

- **New driver screen — service areas.** Up to **10** regions, each chosen through Google Places autocomplete. Reachable in two ways: offered right after a driver's first login, and permanently available from the driver profile so it can be finished or edited later. Skippable — never a hard gate on using the app.
- **New client screen — search by place.** **One** search box that accepts an address or a school. Returns drivers whose registered area contains that point, **ordered by how specific the match is**: the driver who registered exactly that spot comes first, the one who registered the whole city comes last.
- **Google Places autocomplete runs in the app**, not through the backend. The backend deliberately does not proxy autocomplete, so the app calls Places directly with the Android/iOS keys and forwards the `sessionToken` to the backend so the session bills as one unit instead of per keystroke.
- **Onboarding surfacing.** `GET /api/user/me` already returns `onboarding.pendingSteps`; the app starts reading it to decide whether to offer the service-area screen.
- **Bottom navigation shows icons only.** Labels move to `Semantics` so screen readers keep them. Already present as uncommitted work in the tree — this change adopts and tests it rather than redoing it.
- **BREAKING (backend prerequisite, other repo):** the existing `GET /api/drivers/search` requires **both** `originPlaceId` and `destinationPlaceId` and returns an unordered page. The product wants a **single** place and **ranked** results. That endpoint must change before the client search can be built. See Impact.

## Capabilities

### New Capabilities

- `driver-service-areas`: a driver declares, reviews and edits up to 10 regions where they operate, each resolved from a Google place; entry points from first login and from the profile.
- `place-autocomplete`: shared in-app access to Google Places autocomplete — session tokens, per-platform API keys, debounce, and the contract for handing `placeId` + `sessionToken` to the backend.
- `client-location-search`: a client searches one place and gets drivers whose area contains it, ranked by match specificity.

### Modified Capabilities

None. The mobile repo has no specs under `openspec/specs/` yet, so every capability above is new.

## Impact

**New modules** under `lib/modules/`: `driverserviceareas`, `driversearch`. **New shared code** under `lib/core/places/` for the autocomplete client, per R02 (used by two modules, so it cannot live inside either).

**Configuration.** `.env` already carries `GOOGLE_PLACES_API_KEY_ANDROID` and `GOOGLE_PLACES_API_KEY_IOS`, but `.env.example` does not document them and `Environment` does not read them. Both need the placeholders, and `Environment` needs a platform-aware accessor.

**Existing code touched.** `lib/shell/driver_shell.dart` and `driver_bottom_nav.dart` (entry point), `lib/core/ui/vanep_bottom_nav.dart` (icons only), `lib/modules/profile/` (reading `onboarding.pendingSteps`), and `lib/l10n/` (all new copy, per R10).

**Backend prerequisite — blocks the client search only.** `vanep-api-java` needs its own change:

1. Single-place search: accept one `placeId` (+ optional `sessionToken`) instead of origin *and* destination.
2. Rank results by distance from the point up the tree — exact district first, whole-city last — instead of returning an unordered page.
3. `@Size(max = 10)` on `DriverServiceAreaRequestDTO.areas`, so the 10-region cap is enforced server-side and not only in the UI.

The driver flow (items 1–2 of this proposal) depends on none of that and can ship first.

**Known tension to settle during design.** The product rule is "state + city + something deeper, always". The backend's D8 only *requires* a district where a curated flag says so (`DF`, `SP` today) and deliberately lets small cities declare the whole city. Our own fixtures show cities where Google returns **no** level below the city at all (Formosa, Itapetininga) — there, "something deeper" is not selectable and a hard client-side rule would lock the driver out.
