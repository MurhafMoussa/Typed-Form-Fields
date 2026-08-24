---
type: Work Item
title: AsyncValidator Definition, Localizations, and FormFieldDefinition Integration
parent: ../spec.md
---

## What to build
Introduce `AsyncValidator<T>` interface with `FutureOr<String?> validate(T? value, BuildContext context)`. Add a localized fallback error message `asyncValidationError` to `ValidatorLocalizations` and its delegate. Update `FormFieldDefinition<T>` constructor and `copyWith` method to accept optional `List<AsyncValidator<T>>? asyncValidators`, updating `operator ==`, `hashCode`, and `toString()`. Update `GLOSSARY.md` with canonical definition for `Async Validator`. Add unit tests covering `AsyncValidator`, `FormFieldDefinition` with `asyncValidators`, and `ValidatorLocalizations`.

## Required context
- `lib/src/validators/validator.dart`
- `lib/src/models/form_field_definition.dart`
- `lib/src/validators/validator_localizations.dart`
- `GLOSSARY.md`

## Acceptance criteria
- [x] `AsyncValidator<T>` interface is introduced with `FutureOr<String?> validate(T? value, BuildContext context)`.
- [x] `ValidatorLocalizations` contains `asyncValidationError` string.
- [x] `FormFieldDefinition<T>` accepts optional `List<AsyncValidator<T>>? asyncValidators`.
- [x] `FormFieldDefinition<T>` `copyWith`, `==`, `hashCode`, and `toString()` handle `asyncValidators`.
- [x] `GLOSSARY.md` is updated with `Async Validator` definition.
- [x] Unit tests cover `AsyncValidator`, `FormFieldDefinition`, and `ValidatorLocalizations`.

## Covers
- User Stories: 1
- Requirements: 1
- Technical Decisions: 3
- Interview Ledger: L1, L2

## Blocked by
None - ready to start
