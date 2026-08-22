---
type: Work Item
title: Clean Up Duplicate Validator Files, Auxiliary Code, & Package Exports
parent: ../spec.md
---

## What to build
Delete legacy duplicate validator files (`lib/src/validators/common_validators.dart`, `lib/src/validators/conditional_validator.dart`, `lib/src/validators/cross_field_validator.dart`) and keep canonical implementations (`typed_common_validators.dart`, `typed_conditional_validator.dart`, `typed_cross_field_validator.dart`). Delete unused auxiliary files such as `lib/src/core/cubit.dart`. Ensure `lib/src/validators/validators.dart` exports all canonical validator files cleanly.

## Required context
- `lib/src/validators/common_validators.dart`
- `lib/src/validators/conditional_validator.dart`
- `lib/src/validators/cross_field_validator.dart`
- `lib/src/validators/validators.dart`
- `lib/src/core/cubit.dart`

## Acceptance criteria
- [ ] Duplicate validator files (`common_validators.dart`, `conditional_validator.dart`, `cross_field_validator.dart`) are deleted from `lib/src/validators/`.
- [ ] Canonical validator files (`typed_common_validators.dart`, `typed_conditional_validator.dart`, `typed_cross_field_validator.dart`) are exported by `lib/src/validators/validators.dart`.
- [ ] Unused auxiliary file `lib/src/core/cubit.dart` is deleted.
- [ ] Existing validator tests in `test/src/validators/*` pass.

## Covers
- User Stories: 1
- Requirements: 3, 5
- Interview Ledger: L1, L3, L6

## Blocked by
None - ready to start
