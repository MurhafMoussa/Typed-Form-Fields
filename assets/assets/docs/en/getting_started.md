# Getting Started with Typed Form Fields

`Typed-Form-Fields` provides strongly-typed, reactive, and accessible form management for Flutter applications using zero-boilerplate form field wrappers and reactive providers.

## Overview & Prerequisites

Before building forms with `Typed-Form-Fields`, ensure your environment meets the following requirements:
- **Flutter SDK**: `>=3.0.0`
- **Dart SDK**: `>=3.0.0`
- **Dependencies**: Add `typed_form_fields` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  typed_form_fields: ^1.0.0
```

`Typed-Form-Fields` relies on two core building blocks:
1. `TypedFormProvider`: Top-level widget providing form definitions and validation strategy to descendants.
2. `TypedFieldWrapper<T>`: Reactive wrapper connecting any UI widget (`TextFormField`, `Checkbox`, `DropdownButtonFormField`, etc.) to form state.

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
  child: (context) => FormContent(),
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
