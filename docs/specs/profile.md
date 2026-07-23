# Spec — Profile

## Context

Authenticated users need a Profile area in the bottom navigation for all user
types (CLIENT, DRIVER, ASSISTANT). Phase 1 delivers typed session identity
(`GET /api/user/me`): `UserType`, account fields for Dados pessoais
(`phone`, `document`, `birthDate`, `Gender`), and endpoint migration. Phase 2
adds typed domain **summary** `/me` contracts in the app. Phase 3 ships the
Profile UI and wires summary photo into the header.

## Goals

- Expose a typed user role (`UserType`) from session profile to presentation.
- Ship a Profile screen with a role-based menu matrix; v1 enables only
  **Dados pessoais** and **Sair** (with confirm). Other items are greyed and
  non-tappable.
- Keep a single `ClientShell` bottom nav for DRIVER / ASSISTANT in v1 (no new
  shells yet).
- Load the role-appropriate summary `/me` when opening Profile and show
  **photo** in the header for CLIENT / DRIVER / ASSISTANT (Phase 3 UI wiring).

## Menu matrix (later phases — document only)

| Item | CLIENT | DRIVER | ASSISTANT |
|------|--------|--------|-----------|
| Dados pessoais | enabled (v1) | enabled (v1) | enabled (v1) |
| Endereços | later | — | — |
| Formas de pagamento | later | — | — |
| Gerenciar dependentes | later | — | — |
| Vans | later | later (TBD) | — |
| Contratos | later | later (TBD) | — |
| Dados profissionais / horário / cidade | — | later | — |
| Convite / vínculo motorista | — | — | later |
| Configurações | later | later | later |
| Privacidade e segurança | later | later | later |
| Sair | enabled (v1, confirm) | enabled (v1, confirm) | enabled (v1, confirm) |

ADMIN is recognized in domain typing but has **no** typed summary `/me`.
Admin Profile uses only `GET /api/user/me` (session) for header name/email and
Dados pessoais — no `clients|drivers|assistants/me` call.

## Backend contracts

### Session

`GET /api/user/me` — account identity for login/session and **Dados pessoais**.

Session fields mapped in Phase 1: `token`, `name`, `email`, `phone`,
`document`, `birthDate`, `gender` (`MALE` \| `FEMALE` \| `OTHER`), `type`
(`CLIENT` \| `DRIVER` \| `ASSISTANT` \| `ADMIN`).

### Typed summaries (lean)

Called by `UserType` from the session. Nested `user` matches `GET /api/user/me`
shape but is **not** the source of truth for account UI in the app.

| Endpoint | Summary fields |
|----------|----------------|
| `GET /api/clients/me` | `token`, `photo`, `rating`, `active`, `user` |
| `GET /api/drivers/me` | `token`, `photo`, `rating`, `city`, `approvalStatus`, `available`, `active`, `user` |
| `GET /api/assistants/me` | `token`, `photo`, `status`, `pendingInvite`, `user` |

Mobile maps the full summary into sealed domain types. **Profile header UI shows
photo only** (Phase 3); rating / status / invite remain unused in presentation
until a later phase.

Enums:

- Driver `approvalStatus`: `PENDING` \| `APPROVED` \| `REJECTED`
- Assistant `status`: `UNLINKED` \| `PENDING` \| `ACTIVE` \| `INACTIVE`
- Assistant `pendingInvite` (optional object): `token`, `expiresAt`,
  `driver` (`name`, `photo`, `city`, `rating`)

### Out of scope (for Phases 2–3)

- `PUT /api/{clients\|drivers\|assistants}/me` (removed on backend)
- Fat profile DTOs previously used only on `/me`
- CRUD by `{token}` for client/driver
- Assistant self-flows (`/me/invite/**`, `/me/revoke`)
- Header extras beyond photo (rating, city, approval, assistant status / invite)

## Product decisions (locked)

| Topic | Decision |
|-------|----------|
| Header photo | CLIENT / DRIVER / ASSISTANT via summary (wired in Phase 3) |
| ADMIN | Session `user/me` only — no summary `/me` fetch |
| Rating / status / city / invite in header | Later phase |
| Dados pessoais | Always from session (`user/me` at login) — not nested `user` |
| Name / email in header | From session; summary only adds photo (+ later extras) |
| When to fetch summary | Lazy: when opening the Profile tab (not at auth boot) |
| Failure loading summary | Soft-fail: keep header without photo; do not block Profile / menus |
| Camera badge | Still visual-only / disabled |

## Architecture (R01–R09)

Phase 1 lives in `lib/modules/auth/` (session `UserProfile`).

Phase 2 adds `lib/modules/profile/`:

- Chooses `clients` / `drivers` / `assistants` `/me` from session `UserType`
- Maps sealed summary types per role
- Exposes `GetProfileSummary` + `ProfileSummaryCubit` (registered in DI)
- Does **not** yet wire the Profile tab UI (Phase 3)

Phase 3 adds Profile UI in auth presentation and composes summary at the
shell/Profile boundary (lazy load + `photoUrl` on header).

Endpoints via `Environment` (`clientsMeEndpoint`, `driversMeEndpoint`,
`assistantsMeEndpoint`).

### Phased delivery (R16–R23)

| Phase | Contents | Depends on | Parallel with |
|-------|----------|------------|---------------|
| 1 | Migrate `/api/user/me`; expose `UserType` + account fields (`phone`, `document`, `birthDate`, `Gender`) on `UserProfile`; DTO mapping; tests | — | — |
| 2 | Typed summary `/me` module (clients / drivers / assistants); DI; cubit; tests — no Profile UI wiring | Phase 1 | — |
| 3 | Profile UI (header, menus, Sair confirm); lazy load summary on Profile tab; header photo; soft-fail | Phase 2 | — |

## Tasks

## Phase 1 (branch name: feat/n-17-profile-user-me-type)

- [x] 1.1 Spec in `docs/specs/profile.md`
- [x] 1.2 Tests: `UserType` / `Gender` parsing; `UserProfileDto` account + type mapping; endpoint `/api/user/me`
- [x] 1.3 Domain: `UserType`, `Gender`, `UserProfile` account fields + `type`
- [x] 1.4 Data: DTO mapping; `Environment.userProfileEndpoint` → `/api/user/me`
- [x] 1.5 Update fixtures, README path docs
- [x] 1.6 Run relevant unit tests; `make lint` when ready for PR
- [x] 1.7 Manual device verification, then commit/PR after sign-off (R27a)

## Phase 2 (branch name: feat/n-17-profile-summary)

- [x] 2.1 Spec updated: summary contracts + phase order (summary before UI)
- [x] 2.2 Tests: sealed DTO mapping by role; repository/usecase; cubit soft-fail; support helper
- [x] 2.3 Domain + data: sealed summaries; `Environment` endpoints; fetch by `UserType`; DI
- [x] 2.4 `make lint` / `make test`; device sign-off; commit/PR after approval (R27a)

## Phase 3 (branch name: feat/n-17-profile-ui-menus)

- [x] 3.1 Profile UI + role menus; only Dados pessoais + Sair enabled
- [x] 3.2 Header light client-home style; camera badge disabled visual; localization
- [x] 3.3 Lazy load summary when Profile tab opens; pass `photoUrl` into header
- [x] 3.4 Lint, test, device sign-off, PR
