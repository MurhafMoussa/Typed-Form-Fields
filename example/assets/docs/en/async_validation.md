# Asynchronous Validation & Debouncing

Asynchronous validation allows validating user input against remote APIs, databases, or delayed operations (such as checking username availability or promo code validity) without freezing the UI.

## Overview & Prerequisites

Key features of the `Typed-Form-Fields` async validation pipeline:
- **`AsyncValidator<T>` Class**: Abstract class for defining custom asynchronous validation checks.
- **Debounce Delay**: Built-in debouncing (default 300ms) ensures network requests are delayed until typing stops.
- **Loading State Visibility**: Form state exposes `validatingFields` and `field.isValidating` for rendering spinners.
- **Submission Flushing**: Invoking `context.validateForm()` flushes active debouncers and awaits pending network operations before completing.
- **Exception Safety**: Uncaught exceptions during async checks are safely captured via `onAsyncValidationError`.

---

## Step-by-Step Code Walkthrough

### Step 1: Define an `AsyncValidator<T>`

Extend `AsyncValidator<T>` and override the `validate` method:

```dart
class UsernameAvailabilityValidator extends AsyncValidator<String> {
  const UsernameAvailabilityValidator();

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.length < 3) return null;
    
    // Simulate remote API call
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (value.toLowerCase() == 'admin' || value.toLowerCase() == 'taken') {
      return 'Username "$value" is already taken';
    }
    return null;
  }
}
```

### Step 2: Attach to `FormFieldDefinition`

Pass the async validator into `asyncValidators`:

```dart
FormFieldDefinition<String>(
  name: 'username',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.minLength(3),
  ],
  asyncValidators: [
    const UsernameAvailabilityValidator(),
  ],
  initialValue: '',
)
```

### Step 3: Display Real-Time Loading Indicator

Use `field.isValidating` inside `TypedFieldWrapper` to show a progress spinner when an async request is in flight:

```dart
TypedFieldWrapper<String>(
  fieldName: 'username',
  builder: (context, field) {
    return TextFormField(
      initialValue: field.value,
      onChanged: field.updateValue,
      decoration: InputDecoration(
        labelText: 'Username',
        errorText: field.displayError,
        suffixIcon: field.isValidating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
    );
  },
)
```

### Step 4: Submission Flushing & Reset Safety

When calling `validateForm()`, the form controller flushes pending timers and awaits all in-flight async validators before invoking `onValidationPass` or `onValidationFail`. Calling `resetForm()` immediately cancels active timers and resets async state.

---

## Complete Runnable Example

Below is the complete runnable example demonstrating debounced async validation with progress spinner feedback:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class CheckEmailAsyncValidator extends AsyncValidator<String> {
  const CheckEmailAsyncValidator();

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || !value.contains('@')) return null;

    // Simulate backend lookup
    await Future.delayed(const Duration(milliseconds: 500));

    if (value.endsWith('@taken.com')) {
      return 'Domain @taken.com is unavailable';
    }
    return null;
  }
}

class AsyncValidationExampleForm extends StatelessWidget {
  const AsyncValidationExampleForm({super.key});

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
          asyncValidators: [
            const CheckEmailAsyncValidator(),
          ],
          initialValue: '',
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email Address (try user@taken.com)',
                    errorText: field.displayError,
                    suffixIcon: field.isValidating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TypedFormBuilder(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isValidating
                      ? null
                      : () {
                          context.validateForm(
                            onValidationPass: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Async check passed!')),
                              );
                            },
                          );
                        },
                  child: state.isValidating
                      ? const Text('Flushing & Validating...')
                      : const Text('Submit'),
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

Try typing a username in the live registration demo below to see the async loading indicator:

<live-demo id="registration" />
