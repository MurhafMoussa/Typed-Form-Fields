---
type: Work Item
title: Example App Architecture, Shadcn UI Theme, Shell, and Navigation Setup
parent: ../spec.md
---

## What to build
Refactor `example/` structure under `example/lib/src/theme/` and `example/lib/src/shell/`. Implement Shadcn UI theme tokens (Slate/Zinc neutral palettes, subtle 1px borders, dark/light/system theme mode toggle) with a `ValueNotifier` state controller, responsive `AppShell` (`NavigationRail`/`Drawer` on desktop/tablet, `NavigationBar` on mobile), top app bar with theme toggle, locale dropdown selector (EN, ES, FR, DE, AR with RTL support for Arabic), GitHub repository link, and canonical hash routes (`/registration`, `/widget-gallery`, `/multi-step`, `/dynamic-form`, `/docs/...`).

## Required context
- `example/lib/main.dart`
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [x] Clean architecture layout created under `example/lib/src/theme/` and `example/lib/src/shell/`.
- [x] Shadcn UI theme tokens (Slate/Zinc neutral color scheme, subtle 1px borders) configured for light and dark modes with `ValueNotifier` state management for theme mode switching.
- [x] Responsive `AppShell` uses `NavigationRail`/`Drawer` for wider viewports and `NavigationBar` for mobile viewports.
- [x] Top app bar includes theme toggle button, locale switcher dropdown (supporting EN, ES, FR, DE, AR with RTL support for AR), search button placeholder, and GitHub repo link.
- [x] Hash-based routing configured in `MaterialApp` with canonical named route constants (`/registration`, `/widget-gallery`, `/multi-step`, `/dynamic-form`, `/docs/...`).

## Covers
- User Stories: 1
- Requirements: 1
- Technical Decisions: 1, 2
- Testing Strategy: 4
- Interview Ledger: L1

## Blocked by
None - ready to start
