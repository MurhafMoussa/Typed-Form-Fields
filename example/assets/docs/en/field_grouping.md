# Field Grouping & Multi-Step Forms

Group related form fields using `fieldGroup` tags to validate subsets of forms independently (e.g., multi-step wizard screens).

## Group Declaration

Assign fields to logical groups:

```dart
TextFieldController(
  name: 'firstName',
  fieldGroup: 'personal',
);

TextFieldController(
  name: 'cardNumber',
  fieldGroup: 'payment',
);
```

## Partial Group Validation

Validate only the fields belonging to a specific group before advancing to the next step:

```dart
final isStepValid = controller.validateGroup('personal');
if (isStepValid) {
  // Move to step 2
}
```

## Interactive Multi-Step Wizard

Try navigating between steps in the live wizard below:

<live-demo id="multi-step" />
