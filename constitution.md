# Project constitution

Context and conventions for code implementation, and review.

The rules below are not negotiable, you must follow them.

## Stack

Stack: Flutter (pinned via FVM / `.fvmrc`, currently `3.44.4`), Dart SDK `^3.12.2`, Android + iOS targets. Dev workflow via `Makefile` (`make install`, `make lint`, `make lint_fix`, `make test`, `make coverage`). Static analysis is strict: `flutter analyze --fatal-infos`.

## Project rules

- R01 — **Clean Architecture (layered).** Presentation: Cubits/Blocs + Pages/Widgets — UI logic only, no business rules. Domain: abstract Entities + UseCases + Repository contracts — pure business logic. Data: DTOs + Repository implementations + Datasources — external concerns. Layer dependency: Presentation → Domain ← Data. Domain must not depend on Flutter, HTTP clients, local storage, or any other external dependency.
- R02 — **Feature-first modularization.** Each domain is a self-contained module under `lib/modules/` with `*_container.dart` (DI registration), `data/datasources/`, `data/repositories/`, `data/dtos/`, `domain/entities/`, `domain/usecases/`, `domain/repositories/`, and `presentation/cubit/` or `presentation/bloc/`, `presentation/pages/`, `presentation/widgets/`. No cross-module imports except through domain contracts. Shared code lives in `lib/core/`.
- R03 — **Dependency injection (non-negotiable).** All dependencies via the DI container through a `FeatureContainer`. No hardcoded dependencies in business logic. Constructor injection is mandatory for testability.
- R04 — **Type safety and code generation.** DTOs use `freezed_annotation` + `json_annotation` with `build_runner`. Entities are abstract; DTOs implement them. Use an explicit `Result<E, T>` type for error handling — not exceptions as control flow. Use value equality (e.g. `equatable`) for domain and value objects.
- R05 — **Test-first (non-negotiable).** For new behavior, write failing tests first (red → green → refactor); do not land feature logic without tests in the same change set. Unit-test UseCases, Cubits/Blocs, and Repositories with `mocktail` + `bloc_test`. Fixtures and mocks live in dedicated `*_fixture.dart` / `*_mocks.dart` files (module-scoped under `test/modules/<module>/...`, shared under `test/core/` when reused) — never inline large object graphs in `test()` bodies. Test bodies stay thin: arrange via fixtures, act, assert.
- R06 — **Reuse before rewrite.** Extend existing widgets, pages, use cases, and domain types before parallel implementations. New flows compose shared UI. Extract only when reuse is impossible without harming clarity; never copy-paste under a new name.
- R06a — **Single source of truth (non-negotiable).** Every fact, state slice, label, mapping, or identifier has exactly one canonical owner; everything else **derives** from it — never duplicates it in parallel. Multiple sources for the same concept always drift and cause bugs. **State:** one Cubit/Bloc (or domain store) owns runtime truth; widgets read and dispatch — no shadow copies, cached mirrors, or "sync" flags that can disagree. **Copy:** localization only (R11) — no duplicate string tables or hardcoded fallbacks for the same text. **Domain data:** entities and repository contracts are authoritative; DTOs map in/out at the boundary — presentation does not re-encode business rules already in domain. **Identity and keys:** one type/function defines how items are matched; do not maintain a second ID scheme or equality rule elsewhere. **Display derivations:** one function or extension maps canonical state → UI (labels, progress, icons); do not re-derive the same logic in another widget or layer. Before adding a second representation, **extend the owner** or **compute from it**; if two sources already exist, consolidate in the same change — do not add a third.
- R07 — **Abstractions over direct coupling.** Domain exposes contracts (repository interfaces, evaluators, builders); presentation and data depend on those, not concrete implementations. Prefer small, testable interfaces where multiple call sites or test doubles are expected. Direct calls only at composition roots (containers, route builders); business decisions stay behind domain abstractions.
- R08 — **Avoid private methods.** Do not use `_`-prefixed private methods; extract to top-level functions, extensions, or dedicated classes within the same module. `lib/core/` is for global or cross-module code only — never module-specific helpers there.
- R09 — **API contract.** Base URL from a central `Environment`. Endpoints return JSON; DTOs handle deserialization. An auth interceptor manages token refresh transparently at the HTTP-client boundary.
- R10 — **UI standards.** A single design system in `lib/core/design_system/` (theme, colors, typography). User feedback goes through one shared feedback surface. **All user-visible copy** (labels, hints, validation messages, snackbars, dialogs, button text) **must use localization** (`AppLocalizations` from ARB files under `lib/l10n/`) — no hardcoded strings in widgets or presentation logic.
- R10a — **Reuse existing UI patterns (non-negotiable).** Before adding widgets or layout, search `lib/core/design_system/`, `lib/core/ui/`, and the feature's `presentation/widgets/` for an existing pattern. **Do not** invent parallel containers or ad-hoc chrome when a shared component already exists — extend it, or extract one into `lib/core/ui/` first. Titles and list rows must use design-system typography and color tokens; no one-off `fontWeight` / colors for elements that already have a project style.
- R10b — **Core UI widgets mandatory (non-negotiable).** Use widgets from `lib/core/ui/` for shared presentation concerns — never reimplement the same chrome in feature code. Shared buttons, field chrome, page scaffolds, and feedback must come from core. If no widget fits, extend an existing one or add it under `lib/core/ui/` in the same change — do not ship a one-off duplicate in a module.
- R11 — **Spec before code.** Every feature starts with a spec (ADR or task breakdown). Write specs in English even when the user speaks another language.
- R12 — **Branch naming.** Use `feat/`, `fix/`, or `chore/` prefixes.
- R13 — **PR requirements.** CI must pass (lint + tests); at least one review. Run `make lint` and `make test`.
- R14 — **Commits.** Use conventional commit messages.
- R15 — **Codegen.** Run `dart run build_runner build --delete-conflicting-outputs` after any DTO or entity change.

### Phased development

- R16 — Split feature work into phases; ship each phase on its own branch with one PR. Phases must be clear in the generated `tasks.md` file, explicitly defined and numbered.
- R17 — Before code generation: produce a dependency graph, layer assignment, and PR plan table (`| PR | Contents | Depends on | Parallel with |`); do not implement until the plan is approved.
- R18 — Dependency first: artifacts with zero internal dependencies form the first PR; do not generate later layers before them.
- R19 — One dependency layer per PR; never mix artifacts from different layers in the same PR.
- R20 — Never ship an abstraction/interface and its implementation in the same PR.
- R21 — If an upper layer ships before its dependency is merged, use stubs or mocks until the dependency PR is approved.
- R22 — PRs in the same dependency layer may open and review in parallel only when they do not depend on each other.
- R23 — Cap each PR at 600 productive lines and 10 new files; subdivide before implementing if exceeded.
- R24 — Per phase, implement in dependency order: test → domain contract → entity → repository → use case → cubit/bloc → page/widget.
- R25 — Every phase includes automated tests covering the code delivered in that phase; plan tests when implementation can proceed in parallel — do not defer testing to a later phase; CI must pass after each phase.
- R26 — Tests must cover the code delivered in that phase only.
- R27 — Run `make lint` before opening each phase PR.
- R27a — **Never commit or push phase work without developer sign-off.** After `make lint` and `make test` pass, stop and wait for the developer to manually test on device/emulator. Only commit and push after explicit approval. Automated tests alone are not sufficient — runtime behaviour must be verified by a human before the change lands in version control.

### Legacy code

- R28 — Before adding a new resource, check for existing code that is relevant and can be reused.
- R29 — Before adding new code, check if existing code can be refactored to match Project rules.
- R30 — When refactoring, prioritize clarity over conciseness.
- R31 — Functions should have names that say exactly what they do. Instead of `handleData()`, prefer something like `validateCpf()`; instead of `i`, prefer `productIndex`.
- R32 — Function names should normally start with a verb (an action), because a function does something.
- R33 — Avoid ambiguous and generic names like `process()`, `handle()`, `calculate()`.
- R34 — The smaller the function, the easier it is to choose a precise name. If you cannot find a clear name, the function is probably doing too many things.
- R35 — Use consistent vocabulary throughout the codebase. If you use `find` in one place and `get` in another for the same idea, it causes confusion. Pick one term and stick to it.

### Engineering

- R36 — Create tests before writing code.
- R37 — Avoid private functions as much as possible.
- R38 — Small functions with a single purpose: functions should do one thing only and do it well. If you need to describe it with "and then… and after that…", it probably has more than one responsibility. Split it into smaller functions that are easier to read, test, and reuse.
- R39 — Clear and meaningful names: use names that express intent for variables, functions, classes, and modules. Avoid obscure abbreviations and generic terms. The reader should understand what something does just by its name, almost without needing comments.
- R40 — Comments only when they really add value: comments are not an excuse for bad code. First, improve the code; only then add comments for what is not obvious (complex rules, workarounds for external bugs, etc.). Good comments explain the "why", not the "what".
- R41 — Explicit and clean error handling: throw meaningful exceptions, check return values when appropriate, and avoid swallowing errors in empty `catch` blocks. Clean code makes it obvious what happens when something goes wrong and does not mix business logic with error-handling logic in a messy way.
- R42 — Remove duplication and keep cohesion: avoid repeating logic in multiple places (DRY). If you notice patterns being repeated, extract them into reusable functions or classes. At the same time, keep each module/class cohesive: everything in it should revolve around a single responsibility.
- R43 — Delete dead code.
- R44 — Leave code cleaner than you found it (boy scout rule).
- R45 — Treat refactoring tasks as first-class work items.

# Samples

tasks.md sample:
```markdown
## Phase 1 (branch name: [feat/task-number-task-description])
- [ ] 1.1 Description and implementation of tests for phase 1
- [ ] 1.2 Description of task number two
- [ ] 1.3 Run `make lint` and `make test`
- [ ] 1.4 Open PR

## Phase 2 (branch name: [feat/task-number-task-description])
- [ ] 2.1 Description and implementation of tests for phase 2
- [ ] 2.2 Description of task number two
- [ ] 2.3 Run `make lint` and `make test`
- [ ] 2.4 Open PR
```

phased delivery graph sample:
```markdown
### Phased delivery (R16–R23)
| Phase | Contents | Depends on | Parallel with |
|----|----------|------------|---------------|
| 1 | Description of task number one | — | — |
| 2 | Description of task number two | Phase 1 merged | — |
```
