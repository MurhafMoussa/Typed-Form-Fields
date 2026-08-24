---
type: Work Item
title: Delegate TypedFormController to FormValidationOrchestrator & Verify LOC Targets
parent: ../spec.md
---

## What to build
Refactor `TypedFormController` in `lib/src/core/typed_form_controller.dart` to delegate validation strategy dispatch and group evaluation routines to `FormValidationOrchestrator`. Retain `TypedFormController` as a lightweight `Cubit<TypedFormState>` facade preserving 100% backward compatibility for all public methods, constructor parameters, and widget interactions. Verify that `TypedFormController` line count is reduced from >1,200 LOC to under 400 LOC (~350–400 LOC target). Run `flutter test` to ensure zero behavioral regressions across all unit and integration tests.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_validation_orchestrator.dart`
- `test/src/core/typed_form_controller_test.dart`

## Acceptance criteria
- [x] `TypedFormController` delegates strategy dispatch and group validation routines to `FormValidationOrchestrator`.
- [x] All public API methods (`getValue`, `updateField`, `updateFieldWithDebounce`, `updateFields`, `updateFieldValidators`, `setValidationStrategy`, `validateForm`, `validateFieldImmediately`, `resetForm`, `touchAllFields`, `validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, `touchGroup`, `updateError`, `updateErrors`, `addField`, `addFields`, `removeField`, `removeFields`, `close`) retain 100% backward compatibility.
- [x] Line count for `lib/src/core/typed_form_controller.dart` is under 400 LOC.
- [x] All unit and integration test suites (`flutter test`) pass with zero regressions.

## Covers
- User Stories: 1, 2
- Requirements: 1, 2, 4
- Technical Decisions: 1, 2
- Testing Strategy: 1, 2, 3
- Interview Ledger: L1, L2

## Blocked by
- 02-implement-form-validation-orchestrator.md
