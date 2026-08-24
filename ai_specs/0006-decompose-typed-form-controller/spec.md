---
type: Spec
title: Decompose TypedFormController Below 1000 LOC
---

## Problem

`TypedFormController` (`lib/src/core/typed_form_controller.dart`) has grown beyond 1,200 lines of code. It contains duplicated validation strategy branching (`switch (state.validationStrategy)` across `updateField`, `updateFieldWithDebounce`, `updateFields`, and `updateFieldValidators`) as well as group and subset validation logic. This complexity increases maintenance risk and makes the core form controller harder to maintain and test.

## Proposed Outcome

Decompose `TypedFormController` into a lightweight `Cubit<TypedFormState>` facade (~350–400 LOC) by extracting an internal `FormValidationOrchestrator` helper in `lib/src/core/form_validation_orchestrator.dart` and separating `TypedFormState` into a standalone top-level file. All public APIs, constructors, and widget interactions remain 100% backward compatible.

## User Stories

1. As a package maintainer, I want `TypedFormController` decomposed into single-responsibility internal helpers so that strategy dispatch and group validation logic are isolated and `TypedFormController` stays under 400 LOC. [L1, L2]
2. As a package consumer, I want `TypedFormController` to maintain 100% backward compatibility so that my application code and custom form widgets continue working without any modifications. [L1]

## Requirements

1. **Public API & Facade Preservation**:
   - `TypedFormController` must retain its canonical role as the public `Cubit<TypedFormState>` entry point.
   - All public methods (`getValue`, `updateField`, `updateFieldWithDebounce`, `updateFields`, `updateFieldValidators`, `setValidationStrategy`, `validateForm`, `validateFieldImmediately`, `resetForm`, `touchAllFields`, `validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, `touchGroup`, `updateError`, `updateErrors`, `addField`, `addFields`, `removeField`, `removeFields`, `close`) and constructor parameters must remain 100% backward compatible. [L1]

2. **FormValidationOrchestrator Helper**:
   - Introduce package-private `FormValidationOrchestrator` in `lib/src/core/form_validation_orchestrator.dart`.
   - Encapsulate strategy dispatch (`onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, `realTimeOnly`, `disabled`) for field updates (`updateField`, `updateFieldWithDebounce`, `updateFields`, `updateFieldValidators`). [L1, L2]
   - Encapsulate group and subset validation routines (`validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, `touchGroup`). [L2]

3. **TypedFormState Standalone Separation**:
   - Move `TypedFormState` from `part 'typed_form_state.dart'` to a standalone top-level class in `lib/src/core/typed_form_state.dart`.
   - Ensure `TypedFormState` is exported via `lib/typed_form_fields.dart` and re-exported in `lib/src/core/typed_form_controller.dart` (`export 'typed_form_state.dart';`) to preserve full backward compatibility for both package-level and direct file-level imports. [L1]

4. **Package Visibility Boundary**:
   - `FormValidationOrchestrator` must remain internal to `lib/src/core/` and MUST NOT be exported in `lib/typed_form_fields.dart`. [L2]

## Technical Decisions

1. **Internal Delegation Architecture**:
   - `TypedFormController` holds references to `FormFieldRegistry`, `FormTouchedTracker`, `FormValidator`, and `FormValidationOrchestrator`.
   - `FormValidationOrchestrator` is initialized with references to `FormFieldRegistry`, `FormTouchedTracker`, and `FormValidator`. It accepts current state, context, and async validation scheduling callbacks to execute strategy dispatch and group/subset validation routines cleanly without circular dependencies.
   - Field queries route to `FormFieldRegistry`, touched operations route to `FormTouchedTracker`, low-level validation routines route to `FormValidator`, and strategy dispatch / group evaluation route to `FormValidationOrchestrator`. [L1, L2]

2. **Line Count Target**:
   - `TypedFormController` line count is reduced from >1,200 LOC to ~350–400 LOC. [L2]

## Testing Strategy

1. **Unit Testing**:
   - Add isolated unit tests for `FormValidationOrchestrator` in `test/src/core/form_validation_orchestrator_test.dart`. [L2]
   - Update imports in `test/src/models/typed_form_state_test.dart` to reference `package:typed_form_fields/src/core/typed_form_state.dart`.
   - Maintain 100% line coverage for `TypedFormController`, `FormValidator`, and `FormValidationOrchestrator`. [L1, L2]

2. **Regression Verification**:
   - Run existing unit and integration test suites (`flutter test`) to ensure zero behavioral regressions. [L1]

3. **Line Count Verification**:
   - Verify that `lib/src/core/typed_form_controller.dart` line count is reduced from >1,200 LOC to under 400 LOC (~350–400 LOC target). [L2]

## Out of Scope

- Modifying public `TypedFormState` fields or methods.
- Modifying `FormValidator` or validator implementations.
- Modifying public widgets (`TypedFormProvider`, `TypedFieldWrapper`).
