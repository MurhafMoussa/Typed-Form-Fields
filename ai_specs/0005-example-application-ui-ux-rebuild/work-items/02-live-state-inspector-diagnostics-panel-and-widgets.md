---
type: Work Item
title: Live State Inspector, Diagnostics Panel, and Shared Showcase Components
parent: ../spec.md
---

## What to build
Build shared inspector and diagnostic components under `example/lib/src/widgets/` featuring the reusable dual-pane `InspectorPanel` styled with Shadcn UI cards, tabs, and badges, real-time JSON tree viewer (`TypedFormState`, field values, error messages, touched statuses, `isDirty`, `isValid`, `validatingFields`, `isValidating`), dynamic `ValidationStrategy` dropdown switcher, form diagnostic actions (Reset Form, Validate Form/Group, Mark All Touched), and scrollable `EventLogWidget` recording state transitions and async validation events.

## Required context
- `example/lib/src/shell/`
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [x] Reusable `InspectorPanel` implemented with Shadcn UI card styling, split side-by-side view on desktop/tablet, and tabbed/collapsible view on mobile.
- [x] Real-time formatted JSON tree viewer displays `TypedFormState`: values, errors, touched flags, `isDirty`, `isValid`, `validatingFields`, and `isValidating`.
- [x] Interactive `ValidationStrategy` dropdown selector allows dynamically switching active strategy (`realTimeOnly`, `onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, `disabled`).
- [x] Action buttons for Reset Form, Validate Form / Group, and Mark All Touched are functional and trigger appropriate controller methods.
- [x] Scrollable `EventLogWidget` records live form state transitions, validation triggers, and async validation pipeline state changes.

## Covers
- User Stories: 2, 3
- Requirements: 2, 3
- Technical Decisions: 1
- Testing Strategy: 4
- Interview Ledger: L1, L3, L5

## Blocked by
- 01-example-app-architecture-theme-shell-and-navigation.md
