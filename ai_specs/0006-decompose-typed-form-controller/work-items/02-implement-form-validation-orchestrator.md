---
type: Work Item
title: Implement FormValidationOrchestrator Helper & Unit Tests
parent: ../spec.md
---

## What to build
Create package-private `FormValidationOrchestrator` in `lib/src/core/form_validation_orchestrator.dart`. Encapsulate validation strategy dispatch routines (`onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, `realTimeOnly`, `disabled`) and group/subset validation routines (`validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, `touchGroup`). Initialize `FormValidationOrchestrator` with references to `FormFieldRegistry`, `FormTouchedTracker`, and `FormValidator`. Add comprehensive unit tests in `test/src/core/form_validation_orchestrator_test.dart` with 100% test coverage. Ensure `FormValidationOrchestrator` is NOT exported in `lib/typed_form_fields.dart`.

## Required context
- `lib/src/core/form_validation_orchestrator.dart`
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_field_registry.dart`
- `lib/src/core/form_touched_tracker.dart`
- `lib/src/core/form_validator.dart`
- `test/src/core/form_validation_orchestrator_test.dart`

## Acceptance criteria
- [x] `FormValidationOrchestrator` is created in `lib/src/core/form_validation_orchestrator.dart` as a package-private helper.
- [x] Strategy dispatch routines and group/subset validation routines (`validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, `touchGroup`) are encapsulated in `FormValidationOrchestrator`.
- [x] `FormValidationOrchestrator` is NOT exported in `lib/typed_form_fields.dart`.
- [x] Isolated unit tests in `test/src/core/form_validation_orchestrator_test.dart` achieve 100% line coverage for `FormValidationOrchestrator`.

## Covers
- User Stories: 1
- Requirements: 2, 4
- Interview Ledger: L1, L2

## Blocked by
- 01-separate-typed-form-state.md
