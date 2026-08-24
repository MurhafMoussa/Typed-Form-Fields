---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: Should we expand the library to natively support async validation alongside sync validation?

Recommended Answer:
- Validator Contract: Introduce `AsyncValidator<T>` (or update `Validator<T>` / support `FutureOr<String?>`) so a field can execute both synchronous rules and asynchronous checks.
- Execution Sequence: Run synchronous validators first. If sync validation fails, skip async validation for that field to avoid unnecessary network/async calls.
- Form State: Add `validatingFields` (`Set<String>`) and an `isValidating` getter (`bool`) to `TypedFormState`.
- Submission Rule: If form submission is triggered while async validation is in progress, await all pending async validations before determining final validity and proceeding.
- Reset & Cleanup: Resetting the form cancels all active debounced or pending async validation tasks and clears `validatingFields`.

Answer: Yes, native async validation is desired.

Decision: Expand library to natively support async validation with state tracking and pending execution rules.

Reason: Running sync validation first avoids unnecessary async/network calls, while tracking `validatingFields` allows UI feedback during pending validations.

### L2

Status: current

Question: Should we build native async validation directly into the library, or document a recommended pattern using external BLoC/controller state?

Recommended Answer:
- Add native Async Validation support directly to `Typed-Form-Fields`.
- Introduce `AsyncValidator<T>` (or `FutureOr<String?> Function(T?, BuildContext)`).
- Expose `isValidating` and `validatingFields` on `TypedFormState`.
- Support configurable `asyncDebounceDelay` (default 300ms).
- Auto-cancel stale pending requests when field values change before previous async validation completes.
- Non-Goals: No automatic retry mechanisms or offline caching in the form layer.

Answer: Add native async validation support directly to the library.

Decision: Native async validation built directly into `Typed-Form-Fields`.

Reason: Integrating async validation natively solves state-wiping and race condition bugs internally, giving developers a clean, safe, and declarative API.

### L3

Status: current

Question: How should uncaught exceptions or network errors thrown during async validation be handled?

Recommended Answer:
- Error Catching: Catch all uncaught exceptions thrown during async validation execution.
- Fallback Error Message: Record a fallback validation error message on that field using `ValidatorLocalizations.of(context).asyncValidationError` (or a configurable per-validator error message).
- State Transition: Immediately remove the field from `validatingFields` when an exception occurs, ensuring `isValidating` clears cleanly.
- Logging: Log the exception internally or forward it to an optional `onAsyncValidationError` handler on `TypedFormController`.

Answer: Handled with fallback error message and state cleanup.

Decision: Gracefully handle async validation exceptions without crashing or locking state.

Reason: Network or unexpected server failures should not crash the widget tree or leave the form stuck in a perpetual loading/validating state (`isValidating == true`).
