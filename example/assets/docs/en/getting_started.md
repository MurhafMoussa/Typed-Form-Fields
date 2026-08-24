# Getting Started with Typed Form Fields

`Typed-Form-Fields` provides strongly-typed, reactive, and accessible form management for Flutter applications using zero-boilerplate form field wrappers, BLoC-powered state reactivity, and ergonomic provider widgets.

## Overview & Prerequisites

Before building forms with `Typed-Form-Fields`, ensure your development environment satisfies:
- **Flutter SDK**: `>=3.0.0`
- **Dart SDK**: `>=3.0.0`
- **Package Dependency**: Add `typed_form_fields` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  typed_form_fields: ^1.0.0
```

`Typed-Form-Fields` simplifies form architecture through four primary UI building blocks:
1. `TypedFormProvider`: Injects `TypedFormController` into the widget tree with automated lifecycle management.
2. `TypedFieldWrapper<T>`: Attaches individual form controls (`TextFormField`, `Checkbox`, `DropdownButtonFormField`, custom widgets) to form state with targeted rebuilds.
3. `TypedFormBuilder` & `TypedFormListener`: React to form-wide state changes or trigger non-rebuilding side effects (e.g., displaying SnackBars or navigating).
4. `TypedFormProviderExtension`: Provides context-based convenience methods (`context.validateForm()`, `context.getFormValue<T>()`, `context.formCubit`) to eliminate boilerplate.

---

## Core Component API Reference

### 1. `TypedFormProvider`

`TypedFormProvider` creates and manages a `TypedFormController` for its subtree without requiring manual BLoC lifecycle handling.

#### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `fields` | `List<FormFieldDefinition>` | **Required.** List of declarative field definitions. |
| `validationStrategy` | `ValidationStrategy` | Validation timing mode (default: `onSubmitThenRealTime`). |
| `onFormStateChanged` | `void Function(TypedFormState)?` | Optional callback invoked on every form state change. |
| `asyncDebounceDelay` | `Duration` | Debounce duration for async validation (default: `300ms`). |
| `onAsyncValidationError` | `void Function(Object, StackTrace, String)?` | Callback for uncaught exceptions during async validation. |
| `child` | `Widget Function(BuildContext)` | **Required.** Builder function constructing the form UI tree. |
| `key` | `Key?` | Widget identifier key. |

#### Usage Benefits
- Automatically disposes internal controller/cubit on widget unmount.
- Exposes form state and controller methods to all descendant widgets via `BuildContext`.

---

### 2. `TypedFieldWrapper<T>` & `TypedFieldState<T>`

`TypedFieldWrapper<T>` selectively listens to state changes for a single field using BLoC `buildWhen` logic, preventing unnecessary full-form rebuilds.

#### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `fieldName` | `String` | **Required.** Unique identifier matching a `FormFieldDefinition.name`. |
| `builder` | `Widget Function(BuildContext, TypedFieldState<T>)` | **Required.** Builder function receiving local field state. |
| `initialValue` | `T?` | Optional local override value for field initialization. |
| `debounceTime` | `Duration?` | Delay before propagating input changes to central form state. |
| `transformValue` | `T Function(T)?` | Input processing callback (e.g. `.trim()`, `.toLowerCase()`). |
| `onValueChanged` | `void Function(T?)?` | Immediate callback triggered whenever input changes. |
| `onFieldStateChanged` | `void Function(T?, String?, bool)?` | Side-effect listener receiving `(value, error, isValidating)`. |
| `key` | `Key?` | Widget key. |

#### `TypedFieldState<T>` Properties

| Property | Type | Description |
| --- | --- | --- |
| `fieldName` | `String` | Name of the field. |
| `value` | `T?` | Current typed value of the field. |
| `error` | `String?` | Active error message string, if any. |
| `hasError` | `bool` | `true` if `error` is non-null and non-empty. |
| `isValidating` | `bool` | `true` if async validator is currently executing for this field. |
| `displayError` | `String?` | Helper returning `error` only when `hasError` is true. |
| `updateValue` | `void Function(T?)` | Callback to update field value in form controller. |

---

### 3. `TypedFormBuilder` & `TypedFormListener`

`TypedFormBuilder` rebuilds UI based on form-wide state (`isValid`, `validatingFields`), while `TypedFormListener` executes side-effects without triggering widget rebuilds.

```dart
// Reactive Submit Button with TypedFormBuilder
TypedFormBuilder(
  builder: (context, state) {
    return ElevatedButton(
      onPressed: state.isValid && state.validatingFields.isEmpty
          ? () => context.validateForm(onValidationPass: _submit)
          : null,
      child: state.validatingFields.isNotEmpty
          ? const CircularProgressIndicator()
          : const Text('Submit'),
    );
  },
)

// Non-rebuilding Side Effects with TypedFormListener
TypedFormListener(
  listener: (context, state) {
    if (state.errors.containsKey('email')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errors['email']!)),
      );
    }
  },
  child: const FormBody(),
)
```

---

### 4. Context Extension API (`TypedFormProviderExtension`)

Convenience extensions on `BuildContext` simplify form interactions from anywhere in the widget subtree:

| Method / Property | Return Type | Description |
| --- | --- | --- |
| `context.formCubit` | `TypedFormController` | Retrieves the active `TypedFormController`. |
| `context.formState` | `TypedFormState` | Retrieves the current `TypedFormState`. |
| `context.getFormValue<T>(name)` | `T?` | Extracts strongly-typed value for field `name`. |
| `context.updateFormField<T>(name, value)` | `void` | Programmatically updates value for field `name`. |
| `context.validateForm(...)` | `Future<bool>` | Triggers full form validation with pass/fail callbacks. |
| `context.validateGroup(group, ...)` | `Future<bool>` | Validates only fields tagged with `group`. |
| `context.validateFields(fields, ...)` | `Future<bool>` | Validates specific list of field names. |
| `context.isGroupValid(group)` | `bool` | Returns `true` if all fields in `group` are valid without touching. |
| `context.areFieldsValid(fields)` | `bool` | Returns `true` if listed fields are valid without touching. |
| `context.touchGroup(group)` | `void` | Marks all fields in `group` as touched. |

---

## Step-by-Step Code Walkthrough

### Step 1: Wrap Form with `TypedFormProvider`

Define field configurations with `FormFieldDefinition<T>` inside `TypedFormProvider`:

```dart
TypedFormProvider(
  fields: [
    FormFieldDefinition<String>(
      name: 'email',
      validators: [
        TypedCommonValidators.required<String>(),
        TypedCommonValidators.email(),
      ],
      initialValue: '',
    ),
    FormFieldDefinition<bool>(
      name: 'subscribe',
      validators: [],
      initialValue: false,
    ),
  ],
  child: (context) => const FormContentWidget(),
)
```

### Step 2: Bind UI Controls with `TypedFieldWrapper`

Use `TypedFieldWrapper<T>` to manage UI rendering and validation errors without manual controller listening:

```dart
TypedFieldWrapper<String>(
  fieldName: 'email',
  debounceTime: const Duration(milliseconds: 300),
  builder: (context, field) {
    return TextFormField(
      initialValue: field.value,
      onChanged: field.updateValue,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        errorText: field.displayError,
      ),
    );
  },
)
```

### Step 3: Handle Submission with `TypedFormBuilder`

Validate and extract strongly-typed form values when the user clicks submit:

```dart
TypedFormBuilder(
  builder: (context, state) {
    return ElevatedButton(
      onPressed: state.isValid && state.validatingFields.isEmpty
          ? () {
              context.validateForm(
                onValidationPass: () {
                  final email = state.getValue<String>('email');
                  final subscribe = state.getValue<bool>('subscribe');
                  print('Form Submitted: $email, Subscribe: $subscribe');
                },
              );
            }
          : null,
      child: const Text('Submit Registration'),
    );
  },
)
```

### Step 4: AI Agent Skill Reference

This package includes an official AI Agent Skill located at `.agents/skills/typed-form-fields/SKILL.md`. AI coding tools (e.g., OpenCode, Cursor, Claude Code) can load this skill to generate, refactor, and inspect forms cleanly following library conventions.

---

## Complete Runnable Example

Below is the complete runnable example demonstrating `TypedFormProvider`, `TypedFieldWrapper`, and reactive form submission:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class QuickStartRegistrationForm extends StatelessWidget {
  const QuickStartRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      fields: [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<bool>(
          name: 'subscribe',
          validators: [],
          initialValue: false,
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<bool>(
              fieldName: 'subscribe',
              builder: (context, field) {
                return CheckboxListTile(
                  title: const Text('Subscribe to updates'),
                  value: field.value ?? false,
                  onChanged: (val) => field.updateValue(val ?? false),
                );
              },
            ),
            const SizedBox(height: 24),
            TypedFormBuilder(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isValid && state.validatingFields.isEmpty
                      ? () {
                          context.validateForm(
                            onValidationPass: () {
                              final email = state.getValue<String>('email');
                              final subscribe = state.getValue<bool>('subscribe');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registered: $email (Subscribe: $subscribe)'),
                                ),
                              );
                            },
                          );
                        }
                      : null,
                  child: const Text('Submit Form'),
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

Try interacting with the live registration form below:

<live-demo id="registration" />
