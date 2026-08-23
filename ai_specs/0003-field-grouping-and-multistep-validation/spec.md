---
type: Spec
title: Field Grouping and Multi-Step Form Validation
---

## Problem

Building multi-step forms, wizards, or tabbed forms currently requires developers to write boilerplate code:
1. Validating fields manually one-by-one (`validateFieldImmediately('field1')`, `validateFieldImmediately('field2')`) or creating separate `TypedFormProvider` widgets per step.
2. Manually checking error maps to decide if the user can advance to the next step.
3. Lack of first-class field grouping metadata (`group: String?`) on `FormFieldDefinition<T>` to categorize fields by step or section.

This creates poor developer experience (DX) and repetitive code for common multi-step UI flows.

## Proposed Outcome

An intuitive, first-class **Field Grouping & Multi-Step Validation API** that allows developers to:
- Tag form fields with an optional `group` identifier on `FormFieldDefinition<T>`.
- Validate an entire step or group of fields with a single method call (`context.validateGroup('step1')` or `context.validateFields(['fullName', 'email'])`).
- Passively check group/subset validity (`context.isGroupValid('step1')` / `context.areFieldsValid(['fullName', 'email'])`) to reactively enable/disable "Next" buttons.
- Touch group fields automatically on validation attempts so invalid fields highlight error messages immediately.
- Experience seamless strategy switching (`onSubmitThenRealTime` -> `realTimeOnly`) when a step validation fails.

## User Stories

1. As a developer building a multi-step registration wizard, I want to tag form fields with a `group` name so that I can validate and navigate between steps with a single `context.validateGroup('step1')` method call. [L1, L2]
2. As a developer, I want to passively check if a step's fields are valid (`context.isGroupValid('step1')`) so that I can enable or disable the "Next" button in real time as the user types without triggering error displays prematurely. [L3]
3. As a developer, I want step validation attempts to automatically mark step fields as touched so that if required fields are missing, error messages immediately highlight for the user. [L2]

## Requirements

1. **FormFieldDefinition Grouping Metadata**: Add an optional `group` (`String?`) parameter to `FormFieldDefinition<T>` constructor and `copyWith` method. Preserve default value as `null`. Update `operator ==`, `hashCode`, and `toString()` on `FormFieldDefinition` to include `group`. [L1]
2. **Group Validation API (`validateGroup`)**: Implement group validation on `TypedFormController` (`validateGroup(String groupName, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`) and `TypedFormProviderExtension` on `BuildContext` (`context.validateGroup(String groupName, {VoidCallback? onValidationPass, VoidCallback? onValidationFail})`).
   - Marks all fields matching `field.group == groupName` as touched (`touched = true`). [L2]
   - Validates all fields in the group and merges target field error updates into form state while preserving existing errors on unvalidated fields. Re-evaluates overall form `isValid` status. [L2]
   - Triggers `onValidationPass()` if no errors exist for any field in the group; otherwise triggers `onValidationFail()`. [L2]
   - Switches `ValidationStrategy.onSubmitThenRealTime` to `realTimeOnly` if group validation fails. [L5]
   - If `groupName` matches no fields (empty or unknown group), returns cleanly, passes validation (`onValidationPass()`), and does not throw. [L4]
3. **Field Subset Validation API (`validateFields`)**: Implement subset validation on `TypedFormController` (`validateFields(List<String> fieldNames, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`) and `TypedFormProviderExtension` on `BuildContext` (`context.validateFields(List<String> fieldNames, {VoidCallback? onValidationPass, VoidCallback? onValidationFail})`).
   - Marks target fields as touched (`touched = true`). [L2]
   - Throws `FormFieldError.fieldNotFound` if any specified field name does not exist in the form registry. [L4]
   - Handles empty `fieldNames` lists cleanly by invoking `onValidationPass()`. Deduplicates input `fieldNames`.
   - Merges validated field errors into form state, re-evaluates overall form `isValid` status, and invokes `onValidationPass` or `onValidationFail`. [L2, L5]
4. **Passive Group & Subset Validity Checks**: Implement passive validity checks on `TypedFormController` (`isGroupValid(String groupName, {required BuildContext context})` / `areFieldsValid(List<String> fieldNames, {required BuildContext context})`) and `TypedFormProviderExtension` on `BuildContext` (`context.isGroupValid(String groupName)` / `context.areFieldsValid(List<String> fieldNames)`).
   - Performs a passive validation check against current values without altering `touched` state, without triggering debouncing, and without emitting state updates. [L3]
   - Returns `true` if all fields in the target group or list pass validation (or if the group/list is empty), and `false` if any field fails validation or is missing. [L3, L4]
5. **Group Touch API (`touchGroup`)**: Implement group touching on `TypedFormController` (`touchGroup(String groupName, {required BuildContext context})`) and `TypedFormProviderExtension` on `BuildContext` (`context.touchGroup(String groupName)`).
   - Marks all fields matching `field.group == groupName` as touched (`touched = true`) and re-evaluates form state errors and overall `isValid` status. [L2]
   - Does not invoke `onValidationPass`/`onValidationFail` callbacks and does not trigger strategy switching (`onSubmitThenRealTime` -> `realTimeOnly`).
   - If `groupName` matches no fields, returns cleanly without throwing.

## Technical Decisions

- **Field Registry Indexing**: Update `FormFieldRegistry` to add `List<FormFieldDefinition> getFieldsByGroup(String groupName)` which returns an unmodifiable list of fields matching `field.group == groupName` (exact string match), returning `[]` if no fields match.
- **Controller & Context Extensions**: Expose `validateGroup`, `validateFields`, `isGroupValid`, `areFieldsValid`, and `touchGroup` directly on `TypedFormController` (accepting `required BuildContext context`) and `TypedFormProviderExtension` (`BuildContext` extension delegating to controller with `this` context).
- **State Immutability & Rebuild Optimizations**: Ensure `TypedFormState` updates emit only modified field errors and updated validity status, taking advantage of `buildWhen` / `listenWhen` in `TypedFieldWrapper`.

## Testing Strategy

- **Unit Tests (`test/src/core/typed_form_controller_test.dart` & `test/src/core/form_field_registry_test.dart`)**:
  - Test `FormFieldDefinition.copyWith`, `==`, `hashCode`, and `toString()` with `group` parameter.
  - Test `FormFieldRegistry.getFieldsByGroup` with matching, non-matching, and null group fields.
  - Test `validateGroup` with valid, invalid, empty/unknown group names, callback invocations, and strategy switching.
  - Test `validateFields` with valid list, invalid values, empty list, duplicate names, missing field name exception throwing, and callbacks.
  - Test `isGroupValid` and `areFieldsValid` passive checks ensuring `touched` state and `errors` remain untouched.
  - Test `touchGroup` behavior for known and unknown groups without strategy switching.
- **Integration Tests (`test/integration/multi_step_form_integration_test.dart`)**:
  - Add a multi-step registration form integration test navigating between Step 1 (`personal_info`), Step 2 (`address_info`), and Step 3 (`confirmation`).
  - Test Step 1 validation failure, correction, and advancement.
  - Test final multi-step form submission.
- **Example App (`example/lib/screens/multi_step_form_screen.dart` & `example/lib/main.dart`)**:
  - Add a dedicated interactive Multi-Step Form Example screen to the example app showcasing the new Grouping API.
  - Register `MultiStepFormScreen` route and navigation button in `example/lib/main.dart`.

## Out of Scope

- Creating rigid UI stepper widgets (developers can use any stepper, `PageView`, `IndexedStack`, or tab bar UI).
