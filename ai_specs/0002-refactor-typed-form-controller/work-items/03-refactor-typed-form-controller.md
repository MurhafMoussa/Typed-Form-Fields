---
type: Work Item
title: Refactor TypedFormController to Delegate to Internal Helpers
parent: ../spec.md
---

## What to build
Refactor `TypedFormController` in `lib/src/core/typed_form_controller.dart` to delegate field definition management, validator lookups, and exception throwing to `FormFieldRegistry` and touched state tracking to `FormTouchedTracker`. Ensure no raw maps for fields or touched flags are directly managed inside `TypedFormController`. Ensure `FormFieldRegistry` and `FormTouchedTracker` remain internal to `lib/src/core/` and are NOT exported in `lib/typed_form_fields.dart`. Verify zero breaking changes to public Cubit methods and state emissions.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_field_registry.dart`
- `lib/src/core/form_touched_tracker.dart`
- `lib/typed_form_fields.dart`
- `test/src/core/typed_form_controller_test.dart`

## Acceptance criteria
- [ ] `TypedFormController` delegates field management to `FormFieldRegistry` and touched tracking to `FormTouchedTracker`.
- [ ] `FormFieldRegistry` and `FormTouchedTracker` are NOT exported in `lib/typed_form_fields.dart`.
- [ ] All public API signatures, constructor parameters, and `TypedFormState` remain unchanged.
- [ ] Existing controller test suite (`test/src/core/typed_form_controller_test.dart`) passes completely without regression.
- [ ] `flutter analyze` passes with zero issues.

## Covers
- User Stories: 1, 2
- Requirements: 1, 4, 5
- Technical Decisions
- Testing Strategy: 1, 3
- Interview Ledger: L1, L2, L3, L6

## Blocked by
- 01-implement-form-field-registry.md
- 02-implement-form-touched-tracker.md
