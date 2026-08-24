---
type: Spec
title: Native Async Validation Support
---

## Problem

`Typed-Form-Fields` currently only supports synchronous form validation via `Validator<T>.validate(...)`. When developers need async validation (such as backend username or email availability checks):
1. Subsequent synchronous state updates overwrite externally injected async validation errors.
2. Rapid typing causes race conditions where stale async responses overwrite newer field values.
3. Form submissions can occur while async checks are still in flight, because `TypedFormState` lacks `isValidating` or `validatingFields` tracking.

## Proposed Outcome

Introduce native asynchronous validation support into `Typed-Form-Fields` with state tracking (`validatingFields`, `isValidating`), automatic debouncing and request cancellation, sync-first execution pipelines, and robust exception handling.

## User Stories

1. As a developer, I want to attach asynchronous validators to form fields alongside synchronous validators so that I can validate remote conditions (e.g. email availability) declaratively.
2. As a user, I want visual feedback (loading indicators) while async validation is in progress so that I know the form is verifying my input.
3. As a user, I don't want fast typing to trigger wasteful network requests or produce out-of-order stale errors.
4. As a user, submitting a form while async validation is running should wait for validation to complete before deciding if submission can proceed.

## Requirements

1. **Validator Interface & Integration**:
   - Introduce `AsyncValidator<T>` as `abstract class AsyncValidator<T>` (or `FutureOr<String?> Function(T?, BuildContext)` signature) with `FutureOr<String?> validate(T? value, BuildContext context)`. [L1, L2]
   - Update `FormFieldDefinition<T>` to accept `List<AsyncValidator<T>>? asyncValidators` alongside existing synchronous `validators`. [L1]

2. **Sync-First Execution Pipeline**:
   - Run synchronous validation rules before initiating async validation. [L1]
   - If synchronous validation fails for a field, skip running async validation for that field. [L1]

3. **Debouncing & Cancellation**:
   - Apply debouncing via configurable `asyncDebounceDelay` (defaulting to `Duration(milliseconds: 300)` on `TypedFormController`) before executing async validators. [L2]
   - Cancel stale pending async validation tasks automatically when field values change before previous async checks complete. [L2]

4. **Form State Tracking & UI Wrapper**:
   - Extend `TypedFormState` with `validatingFields` (`Set<String>`, defaulting to `{}`) and an `isValidating` getter (`bool`, true when `validatingFields.isNotEmpty`). [L1, L2]
   - Add field names to `validatingFields` when async validation begins, and remove them when validation completes or fails. [L1, L3]
   - Update `TypedFieldWrapper<T>` to inspect `validatingFields` in `buildWhen`/`listenWhen` and pass `bool isValidating` to its `builder` callback signature: `Widget Function(BuildContext context, T? value, String? error, bool hasError, bool isValidating, void Function(T? value) updateValue)`. [L2]

5. **Submission & Reset Lifecycle**:
   - When form submission (`validateForm` or submission trigger) occurs during active debouncing or async validation, immediately flush any active debounce timers and await all pending async validations before evaluating final validity. [L1]
   - Resetting the form cancels all active debounced or pending async validation tasks and clears `validatingFields`. [L1]

6. **Error & Exception Handling**:
   - Catch uncaught exceptions thrown during async validation execution. [L3]
   - When an exception occurs, set a fallback error message on the field (using `ValidatorLocalizations.of(context).asyncValidationError` or a custom fallback) and remove the field from `validatingFields`. [L3]
   - Forward caught async validation exceptions to an optional `onAsyncValidationError` callback (`void Function(Object error, StackTrace stackTrace, String fieldName)?`) on `TypedFormController`. [L3]

## Technical Decisions

1. **State Immutability & Equality**:
   - `TypedFormState` updated to store `validatingFields` (`Set<String>`).
   - `TypedFormState.copyWith`, `operator ==`, `hashCode` (using `SetEquality`), and `toString` updated to include `validatingFields`. [L1, L2]

2. **Controller Lifecycle & API**:
   - `TypedFormController` constructor updated with optional parameters: `Duration asyncDebounceDelay = const Duration(milliseconds: 300)` and `void Function(Object error, StackTrace stackTrace, String fieldName)? onAsyncValidationError`. [L2, L3]
   - `FormValidator` updated with async task tracking map (`Map<String, CancelableOperation>` or `Timer` + token mechanism) for per-field cancellation. [L2]
   - Form submission logic updated to flush active timers and `await` pending async operations when `isValidating == true`. [L1]

3. **Domain Vocabulary**:
   - Updated `GLOSSARY.md` with canonical definition for `Async Validator`.

## Testing Strategy

1. **Unit Tests**:
   - Test sync-first rule: verify async validator is not called when sync validator fails. [L1]
   - Test debouncing and cancellation: verify typing fast cancels previous pending async calls and only completes the latest. [L2]
   - Test exception handling: verify thrown exception produces localized fallback error, fires `onAsyncValidationError`, and clears `validatingFields`. [L3]
   - Test state updates: verify `validatingFields` and `isValidating` transitions during async lifecycle and state equality (`==`). [L1, L2]

2. **Integration Tests**:
   - Test form submission while async validation is in flight or debounced: verify submission flushes timers, waits for async completion, and evaluates validity accurately. [L1]
   - Test form reset during active async validation: verify pending tasks cancel and state clears immediately. [L1]
   - Test `TypedFieldWrapper` visual updates: verify wrapper triggers rebuild and exposes `isValidating == true` to builder when field is validating. [L2]

## Out of Scope

- Offline caching or retry mechanisms for failed network calls during async validation (handled by client API layer). [L2]
