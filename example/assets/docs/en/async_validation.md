# Asynchronous Validation & Debouncing

Asynchronous validation enables validating user input against remote REST APIs, databases, or delayed operations (such as verifying username availability or checking coupon codes) without freezing the UI or overwhelming backend servers with network requests.

## Overview & Architecture

Key features of the `Typed-Form-Fields` async validation pipeline:
1. **`AsyncValidator<T>` Class**: Abstract interface for defining asynchronous validation checks.
2. **Per-Field Debouncing**: Configurable delay (`asyncDebounceDelay`, default 300ms) delays API execution until typing pauses.
3. **Execution Pipeline Order**: Synchronous validators execute instantly; async validation triggers *only* if synchronous checks pass.
4. **In-Flight Visual Feedback**: Reactive `validatingFields` set and `field.isValidating` helper enable displaying loading spinners.
5. **Submission Flushing**: Calling `context.validateForm()` flushes pending debounce timers and awaits all active network checks before proceeding.
6. **Exception Safety**: Uncaught exceptions during network calls are safely caught via `onAsyncValidationError`.

---

## Detailed API Breakdown

### 1. `AsyncValidator<T>` Class Signature

To construct an asynchronous validator, create a class implementing `AsyncValidator<T>`:

```dart
abstract class AsyncValidator<T> {
  const AsyncValidator();

  /// Evaluates value asynchronously. Returns error message String on failure or null on success.
  FutureOr<String?> validate(T? value, BuildContext context);
}
```

#### Parameters & Return Values

| Component | Type | Description |
| --- | --- | --- |
| `value` | `T?` | Current input value passed to the validator. |
| `context` | `BuildContext` | BuildContext giving access to themes, localizations, or form state. |
| **Returns** | `FutureOr<String?>` | `Future` resolving to error string `String` if invalid, or `null` if valid. |

---

### 2. Debouncing & Execution Order

```
[User Input] ──> [Run Sync Validators]
                      │
                      ├──> (If Sync Fails)  ──> Display Sync Error Immediately
                      │
                      └──> (If Sync Passes) ──> Start/Reset Debounce Timer (300ms)
                                                     │
                                                     └──> (Timer Expires) ──> Set field.isValidating = true
                                                                                   │
                                                                                   └──> Execute AsyncValidator
                                                                                             │
                                                                                             └──> Set field.isValidating = false & Update Error
```

#### Key Properties & Parameters

| Property / Parameter | Location | Description |
| --- | --- | --- |
| `asyncDebounceDelay` | `TypedFormProvider` / `TypedFormController` | Global debounce duration (default: `Duration(milliseconds: 300)`). |
| `state.validatingFields` | `TypedFormState` | `Set<String>` of field names currently executing async checks. |
| `state.isValidating` | `TypedFormState` | `bool` helper returning `true` if any field in the form is validating. |
| `field.isValidating` | `TypedFieldState<T>` | `bool` helper inside `TypedFieldWrapper` for field-specific loading indicators. |

---

### 3. Submission Flushing & Reset Safety

- **Flushing on Submit**: When calling `context.validateForm()` or `controller.validateForm()`, any active debounce timers are cancelled immediately and their underlying async validation tasks are executed and awaited.
- **Reset Safety**: Calling `controller.resetForm()` cancels all pending async timers, discards pending futures, and clears `state.validatingFields`.

---

### 4. Exception Handling with `onAsyncValidationError`

Provide `onAsyncValidationError` when initializing `TypedFormProvider` or `TypedFormController` to capture uncaught network or socket errors during async checks:

```dart
TypedFormProvider(
  asyncDebounceDelay: const Duration(milliseconds: 400),
  onAsyncValidationError: (error, stackTrace, fieldName) {
    debugPrint('Async validation failed on $fieldName: $error');
  },
  fields: [ /* ... */ ],
  child: (context) => const FormWidget(),
)
```

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

### Step 4: Submission Flushing & Form Submission

When calling `validateForm()`, the form controller flushes pending timers and awaits all in-flight async validators before invoking `onValidationPass` or `onValidationFail`.

```dart
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
          : const Text('Submit Form'),
    );
  },
)
```

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
      asyncDebounceDelay: const Duration(milliseconds: 400),
      onAsyncValidationError: (error, stackTrace, fieldName) {
        debugPrint('Async exception on $fieldName: $error');
      },
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
