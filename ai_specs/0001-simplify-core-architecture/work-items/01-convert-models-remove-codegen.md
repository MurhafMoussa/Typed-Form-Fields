---
type: Work Item
title: Convert Models to Pure Dart Immutable Classes & Remove Codegen
parent: ../spec.md
---

## What to build
Replace Freezed data models (`TypedFormState` in `lib/src/core/typed_form_state.dart` and `FormFieldDefinition` in `lib/src/models/form_field_definition.dart`) with plain, immutable Dart classes with custom `copyWith`, `operator ==`, and `hashCode`. `TypedFormState`'s `operator ==` and `hashCode` must use deep collection equality (e.g. `MapEquality` from `package:collection`) for `values`, `errors`, and `fieldTypes`. Remove `.freezed.dart` files and eliminate `freezed`, `freezed_annotation`, `build_runner`, `json_serializable`, and `equatable` (if no longer used) from `pubspec.yaml`.

## Required context
- `lib/src/core/typed_form_state.dart`
- `lib/src/models/form_field_definition.dart`
- `pubspec.yaml`

## Acceptance criteria
- [x] `TypedFormState` and `FormFieldDefinition` are pure Dart immutable classes with custom `copyWith`, `operator ==`, and `hashCode` without code generation annotations.
- [x] `TypedFormState.operator ==` correctly compares `values`, `errors`, and `fieldTypes` using deep collection equality.
- [x] `lib/src/core/typed_form_controller.freezed.dart` and `lib/src/models/form_field_definition.freezed.dart` are deleted.
- [x] `freezed`, `freezed_annotation`, `build_runner`, and `json_serializable` are removed from `pubspec.yaml`.
- [x] Existing model tests in `test/src/models/typed_form_state_test.dart` pass without code generation.

## Covers
- User Stories: 1
- Requirements: 2
- Interview Ledger: L1, L3

## Blocked by
None - ready to start
