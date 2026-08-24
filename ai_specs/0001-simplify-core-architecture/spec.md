---
type: Spec
title: Simplify Core Architecture and Refactor Micro-Services
---

## Problem

The current `typed_form_fields` implementation suffers from over-engineering:
1. 10 micro-services (`field_lifecycle.dart`, `validation_execution.dart`, `error_management.dart`, `field_registry.dart`, `field_mutations.dart`, `field_tracking.dart`, `state_calculation.dart`, `submission_handling.dart`, `validation_coordination.dart`, `validation_debounce.dart`) introduce excessive abstraction layers and boilerplate.
2. Code generation (`freezed`, `freezed_annotation`, `build_runner`, `json_serializable`) is used for simple immutable models (`TypedFormState`, `FormFieldDefinition`), causing unnecessary build-runner overhead.
3. Multiple duplicate validator files exist (`common_validators.dart` vs `typed_common_validators.dart`, `conditional_validator.dart` vs `typed_conditional_validator.dart`, `cross_field_validator.dart` vs `typed_cross_field_validator.dart`).
4. Over 10 unit test files test internal micro-service details (`test/src/services/*`), adding high test maintenance overhead without protecting public API contracts.

## Proposed Outcome

A clean, simplified, maintainable form field package that retains high performance and type safety:
- Micro-services consolidated into 2 cohesive, single-responsibility components (`TypedFormController` for state & form lifecycle; `FormValidator` for validation rules, strategy coordination, and debounce timers).
- Code generation eliminated and replaced with pure Dart immutable classes with custom `copyWith`, `operator ==`, and `hashCode`.
- Duplicate validator files deleted, leaving single canonical files.
- Internal service unit tests removed; tests consolidated around public contracts (`TypedFormController`, `TypedFormProvider`, `TypedFieldWrapper`, and Validators).
- 100% backward compatibility for all public-facing APIs and widgets.

## User Stories

1. As a developer using `typed_form_fields`, I want a clean, dependency-free, type-safe form state library without code generation or heavy internal micro-service indirection so that I can easily debug, extend, and maintain forms.
2. As a package maintainer, I want a streamlined test suite that tests public contracts directly so that internal refactorings do not break unit tests unnecessarily.

## Requirements

1. **Service Layer Consolidation**: Merge the 10 micro-service files into 2 primary components: `TypedFormController` (handling value updates, touched state, form lifecycle, and state emission) and `FormValidator` located in `lib/src/core/form_validator.dart` (handling validation execution, cross-field rules, and debounce timers). Remove obsolete internal micro-service constructor parameters from `TypedFormController` while preserving public constructor arguments (`fields`, `validationStrategy`). [L1, L2, L5]
2. **Code Generation Removal**: Replace Freezed models (`TypedFormState`, `FormFieldDefinition`) with plain, immutable Dart classes. Implement explicit `copyWith`, `operator ==`, and `hashCode` ensuring deep collection equality (e.g. `MapEquality`) for map fields (`values`, `errors`, `fieldTypes`). Remove `freezed`, `freezed_annotation`, `build_runner`, and `json_serializable` from `pubspec.yaml` (and `equatable` if unused) and delete `.freezed.dart` files. [L1, L3]
3. **Validator & Export Clean Up**: Delete legacy duplicate validator files (`common_validators.dart`, `conditional_validator.dart`, `cross_field_validator.dart`) and keep canonical implementations (`typed_common_validators.dart`, `typed_conditional_validator.dart`, `typed_cross_field_validator.dart`). Update `lib/typed_form_fields.dart` to remove exports of deleted micro-service files and cleanly export canonical validators and `FormValidator`. [L1, L3]
4. **Debouncing & Lifecycle**: Handle debouncing timers internally within `FormValidator`. Ensure all timers are properly disposed when `TypedFormController` is closed. [L5]
5. **Auxiliary Cleanup**: Remove unused unexported files such as `lib/src/core/cubit.dart` and clean up configuration files. [L6]
6. **Public API Compatibility**: Preserve all existing public widgets (`TypedFormProvider`, `TypedFieldWrapper`, pre-built inputs), `ValidationStrategy`, and public methods (`getValue`, `updateField`, `validateForm`, etc.). [L1, L2, L3]

## Technical Decisions

- **Architectural Pattern**: Adopt a 2-tier architecture balancing SOLID principles and simplicity:
  - `TypedFormController` (Cubit subclass): owns form state, field registry, submission, and lifecycle.
  - `FormValidator` (`lib/src/core/form_validator.dart`): owns field validation routines, strategy rules (`onSubmitOnly`, `onSubmitThenRealTime`, `realTimeOnly`, `allFieldsRealTime`, `disabled`), and debounce timer management.
- **Data Models**: Use pure Dart immutable data classes without external codegen. Implement custom `operator ==` using deep collection equality (`MapEquality`) for `TypedFormState`.

## Testing Strategy

- Delete internal service test suite (`test/src/services/*`). [L4]
- Enhance `test/src/core/typed_form_controller_test.dart`, add `test/src/core/form_validator_test.dart` (if needed for isolated validator & debounce testing), and update `test/integration/form_integration_test.dart` and `test/benchmarks/form_performance_benchmark.dart` to cover all edge cases, strategies, and lifecycle operations through public contracts. [L4]
- Maintain `test/src/validators/*` and `test/src/widgets/*`. [L4]
- Verify whole suite with `flutter test` and static analysis with `flutter analyze`. [L4]

## Out of Scope

- Modifying public widget parameters or UI behavior.
- Altering existing `ValidationStrategy` behavior or error message localizations.
