---
type: Work Item
title: Multi-Step Form Integration Tests and Interactive Example Screen
parent: ../spec.md
---

## What to build
Create an integration test suite for multi-step form validation and add an interactive Multi-Step Form Example screen to the example application.
- `test/integration/multi_step_form_integration_test.dart`: Test a 3-step registration wizard (`personal_info`, `address_info`, `confirmation`). Verify step validation failure on required fields, error highlighting, passive Next button enabling via `isGroupValid`, step correction, step advancement, and final form submission.
- `example/lib/screens/multi_step_form_screen.dart` & `example/lib/main.dart`: Build an interactive Multi-Step Form screen in the example app showcasing group tagging (`group: 'step1'`), `context.validateGroup`, passive `context.isGroupValid` button state, step transitions, and real-time validation. Add route navigation button in `example/lib/main.dart`.

## Required context
- `lib/src/widgets/typed_form_provider.dart`
- `example/lib/main.dart`
- `example/lib/screens/`

## Acceptance criteria
- [ ] Integration tests in `test/integration/multi_step_form_integration_test.dart` cover multi-step wizard navigation, step validation, passive validity checks, error displays, and final submission.
- [ ] Interactive `MultiStepFormScreen` added in `example/lib/screens/multi_step_form_screen.dart`.
- [ ] `MultiStepFormScreen` route registered in `example/lib/main.dart` with a navigation button on the home screen.
- [ ] All unit and integration tests pass cleanly and example app builds without error.

## Covers
- User Stories: 1, 2, 3
- Requirements: 1, 2, 3, 4, 5
- Testing Strategy: Integration Tests, Example App

## Blocked by
`02-group-and-subset-validation-controller-api.md`
