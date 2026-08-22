---
type: Work Item
title: Consolidate Micro-Services into FormValidator and TypedFormController
parent: ../spec.md
---

## What to build
Consolidate the 10 internal micro-services (`field_lifecycle.dart`, `validation_execution.dart`, `error_management.dart`, `field_registry.dart`, `field_mutations.dart`, `field_tracking.dart`, `state_calculation.dart`, `submission_handling.dart`, `validation_coordination.dart`, `validation_debounce.dart`) into `FormValidator` (`lib/src/core/form_validator.dart`) and `TypedFormController` (`lib/src/core/typed_form_controller.dart`). `FormValidator` handles validation routines, strategy rules, and debouncing timer lifecycle (with automatic disposal on teardown). `TypedFormController` manages form values, field registry, submission, touched state, and state emission directly. Remove obsolete micro-service constructor parameters from `TypedFormController`. Delete all 10 micro-service files from `lib/src/services/` and update `lib/typed_form_fields.dart` to remove exports of deleted micro-services and export `FormValidator`.

## Required context
- `lib/src/core/typed_form_controller.dart`
- `lib/src/core/form_validator.dart` (new)
- `lib/src/services/*` (10 micro-services to delete)
- `lib/typed_form_fields.dart`

## Acceptance criteria
- [ ] `FormValidator` is created at `lib/src/core/form_validator.dart` encapsulating validation rules, strategy coordination, and debouncing timers.
- [ ] `TypedFormController` handles form lifecycle, values, touched fields, and state emission directly using `FormValidator`.
- [ ] Debouncing timers are cleanly disposed when `TypedFormController.close()` is called.
- [ ] All 10 internal micro-service files in `lib/src/services/` are deleted.
- [ ] Obsolete internal micro-service constructor injection parameters are removed from `TypedFormController`.
- [ ] `lib/typed_form_fields.dart` exports are updated to remove deleted micro-services and export `FormValidator`.
- [ ] All public-facing APIs (`getValue`, `updateField`, `validateForm`, etc.) remain 100% backward compatible.

## Covers
- User Stories: 1
- Requirements: 1, 3, 4, 6
- Interview Ledger: L1, L2, L5

## Blocked by
- 01-convert-models-remove-codegen.md
- 02-cleanup-duplicate-validators-exports.md
