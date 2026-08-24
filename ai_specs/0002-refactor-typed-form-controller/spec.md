---
type: Spec
title: Refactor TypedFormController God Class
---

## Problem

`TypedFormController` (`lib/src/core/typed_form_controller.dart`) has grown into a large class (~743 lines) responsible for multiple distinct concerns:
1. Maintaining form field definitions, validator creation, and field type lookups.
2. Tracking field touched state across initialization, updates, touch-all, and resets.
3. Orchestrating state updates, debounced validation, and Cubit emissions.
4. Handling dynamic field addition and removal with exception throwing.

This high level of coupling makes internal controller maintenance difficult and increases risk when changing internal validation or lifecycle logic.

## Proposed Outcome

A clean, modular `TypedFormController` that acts as a thin public Cubit facade while delegating field storage and touched state tracking to two dedicated, package-private helper classes (`FormFieldRegistry` and `FormTouchedTracker`).
- Zero public API breaks: `TypedFormController`, `TypedFormState`, public widget contracts, and exported signatures remain 100% backward compatible.
- Reduced controller size: `TypedFormController` delegates field lookups, exception checks, and touched tracking.
- Isolated testability: `FormFieldRegistry` and `FormTouchedTracker` have dedicated unit tests alongside existing public controller tests.

## User Stories

1. As a package maintainer, I want `TypedFormController` decomposed into single-responsibility internal helpers so that I can modify field management or touched-state tracking safely without risking Cubit state orchestration logic. [L1, L2]
2. As a package consumer, I want `TypedFormController` to retain its existing public API surface and behavioral contract so that upgrading the package requires zero breaking changes in my app code. [L1, L6]

## Requirements

1. **Facade & Public API Preservation**: `TypedFormController` must retain its canonical position as the sole `Cubit<TypedFormState>` and public API facade. All public methods (`getValue`, `updateField`, `updateFieldWithDebounce`, `updateFields`, `updateFieldValidators`, `setValidationStrategy`, `validateForm`, `validateFieldImmediately`, `resetForm`, `touchAllFields`, `updateError`, `updateErrors`, `addField`, `addFields`, `removeField`, `removeFields`, `close`) and constructor parameters must remain backward compatible. [L1, L2]
2. **Field Registry Helper**: Create package-private `FormFieldRegistry` in `lib/src/core/form_field_registry.dart`. It must encapsulate field definition storage (`_fields`), validator maps (`_validators`), type lookups (`fieldTypes`), existence checks (`containsField`), and throwing typed `FormFieldError` exceptions (`fieldNotFound`, `fieldAlreadyExists`). `checkFieldExists` must accept `currentValues` (or state context) to preserve complete exception debug info. `FormFieldRegistry` must expose `validators` and `fieldTypes` getters, support updating field validators (`updateFieldValidators`), and provide atomic existence checks for single and batch field additions. [L2, L4]
3. **Touched Tracker Helper**: Create package-private `FormTouchedTracker` in `lib/src/core/form_touched_tracker.dart`. It must encapsulate field touched state management exposing `initialize`, `markTouched`, `markAllTouched`, `reset`, `remove`/`removeFields`, `isTouched`, and an unmodifiable view of touched fields (`touchedFields`). [L2, L5]
4. **Package Visibility Boundary**: `FormFieldRegistry` and `FormTouchedTracker` must remain internal to `lib/src/core/` and MUST NOT be exported in `lib/typed_form_fields.dart`. [L2, L6]
5. **No Fine-Grained Micro-Services**: Do not re-introduce external micro-services or split state management across multiple public Cubits/BLoCs. [L1]

## Technical Decisions

- **Internal Delegation**: `TypedFormController` holds instances of `FormFieldRegistry`, `FormTouchedTracker`, and `FormValidator`. It routes field queries to `FormFieldRegistry`, touched operations to `FormTouchedTracker`, and validation logic to `FormValidator`. [L1, L2, L4, L5]
- **State Immutability**: All state updates emit new immutable `TypedFormState` instances created via `copyWith` using updated values, errors, and validity flags. [L1, L2]

## Testing Strategy

- **Public Contract Regression**: Retain and run `test/src/core/typed_form_controller_test.dart` to verify zero behavioral regressions across all validation strategies, dynamic field mutations, and resets. [L3]
- **Isolated Unit Testing**: Add unit tests in `test/src/core/form_field_registry_test.dart` for `FormFieldRegistry` and `test/src/core/form_touched_tracker_test.dart` for `FormTouchedTracker`. [L3]
- **Verification Commands**: Run `flutter analyze` for static analysis and `flutter test` for full test suite validation. [L3]

## Out of Scope

- Modifying `TypedFormState` fields or methods.
- Modifying `FormValidator` or validator implementations.
- Modifying public widgets (`TypedFormProvider`, `TypedFieldWrapper`, pre-built input widgets).
