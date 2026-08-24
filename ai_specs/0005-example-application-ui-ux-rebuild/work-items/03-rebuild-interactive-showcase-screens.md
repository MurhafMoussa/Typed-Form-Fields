---
type: Work Item
title: Rebuild Interactive Showcase Screens with Shadcn UI Form Controls
parent: ../spec.md
---

## What to build
Rebuild the 4 consolidated showcase screens in `example/lib/src/screens/` with Shadcn UI styled input controls and dual-pane layout integrating the `InspectorPanel`: `registration_form_screen.dart` (cross-field password matching, simulated async username/email availability check with loading indicators and debounce control, BLoC toggle), `widget_gallery_screen.dart` (pre-built typed widgets and custom `FieldWrapper`), `multi_step_form_screen.dart` (step-based `fieldGroup` partial validation wizard), and `dynamic_form_screen.dart` (runtime form array manipulation).

## Required context
- `example/lib/src/widgets/`
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [ ] `registration_form_screen.dart` showcases registration with cross-field password validation, simulated async availability check with loading indicators, and optional BLoC integration.
- [ ] `widget_gallery_screen.dart` displays gallery of all pre-built typed input widgets and custom `FieldWrapper` components styled with Shadcn UI aesthetics.
- [ ] `multi_step_form_screen.dart` demonstrates step-by-step form wizard using `fieldGroup` partial validation.
- [ ] `dynamic_form_screen.dart` demonstrates dynamic form array manipulation (add, remove, reorder fields at runtime).
- [ ] All 4 showcase screens incorporate the dual-pane layout with Live Form Preview and `InspectorPanel`.

## Covers
- User Stories: 1, 2, 3
- Requirements: 2, 4
- Technical Decisions: 1
- Testing Strategy: 4
- Interview Ledger: L1, L3, L4, L5

## Blocked by
- 01-example-app-architecture-theme-shell-and-navigation.md
- 02-live-state-inspector-diagnostics-panel-and-widgets.md
