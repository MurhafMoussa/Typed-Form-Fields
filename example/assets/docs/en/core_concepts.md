# Core Architecture & State Management

`Typed-Form-Fields` decouples form state and validation logic from UI rendering using reactive controllers.

## Core Components

### 1. TypedFormController
The root controller orchestrates form state, validation strategies, group validations, and value aggregation.

```dart
final controller = TypedFormController(
  validationStrategy: ValidationStrategy.onSubmitThenRealTime,
);
```

### 2. TypedFormFieldController
Represents an individual form field, holding value, error state, touched status, dirty flag, and validation logic.

### 3. State Streams & ValueListenable
Controllers expose `ValueListenable<TypedFormState>` for state observation.

## Interactive Widget Gallery

Explore pre-built input components below:

<live-demo id="widget-gallery" />

## Architectural Benefits

- Zero boilerplate for form state synchronization.
- Seamless integration with BLoC, Provider, Riverpod, or pure `ValueNotifier`.
- Automatic disposal and memory safety.
