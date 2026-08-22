---
type: Work Item
title: Implement FormFieldRegistry Helper and Unit Tests
parent: ../spec.md
---

## What to build
Create package-private `FormFieldRegistry` class in `lib/src/core/form_field_registry.dart`. It encapsulates field definition storage (`_fields`), validator maps (`_validators`), type lookups (`fieldTypes`), existence checks (`containsField`), and throwing typed `FormFieldError` exceptions (`fieldNotFound`, `fieldAlreadyExists`). `checkFieldExists` must accept current values/state context to preserve debug information on exception throwing. Expose `validators` and `fieldTypes` getters, support updating field validators (`updateFieldValidators`), and provide atomic existence checks for single and batch field additions/removals. Add dedicated unit tests in `test/src/core/form_field_registry_test.dart`.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_errors.dart`
- `lib/src/models/form_field_definition.dart`

## Acceptance criteria
- [x] Package-private `FormFieldRegistry` class created in `lib/src/core/form_field_registry.dart`.
- [x] Encapsulates field storage, validator creation and updating, type lookups, and `checkFieldExists` exception checks.
- [x] Atomically handles existence checks when registering single or multiple fields, throwing `FormFieldError.fieldAlreadyExists`.
- [x] `checkFieldExists` throws `FormFieldError.fieldNotFound` with complete context (`availableFields`, `fieldTypes`, `currentValues`).
- [x] Unit tests in `test/src/core/form_field_registry_test.dart` achieve complete coverage of registry functionality.

## Covers
- Requirements: 2, 4
- Testing Strategy: 2
- Interview Ledger: L2, L4, L6

## Blocked by
None - ready to start
