---
type: Work Item
title: TypedFormState Validating Fields Tracking and TypedFieldWrapper UI Support
parent: ../spec.md
---

## What to build
Extend `TypedFormState` with `validatingFields` (`Set<String>`, defaulting to `{}`) and `bool get isValidating => validatingFields.isNotEmpty`. Update `TypedFormState.copyWith`, `operator ==`, `hashCode` (using `SetEquality`), and `toString()` to incorporate `validatingFields`. Update `TypedFieldWrapper<T>` builder callback signature to: `Widget Function(BuildContext context, T? value, String? error, bool hasError, bool isValidating, void Function(T? value) updateValue)`. Update `TypedFieldWrapper<T>` rebuild logic so that changes to `validatingFields` for the target field trigger widget rebuilds. Add unit tests for `TypedFormState` and widget tests for `TypedFieldWrapper`.

## Required context
- `lib/src/core/typed_form_state.dart`
- `lib/src/widgets/typed_field_wrapper.dart`

## Acceptance criteria
- [x] `TypedFormState` includes `validatingFields` (`Set<String>`) and `isValidating` getter.
- [x] `TypedFormState` `copyWith`, `==`, `hashCode`, and `toString()` properly support `validatingFields`.
- [x] `TypedFieldWrapper<T>` builder callback includes `bool isValidating`.
- [x] `TypedFieldWrapper<T>` rebuilds when its field name enters or exits `validatingFields`.
- [x] Unit tests for `TypedFormState` and widget tests for `TypedFieldWrapper` pass.

## Covers
- User Stories: 2
- Requirements: 4
- Technical Decisions: 1
- Testing Strategy: 1, 2
- Interview Ledger: L1, L2

## Blocked by
None - ready to start
