# Custom Widgets & Dynamic Forms

Wrap any custom Flutter widget into a fully reactive form field or manage dynamically changing form array structures.

## Using FieldWrapper

Wrap third-party or custom input widgets using `FieldWrapper`:

```dart
FieldWrapper<double>(
  name: 'rating',
  builder: (context, fieldState, onChanged) {
    return Slider(
      value: fieldState.value ?? 0.0,
      onChanged: onChanged,
    );
  },
);
```

## Dynamic Form Arrays

Add, remove, and reorder fields dynamically at runtime with `TypedFormController.addField()` and `removeField()`.

## Interactive Dynamic Form

Try adding and removing field items dynamically in the demo below:

<live-demo id="dynamic-form" />
