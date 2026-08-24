---
type: Work Item
title: Dynamic Form Untouched Field State Preservation
parent: ../spec.md
---

## What to build
Modify `TypedFieldWrapper` (`lib/src/widgets/typed_field_wrapper.dart`) so that setting initial values or registering fields on wrapper mount or frame callbacks maintains untouched status (`touched = false`). Update `DynamicFormScreen` field creation so newly added dynamic fields initialize with `touchedFields[fieldName] = false`. Configure `DynamicFormScreen` validation strategy so validation errors remain hidden until `isTouched(fieldName) == true` or form submission occurs.

## Required context
- `lib/src/widgets/typed_field_wrapper.dart`
- `example/lib/src/screens/dynamic_form_screen.dart`
- `test/src/widgets/typed_field_wrapper_test.dart`
- `test/integration/dynamic_form_integration_test.dart`

## Acceptance criteria
- [ ] Initial field value registration in `TypedFieldWrapper` preserves `isTouched(fieldName) == false`.
- [ ] `DynamicFormScreen` adds and removes fields dynamically with `touched == false`.
- [ ] Validation error messages in `DynamicFormScreen` do not display before user field interaction or form submission.
- [ ] Existing `typed_field_wrapper_test.dart` and `dynamic_form_integration_test.dart` tests pass via `flutter test`.

## Covers
- User Stories: 4
- Requirements: 4
- Interview Ledger: L4

## Blocked by
None - ready to start
