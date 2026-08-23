# Asynchronous Validation & Debouncing

Asynchronous validation allows validating user input against remote APIs, databases, or delayed operations (e.g. checking username availability).

## Configuring Async Validators

Pass an `AsyncValidator` with configurable debounce duration to any field:

```dart
TextFieldController(
  name: 'username',
  asyncValidators: [
    AsyncValidator(
      validator: (value) async {
        final taken = await api.checkUsernameTaken(value);
        return taken ? 'Username is already taken' : null;
      },
      debounceDuration: Duration(milliseconds: 500),
    ),
  ],
);
```

## State Transparency

The `TypedFormState` exposes:
- `validatingFields`: List of field names currently executing async validation.
- `isValidating`: Boolean indicating whether any async validation is in progress.

## Interactive Demo

Try typing a username in the registration form below to see the loading spinner and delayed async validation in action:

<live-demo id="registration" />
