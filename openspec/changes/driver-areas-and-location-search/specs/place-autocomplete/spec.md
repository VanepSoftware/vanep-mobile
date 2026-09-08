## ADDED Requirements

### Requirement: Autocomplete runs in the app, against Google directly

The app SHALL call Google Places Autocomplete (New) itself. The backend deliberately does not proxy autocomplete, because proxying would add a round trip to every keystroke without any gain.

The app MUST use the platform key — the Android key on Android, the iOS key on iOS — and MUST NOT ship or use the server key, which is restricted by IP and would fail on a device anyway.

#### Scenario: Suggestions for typed text

- **WHEN** the user types at least the configured minimum number of characters
- **THEN** the app requests suggestions from Google and shows them

#### Scenario: Platform key selected

- **WHEN** the app builds an autocomplete request
- **THEN** it uses the Android key on Android and the iOS key on iOS

#### Scenario: Results restricted to Brazil

- **WHEN** the app requests suggestions
- **THEN** the request restricts results to the `br` region

### Requirement: One session token per search box

The app SHALL create a session token when a search box gains focus and SHALL send that same token with every autocomplete request from that box and with the request that hands the chosen `placeId` to the backend.

The app MUST start a new token after a selection is handed over, because a session ends when the backend calls Place Details with it.

This is a billing requirement, not a nicety: a session that closes with a matching token bills as one free session, and one that does not bills every keystroke separately.

#### Scenario: Same token across a search

- **WHEN** the user types several times in one box and picks a suggestion
- **THEN** every autocomplete request and the request to the backend carry the same session token

#### Scenario: New token after handover

- **WHEN** the user picks a suggestion and then starts typing again in the same box
- **THEN** the app uses a new session token for the new search

#### Scenario: Independent boxes

- **WHEN** a screen shows more than one search box
- **THEN** each box owns its own session token

### Requirement: Keystrokes do not each become a request

The app MUST debounce input so a burst of typing produces one request rather than one per character, and MUST discard a response that arrives after a newer request for the same box.

#### Scenario: Fast typing

- **WHEN** the user types continuously without pausing
- **THEN** the app issues one request after the pause, not one per character

#### Scenario: Out-of-order responses

- **WHEN** a slower earlier response arrives after a newer one
- **THEN** the app keeps the newer suggestions and discards the stale ones

### Requirement: Failures are visible and recoverable

The app SHALL distinguish a rejected credential from a network failure and MUST NOT present an empty suggestion list as if the place did not exist.

#### Scenario: Network failure

- **WHEN** the autocomplete request fails for network reasons
- **THEN** the app shows a localized retry affordance and keeps the typed text

#### Scenario: Rejected key

- **WHEN** Google rejects the key because of its application restriction
- **THEN** the app surfaces an error distinct from "no results found"

#### Scenario: Genuinely no results

- **WHEN** Google answers successfully with no suggestions
- **THEN** the app shows a localized empty state, not an error
