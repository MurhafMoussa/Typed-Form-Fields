---
type: Work Item
title: Consolidate Test Suite & Benchmark Updates
parent: ../spec.md
---

## What to build
Delete the obsolete internal micro-service unit tests (`test/src/services/*`). Add/enhance tests in `test/src/core/typed_form_controller_test.dart` and `test/src/core/form_validator_test.dart` to verify strategy behavior, edge cases, debouncing, and teardown lifecycle through public contracts. Update `test/integration/form_integration_test.dart` and `test/benchmarks/form_performance_benchmark.dart` as necessary. Run and pass `flutter test` and `flutter analyze`.

## Required context
- `test/src/services/*` (to delete)
- `test/src/core/typed_form_controller_test.dart`
- `test/src/core/form_validator_test.dart` (new/enhanced)
- `test/integration/form_integration_test.dart`
- `test/benchmarks/form_performance_benchmark.dart`

## Acceptance criteria
- [ ] Obsolete internal micro-service test directory `test/src/services/` is removed.
- [ ] `test/src/core/typed_form_controller_test.dart` and `test/src/core/form_validator_test.dart` thoroughly test controller state updates, debouncing, validation strategies, and disposal.
- [ ] `test/integration/form_integration_test.dart` and `test/benchmarks/form_performance_benchmark.dart` execute cleanly without reference errors to deleted micro-services.
- [ ] `flutter analyze` passes with zero static analysis errors or warnings.
- [ ] `flutter test` completes with 100% passing tests.

## Covers
- User Stories: 2
- Requirements: 6
- Testing Strategy: 1-4
- Interview Ledger: L1, L4

## Blocked by
- 03-consolidate-microservices-controller.md
