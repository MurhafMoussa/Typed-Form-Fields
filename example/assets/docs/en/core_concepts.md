# Core Concepts & State Management

`Typed-Form-Fields` decouples form state and validation logic from UI rendering using reactive state architecture, ensuring type safety and fine-grained UI rebuilds.

## Overview & Prerequisites

To effectively manage form state, understand the following core concepts:
- **Type-Safe Value Retrieval**: Use `getValue<T>('fieldName')` to safely extract values without casting errors.
- **Form Inspection Flags**: Monitor `isDirty`, `initialValues`, `touchedFields`, and `isTouched(fieldName)` for user activity tracking.
- **Internal BLoC Optimization**: Under the hood, state updates are powered by BLoC reactivity (`buildWhen` and `listenWhen`), avoiding full-screen re-renders when individual fields change.

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
