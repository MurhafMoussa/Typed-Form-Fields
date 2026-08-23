# Getting Started with Typed Form Fields

`Typed-Form-Fields` provides strongly-typed, reactive, and accessible form management for Flutter applications.

## Installation

Add `typed_form_fields` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  typed_form_fields: ^1.0.0
```

## Quick Start Example

Define a `TypedFormController` with your form fields and validation rules:

```dart
final formController = TypedFormController(
  fields: [
    TextFieldController(
      name: 'username',
      validators: [
        Validators.required(message: 'Username is required'),
        Validators.minLength(3, message: 'Minimum 3 characters required'),
      ],
    ),
    TextFieldController(
      name: 'email',
      validators: [
        Validators.required(message: 'Email is required'),
        Validators.email(message: 'Invalid email address'),
      ],
    ),
  ],
);
```

### Try it Live

Interact with the registration form below to see validation in real time:

<live-demo id="registration" />

## Key Features

- **Type Safety:** Strongly typed field values (`String`, `bool`, `DateTime`, `List<T>`).
- **Reactive State:** Fine-grained rebuilds without unnecessary re-renders.
- **Flexible Strategies:** Switch between real-time, on-submit, or hybrid validation on the fly.
- **Async Validation:** Native debounced async checks for remote validations.
