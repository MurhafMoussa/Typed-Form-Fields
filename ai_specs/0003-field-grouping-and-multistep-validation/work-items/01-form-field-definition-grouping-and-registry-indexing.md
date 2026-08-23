---
type: Work Item
title: FormFieldDefinition Grouping Metadata and FormFieldRegistry Indexing
parent: ../spec.md
---

## What to build
Add an optional `group` (`String?`) metadata parameter to `FormFieldDefinition<T>` constructor and `copyWith` method, preserving default value as `null`. Update `operator ==`, `hashCode`, and `toString()` on `FormFieldDefinition` to include `group`. Update `FormFieldRegistry` in `lib/src/core/form_field_registry.dart` with `List<FormFieldDefinition> getFieldsByGroup(String groupName)` which returns an unmodifiable list of field definitions matching `field.group == groupName` (exact match), returning `[]` if no fields match. Add unit tests for `FormFieldDefinition` and `FormFieldRegistry` grouping functionality.

## Required context
- `lib/src/models/form_field_definition.dart`
- `lib/src/core/form_field_registry.dart`

## Acceptance criteria
- [ ] `FormFieldDefinition<T>` constructor and `copyWith` accept optional `group` (`String?`) parameter defaulting to `null`.
- [ ] `FormFieldDefinition` `operator ==`, `hashCode`, and `toString()` reflect the `group` parameter.
- [ ] `FormFieldRegistry.getFieldsByGroup(String groupName)` returns an unmodifiable list of fields matching `field.group == groupName`.
- [ ] `FormFieldRegistry.getFieldsByGroup` returns an empty list `[]` when `groupName` matches no fields.
- [ ] Unit tests in `test/src/models/form_field_definition_test.dart` and `test/src/core/form_field_registry_test.dart` cover `group` metadata, `copyWith`, equality, hashcode, and `getFieldsByGroup`.

## Covers
- User Stories: 1
- Requirements: 1
- Interview Ledger: L1

## Blocked by
None - ready to start
