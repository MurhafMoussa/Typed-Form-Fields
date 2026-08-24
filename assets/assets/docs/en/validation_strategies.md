# Validation Strategies & Rules

`Typed-Form-Fields` offers fine-grained control over validation timing, built-in common rules, cross-field equality checks, and conditional validation rules.

## Overview & Prerequisites

Validation in `Typed-Form-Fields` spans three distinct areas:
1. **Validation Strategies**: Timing rules (`realTimeOnly`, `onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, `disabled`).
2. **Built-in Common Validators**: Pre-built static rules (`TypedCommonValidators.required`, `email`, `minLength`, `maxLength`, `pattern`, etc.).
3. **Cross-Field & Conditional Validation**: Rules that depend on other fields (`TypedCrossFieldValidators`) or conditional logic (`TypedConditionalValidator`).

---

## Step-by-Step Code Walkthrough

### Step 1: Choosing a Validation Strategy

Set the global validation timing mode when constructing `TypedFormProvider` or `TypedFormController`:

```dart
TypedFormProvider(
  validationStrategy: ValidationStrategy.onSubmitThenRealTime, // Default strategy
  fields: [ /* ... */ ],
  child: (context) => FormWidget(),
)
```

| Strategy | Description |
| --- | --- |
| `onSubmitOnly` | Errors remain hidden until `validateForm()` or submission is triggered. |
| `onSubmitThenRealTime` | Silent until first submit attempt, then updates in real time on keystrokes. |
| `realTimeOnly` | Validates active fields on every value change. |
| `allFieldsRealTime` | Re-evaluates every field in the form whenever any single value changes. |
| `disabled` | Disables automatic validation execution. |

### Step 2: Using Built-in Common Validators

Combine built-in validators in field definitions:

```dart
FormFieldDefinition<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required<String>(message: 'Password is required'),
    TypedCommonValidators.minLength(8, message: 'Must be at least 8 characters'),
    TypedCommonValidators.pattern(
      RegExp(r'[A-Z]'),
      message: 'Must contain an uppercase letter',
    ),
  ],
  initialValue: '',
)
```

### Step 3: Cross-Field Validation (`TypedCrossFieldValidators`)

Validate fields that depend on other field values (e.g. Password Confirmation):

```dart
FormFieldDefinition<String>(
  name: 'confirmPassword',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCrossFieldValidators.matches<String>(
      'password',
      message: 'Passwords do not match',
    ),
  ],
  initialValue: '',
)
```

### Step 4: Conditional Validation (`TypedConditionalValidator`)

Apply rules conditionally based on context or sibling values:

```dart
// Validate phone number only if 'contactViaPhone' checkbox is checked
FormFieldDefinition<String>(
  name: 'phoneNumber',
  validators: [
    TypedConditionalValidator<String>(
      condition: (value, context) =>
          context.getFormValue<bool>('contactViaPhone') == true,
      validator: TypedCommonValidators.required<String>(
        message: 'Phone number required for SMS updates',
      ),
    ),
  ],
  initialValue: '',
)
```

---

## Complete Runnable Example

The runnable example below showcases common, cross-field, and conditional validators:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class ValidationStrategiesExampleForm extends StatelessWidget {
  const ValidationStrategiesExampleForm({super.key});

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      validationStrategy: ValidationStrategy.onSubmitThenRealTime,
      fields: [
        FormFieldDefinition<String>(
          name: 'password',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(6),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'confirmPassword',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCrossFieldValidators.matches<String>(
              'password',
              message: 'Passwords do not match',
            ),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<bool>(
          name: 'requireNote',
          validators: [],
          initialValue: false,
        ),
        FormFieldDefinition<String>(
          name: 'note',
          validators: [
            TypedConditionalValidator<String>(
              condition: (value, context) =>
                  context.getFormValue<bool>('requireNote') == true,
              validator: TypedCommonValidators.required<String>(
                message: 'Note is required when checkbox is enabled',
              ),
            ),
          ],
          initialValue: '',
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypedFieldWrapper<String>(
              fieldName: 'password',
              builder: (context, field) {
                return TextFormField(
                  obscureText: true,
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TypedFieldWrapper<String>(
              fieldName: 'confirmPassword',
              builder: (context, field) {
                return TextFormField(
                  obscureText: true,
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TypedFieldWrapper<bool>(
              fieldName: 'requireNote',
              builder: (context, field) {
                return CheckboxListTile(
                  title: const Text('Require optional note'),
                  value: field.value ?? false,
                  onChanged: (val) => field.updateValue(val ?? false),
                );
              },
            ),
            TypedFieldWrapper<String>(
              fieldName: 'note',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Optional / Conditional Note',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TypedFormBuilder(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    context.validateForm(
                      onValidationPass: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All validation rules passed!')),
                        );
                      },
                    );
                  },
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

Test validation strategies and cross-field validation in the live demo below:

<live-demo id="registration" />
