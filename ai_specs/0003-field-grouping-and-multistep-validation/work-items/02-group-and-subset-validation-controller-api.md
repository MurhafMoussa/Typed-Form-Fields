---
type: Work Item
title: Group and Field Subset Validation Controller and Provider APIs
parent: ../spec.md
---

## What to build
Implement step/group validation, field subset validation, passive validity checking, and group touching APIs on `TypedFormController` and `TypedFormProviderExtension` on `BuildContext`.
- `validateGroup(String groupName, ...)`: Marks fields in group as touched, validates group fields, merges error updates into form state, re-evaluates form `isValid`, triggers `onValidationPass` or `onValidationFail`, and switches `onSubmitThenRealTime` strategy to `realTimeOnly` on validation failure. Unknown/empty groups pass validation cleanly without throwing.
- `validateFields(List<String> fieldNames, ...)`: Marks target fields as touched, validates target fields, merges error updates into form state, re-evaluates form `isValid`, triggers callbacks, and switches strategy on failure. Throws `FormFieldError.fieldNotFound` if any specified field does not exist. Deduplicates input list and handles empty lists cleanly.
- `isGroupValid(String groupName)` & `areFieldsValid(List<String> fieldNames)`: Passive validity checks returning `bool` without modifying `touched` state, without debouncing, and without emitting state updates. Unknown/empty groups or lists return `true`.
- `touchGroup(String groupName)`: Marks fields in group as touched and re-evaluates form state errors and `isValid` status without callbacks or strategy switching. Unknown groups return cleanly.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/widgets/typed_form_provider.dart`
- `lib/src/core/form_field_registry.dart`

## Acceptance criteria
- [ ] `validateGroup` on controller and context extension marks target group fields as touched, merges errors into form state, re-evaluates `isValid`, and triggers `onValidationPass` / `onValidationFail`.
- [ ] `validateGroup` switches `ValidationStrategy.onSubmitThenRealTime` to `realTimeOnly` if group validation fails. Unknown groups return cleanly and pass validation.
- [ ] `validateFields` on controller and context extension marks specified fields as touched, merges error updates, re-evaluates `isValid`, triggers callbacks, and switches strategy on failure.
- [ ] `validateFields` throws `FormFieldError.fieldNotFound` if any specified field name does not exist.
- [ ] `isGroupValid` and `areFieldsValid` passively check validity without altering `touched` state or emitting form state changes.
- [ ] `touchGroup` marks group fields as touched and updates form state without invoking callbacks or switching validation strategies.
- [ ] Unit tests in `test/src/core/typed_form_controller_test.dart` cover `validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, and `touchGroup`.

## Covers
- User Stories: 1, 2, 3
- Requirements: 2, 3, 4, 5
- Interview Ledger: L2, L3, L4, L5

## Blocked by
`01-form-field-definition-grouping-and-registry-indexing.md`
