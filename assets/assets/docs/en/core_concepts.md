# Core Concepts & State Management

`Typed-Form-Fields` decouples form state and validation logic from UI rendering using reactive BLoC state architecture, ensuring type safety, immutability, and fine-grained UI rebuilds.

## Overview & Architecture

Form state management in `Typed-Form-Fields` is structured around three core primitives:
1. `FormFieldDefinition<T>`: Declarative schema defining a field's name, initial value, validation rules, group tag, and generic data type.
2. `TypedFormController`: A specialized BLoC `Cubit<TypedFormState>` managing central state, async debounce timers, group validation, and runtime field modifications.
3. `TypedFormState`: An immutable snapshot containing current raw values, active error messages, dirty/touched status, and pending async validation tasks.

---

## Detailed API Breakdown

### 1. `FormFieldDefinition<T>`

`FormFieldDefinition<T>` defines field metadata and validation rules declaratively.

#### Properties & Methods

| Property / Method | Type | Description |
| --- | --- | --- |
| `name` | `String` | **Required.** Unique field key identifier. |
| `validators` | `List<Validator<T>>` | Synchronous validation rules executing in order. |
| `asyncValidators` | `List<AsyncValidator<T>>` | Asynchronous validation rules executing with debouncing. |
| `initialValue` | `T?` | Starting value assigned when controller initializes or resets. |
| `group` | `String?` | Group tag identifier for multi-step or tabbed validation. |
| `valueType` | `Type` | Returns runtime type `T`. |
| `createValidator()` | `String? Function(Object?, BuildContext)` | Compiles combined synchronous validator execution block. |
| `copyWith(...)` | `FormFieldDefinition<T>` | Creates modified copy of field definition. |

---

### 2. `TypedFormController` (`Cubit<TypedFormState>`)

`TypedFormController` is the central Cubit governing state updates, validation triggers, and dynamic field modifications.

#### Constructor Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `fields` | `List<FormFieldDefinition>` | List of initial field definitions. |
| `validationStrategy` | `ValidationStrategy` | Active validation timing strategy. |
| `asyncDebounceDelay` | `Duration` | Delay before executing async validators (default: `300ms`). |
| `onAsyncValidationError` | `void Function(Object, StackTrace, String)?` | Callback for uncaught exceptions in async validators. |

#### Controller Properties

| Property | Type | Description |
| --- | --- | --- |
| `asyncDebounceDelay` | `Duration` | Active async debounce duration. |
| `onAsyncValidationError` | `Function?` | Active uncaught async error callback. |
| `touchedFields` | `Map<String, bool>` | Map of field names to user interaction (touched) booleans. |
| `initialValues` | `Map<String, Object?>` | Map of original starting field values. |
| `isDirty` | `bool` | `true` if current values differ from `initialValues`. |

#### Complete Method Catalog

| Method | Parameters | Description |
| --- | --- | --- |
| `getValue<T>()` | `String fieldName` | Safely retrieves typed value for `fieldName`. |
| `updateField<T>()` | `fieldName`, `value`, `context` | Updates field value and executes synchronous validation. |
| `updateFieldWithDebounce<T>()` | `fieldName`, `value`, `context` | Updates field value and triggers debounced async validation. |
| `updateFields()` | `fieldValues`, `context` | Programmatically updates multiple field values in batch. |
| `updateFieldValidators<T>()` | `name`, `validators`, `context` | Replaces validation rules for a field at runtime. |
| `validateGroup()` | `groupName`, `context`, `onPass`, `onFail` | Validates all fields matching `groupName`. |
| `validateFields()` | `fields`, `context`, `onPass`, `onFail` | Validates a specific list of field names. |
| `isGroupValid()` | `groupName` | Passive check returning `true` if group has no errors. |
| `areFieldsValid()` | `fields` | Passive check returning `true` if field list has no errors. |
| `touchGroup()` | `groupName`, `context` | Marks all fields in `groupName` as touched. |
| `setValidationStrategy()` | `ValidationStrategy strategy` | Dynamically switches active validation timing rule. |
| `validateForm()` | `context`, `onPass`, `onFail` | Flushes pending async checks and validates entire form. |
| `validateFieldImmediately()` | `fieldName`, `context` | Forces immediate evaluation of field validators. |
| `resetForm()` | *(none)* | Resets values to `initialValues` and clears errors/touched status. |
| `touchAllFields()` | `context` | Marks every field in the form as touched. |
| `updateError()` | `fieldName`, `errorMessage`, `context` | Manually injects an error message (e.g., from server API). |
| `updateErrors()` | `errors`, `context` | Manually injects map of field errors from server response. |
| `addField<T>()` | `field`, `context` | Adds a new field definition to form dynamically. |
| `addFields()` | `fields`, `context` | Adds multiple new field definitions dynamically. |
| `removeField()` | `fieldName`, `context` | Removes field definition and cleans up its state. |
| `removeFields()` | `fieldNames`, `context` | Removes multiple fields dynamically. |
| `isTouched()` | `String fieldName` | Returns `true` if user has interacted with `fieldName`. |

---

### 3. `TypedFormState`

`TypedFormState` is an immutable state snapshot produced by `TypedFormController`.

#### State Properties & Helpers

| Property / Method | Type | Description |
| --- | --- | --- |
| `values` | `Map<String, Object?>` | Raw map of all field values. |
| `errors` | `Map<String, String>` | Map of active field error strings. |
| `isValid` | `bool` | `true` if `errors` map is empty. |
| `validationStrategy` | `ValidationStrategy` | Active validation timing mode. |
| `fieldTypes` | `Map<String, Type>` | Map of registered field name to Dart Type. |
| `validatingFields` | `Set<String>` | Set of field names currently undergoing async validation. |
| `isValidating` | `bool` | `true` if `validatingFields.isNotEmpty`. |
| `getValue<T>(fieldName)` | `T?` | Extracts value cast to `T` safely. |
| `getError(fieldName)` | `String?` | Gets active error string for field. |
| `hasError(fieldName)` | `bool` | Returns `true` if error exists for field. |
| `copyWith(...)` | `TypedFormState` | Returns modified immutable copy. |

---

## Step-by-Step Code Walkthrough

### Step 1: Type-Safe Value Extraction with `getValue<T>`

Extract typed values directly from `TypedFormState` or via context helpers:

```dart
// Access inside TypedFormBuilder
final email = state.getValue<String>('email');
final age = state.getValue<int>('age');

// Access via BuildContext extension
final emailFromContext = context.getFormValue<String>('email');
```

### Step 2: Inspecting Form Touched & Dirty State

Track field interaction and modified values for unsaved-changes warnings or dirty state badges:

```dart
final controller = context.formCubit;

// Check if form differs from initialValues
print('Is Form Dirty: ${controller.isDirty}');

// Access map of initial values
print('Initial Values: ${controller.initialValues}');

// Check touched status for specific field or overall map
print('Is Email Touched: ${controller.isTouched('email')}');
print('Touched Fields Map: ${controller.touchedFields}');
```

### Step 3: BLoC Performance Optimizations (`buildWhen` & `listenWhen`)

`TypedFieldWrapper` uses internal BLoC selective filtering so that changing Field A only re-evaluates Field A's widget tree:

```dart
// Internal performance design pattern used by TypedFieldWrapper:
// Rebuilds occur ONLY when value, error, or validating state changes for 'fieldName'
buildWhen: (previousState, currentState) {
  return previousState.getValue(fieldName) != currentState.getValue(fieldName) ||
         previousState.getError(fieldName) != currentState.getError(fieldName) ||
         previousState.isValidating(fieldName) != currentState.isValidating(fieldName);
}
```

---

## Complete Runnable Example

The following runnable widget demonstrates inspecting form state, checking `isDirty`, `isTouched`, and getting typed values:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class CoreConceptsStateInspector extends StatelessWidget {
  const CoreConceptsStateInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      fields: [
        FormFieldDefinition<String>(
          name: 'username',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'initial_user',
        ),
        FormFieldDefinition<String>(
          name: 'bio',
          validators: [TypedCommonValidators.maxLength(100)],
          initialValue: '',
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TypedFieldWrapper<String>(
              fieldName: 'username',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'bio',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TypedFormBuilder(
              builder: (context, state) {
                final username = state.getValue<String>('username');
                final bio = state.getValue<String>('bio');
                final isDirty = context.formCubit.isDirty;
                final isUsernameTouched = context.formCubit.isTouched('username');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Form State Inspection:', style: Theme.of(context).textTheme.titleSmall),
                        const Divider(),
                        Text('Username Value: $username'),
                        Text('Bio Value: $bio'),
                        Text('Form Is Dirty: $isDirty'),
                        Text('Username Touched: $isUsernameTouched'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Live Interactive Demo

Test state inspection live in the interactive demo below:

<live-demo id="registration" />
