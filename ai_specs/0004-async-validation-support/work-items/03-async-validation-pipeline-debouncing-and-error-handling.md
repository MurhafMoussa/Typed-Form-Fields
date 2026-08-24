---
type: Work Item
title: Async Validation Pipeline, Debouncing, Cancellation, and Error Handling
parent: ../spec.md
---

## What to build
Update `TypedFormController` constructor to accept optional `Duration asyncDebounceDelay = const Duration(milliseconds: 300)` and `void Function(Object error, StackTrace stackTrace, String fieldName)? onAsyncValidationError`. Implement sync-first validation logic in `FormValidator` or `TypedFormController`: if sync validators fail for a field, skip running async validators for that field. Implement per-field debouncing using `asyncDebounceDelay`. Implement request cancellation for stale pending async validations when a field value changes before the previous check finishes. Track `validatingFields` on `TypedFormState` when async validation starts and remove fields when validation completes or fails. Handle uncaught exceptions during async validation by setting localized fallback error on the field, clearing `validatingFields`, and invoking `onAsyncValidationError` if provided. Write unit tests covering sync-first rules, debouncing, request cancellation, exception handling, and `validatingFields` transitions.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_validator.dart`

## Acceptance criteria
- [x] `TypedFormController` supports `asyncDebounceDelay` and `onAsyncValidationError`.
- [x] Synchronous validation runs first; if sync validation fails, async validation is skipped.
- [x] Debouncing delays async validator execution by `asyncDebounceDelay`.
- [x] Fast value updates cancel previous pending async tasks for that field without emitting stale errors.
- [x] Field names enter `validatingFields` during active async validation and leave when completed or failed.
- [x] Exceptions in async validators set a localized fallback error, clear the field from `validatingFields`, and trigger `onAsyncValidationError`.
- [x] Unit tests cover sync-first pipeline, debouncing, cancellation, and exception handling.

## Covers
- User Stories: 1, 3
- Requirements: 2, 3, 6
- Technical Decisions: 2
- Testing Strategy: 1
- Interview Ledger: L1, L2, L3

## Blocked by
1, 2
