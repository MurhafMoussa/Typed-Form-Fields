---
name: typed-form-fields
description: Comprehensive LLM guide and API reference for the typed_form_fields package. Covers TypedFormController lifecycle, state reactivity, validation strategies, async validation pipeline, field grouping, state management integration (BLoC/Provider), and custom widget wrapping using TypedFieldWrapper.
---

# Typed Form Fields Agent Skill

Use this skill whenever building, refactoring, or integrating form management using the `typed_form_fields` package in Dart and Flutter.

---

## Core Concepts & Architecture

`typed_form_fields` is a zero-dependency, high-performance form state management package built on top of Flutter's BLoC pattern (`Cubit<TypedFormState>`).

### Architectural Components
1. **`FormFieldDefinition<T>`**: Declarative definition of a form field (name, static validators, async validators, initial value, group name).
2. **`TypedFormController`**: The central Cubit managing form values, error maps, touched states, async validation tasks, field definitions, and group validation.
3. **`TypedFormState`**: Immutable state snapshot containing `values`, `errors`, `isValid`, `validationStrategy`, `validatingFields`, and `fieldTypes`.
4. **`TypedFormProvider`**: Provider widget exposing `TypedFormController` to the widget subtree without requiring direct BLoC setup by the consumer.
5. **`TypedFieldWrapper<T>`**: Universal wrapper widget targeting individual fields with selective rebuilds via `buildWhen`/`listenWhen`.

---

## 1. Controller Lifecycle & Initialization

### Defining Form Fields
Form fields are defined using `FormFieldDefinition<T>`.

> **Note on Validators:** Synchronous validators must implement `Validator<T>` (e.g., via `TypedCommonValidators`), and async validators must implement `AsyncValidator<T>`.

```dart
// Custom AsyncValidator class implementing AsyncValidator<T>
class CheckEmailAvailabilityValidator extends AsyncValidator<String> {
  const CheckEmailAvailabilityValidator();

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.isEmpty) return null;
    final isAvailable = await checkEmailAvailability(value);
    return isAvailable ? null : 'Email is already registered';
  }
}

final fields = <FormFieldDefinition>[
  FormFieldDefinition<String>(
    name: 'email',
    initialValue: '',
    validators: [
      TypedCommonValidators.required<String>(errorText: 'Email is required'),
      TypedCommonValidators.email(errorText: 'Enter a valid email address'),
    ],
    asyncValidators: const [
      CheckEmailAvailabilityValidator(),
    ],
  ),
  FormFieldDefinition<String>(
    name: 'password',
    initialValue: '',
    validators: [
      TypedCommonValidators.required<String>(errorText: 'Password is required'),
      TypedCommonValidators.minLength(8, errorText: 'Password must be at least 8 characters'),
    ],
  ),
  FormFieldDefinition<bool>(
    name: 'terms',
    initialValue: false,
    validators: [
      TypedCommonValidators.mustBeTrue(errorText: 'You must accept the terms'),
    ],
  ),
];
```

### Initializing and Disposing `TypedFormController`

#### Direct Controller Usage
When managing the controller manually inside a `StatefulWidget`:

```dart
class MyFormWidgetState extends State<MyFormWidget> {
  late final TypedFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TypedFormController(
      fields: myFields,
      validationStrategy: ValidationStrategy.allFieldsRealTime,
      asyncDebounceDelay: const Duration(milliseconds: 400),
      onAsyncValidationError: (error, stackTrace, fieldName) {
        debugPrint('Async error on $fieldName: $error');
      },
    );
  }

  @override
  void dispose() {
    _controller.close(); // Cleanly cancels async timers and releases resources
    super.dispose();
  }
}
```

#### Provider-Based Usage
When using `TypedFormProvider`, controller creation and disposal are handled automatically:

```dart
TypedFormProvider(
  fields: myFields,
  validationStrategy: ValidationStrategy.realTimeOnly,
  onFormStateChanged: (state) {
    debugPrint('Form state updated: isValid=${state.isValid}');
  },
  child: (context) => const MyFormContentWidget(),
)
```

---

## 2. State Reactivity & Access

### `TypedFormState` Properties

| Property | Type | Description |
|---|---|---|
| `values` | `Map<String, Object?>` | Map of field names to current raw values |
| `errors` | `Map<String, String>` | Map of field names to active error messages |
| `isValid` | `bool` | `true` if all form fields have no validation errors |
| `validationStrategy` | `ValidationStrategy` | Current active validation timing rule |
| `validatingFields` | `Set<String>` | Set of field names currently executing async validation |
| `fieldTypes` | `Map<String, Type>` | Map of field names to their Dart types |

### Accessing State & Values

#### Type-Safe Field Value Retrieval
```dart
// Direct controller access
final String? email = controller.getValue<String>('email');

// From TypedFormState
final String? password = state.getValue<String>('password');

// Via BuildContext extension
final bool? terms = context.getFormValue<bool>('terms');
```

#### Reacting to State Changes

##### Full Form Rebuilds (`TypedFormBuilder`)
```dart
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
```

##### Side-Effect Listening (`TypedFormListener`)
```dart
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

## 3. Validation Strategies

The library supports 5 distinct validation strategies via `ValidationStrategy`:

```dart
enum ValidationStrategy {
  realTimeOnly,          // Validates fields immediately on every value change
  onSubmitOnly,          // Validates fields only when validateForm/validateGroup is called
  onSubmitThenRealTime,  // Validates on submit; after first submission attempt, validates in real-time
  allFieldsRealTime,     // Re-validates all fields in real-time whenever any field value changes
  disabled,              // Disables automatic validation entirely
}
```

### Dynamic Strategy Switching
You can change the validation strategy dynamically at runtime without losing form values or touched states:

```dart
// Switch strategy on controller
controller.setValidationStrategy(ValidationStrategy.onSubmitThenRealTime);

// From context
context.formCubit.setValidationStrategy(ValidationStrategy.realTimeOnly);
```

---

## 4. Async Validation Pipeline & Debouncing

### Defining Async Validators
Async validators must extend `AsyncValidator<T>` and implement `FutureOr<String?> validate(T? value, BuildContext context)`:

```dart
class CheckUsernameAvailabilityValidator extends AsyncValidator<String> {
  const CheckUsernameAvailabilityValidator(this.apiService);
  final ApiService apiService;

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.isEmpty) return null;
    final exists = await apiService.checkUsernameExists(value);
    if (exists) return 'Username is already taken';
    return null;
  }
}

final usernameField = FormFieldDefinition<String>(
  name: 'username',
  initialValue: '',
  validators: [
    TypedCommonValidators.required<String>(errorText: 'Username is required'),
    TypedCommonValidators.minLength(3, errorText: 'Minimum 3 characters'),
  ],
  asyncValidators: [
    CheckUsernameAvailabilityValidator(apiService),
  ],
);
```

### Async Debouncing Mechanics
1. When a user types into an async-validated field, static sync validators run immediately.
2. If static validators pass, async validation is debounced by `asyncDebounceDelay` (default: `Duration(milliseconds: 300)`).
3. During execution, the field name is added to `state.validatingFields`.
4. When async validation completes, `state.validatingFields` is updated and `state.errors` is populated if an error occurred.

### Handling Async Validation Errors
Pass `onAsyncValidationError` when instantiating `TypedFormController` to catch uncaught exceptions during network/database calls:

```dart
TypedFormController(
  fields: myFields,
  asyncDebounceDelay: const Duration(milliseconds: 500),
  onAsyncValidationError: (error, stackTrace, fieldName) {
    debugPrint('Network error while validating $fieldName: $error');
  },
);
```

---

## 5. Field Grouping & Partial Validation

Field grouping allows validating subsets of form fields independently, which is ideal for multi-step form wizards, tabbed inputs, or multi-card forms.

### Defining Field Groups
Assign a `group` string to `FormFieldDefinition`:

```dart
final fields = [
  // Step 1 Group
  FormFieldDefinition<String>(
    name: 'firstName',
    group: 'personal_info',
    validators: [TypedCommonValidators.required<String>()],
  ),
  FormFieldDefinition<String>(
    name: 'lastName',
    group: 'personal_info',
    validators: [TypedCommonValidators.required<String>()],
  ),
  // Step 2 Group
  FormFieldDefinition<String>(
    name: 'street',
    group: 'address_info',
    validators: [TypedCommonValidators.required<String>()],
  ),
  FormFieldDefinition<String>(
    name: 'city',
    group: 'address_info',
    validators: [TypedCommonValidators.required<String>()],
  ),
];
```

### Group Validation API

#### Validating a Group
```dart
// Via BuildContext extension
context.validateGroup(
  'personal_info',
  onValidationPass: () => _goToNextStep(),
  onValidationFail: () => _showErrorBanner(),
);

// Via Controller
controller.validateGroup(
  'address_info',
  context: context,
  onValidationPass: () => _submitFinalOrder(),
);
```

#### Passive Group & Subset Checks
```dart
// Check if group is valid without marking fields touched
final bool step1Valid = context.isGroupValid('personal_info');

// Check specific list of fields by name
final bool subsetValid = context.areFieldsValid(['firstName', 'city']);
```

#### Marking Group Touched
```dart
context.touchGroup('personal_info');
```

---

## 6. State Management Integration (BLoC & Provider)

### Provider Integration Pattern
Use `TypedFormProvider` and `TypedFormProviderExtension` for clean widget trees without needing `flutter_bloc` directly in user code:

```dart
class RegistrationFormPage extends StatelessWidget {
  const RegistrationFormPage({super.key});

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
        ),
      ],
      child: (context) {
        return Column(
          children: [
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, field) {
                return TextField(
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: field.displayError,
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                context.validateForm(
                  onValidationPass: () {
                    final email = context.getFormValue<String>('email');
                    debugPrint('Submitting email: $email');
                  },
                );
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }
}
```

---

## 7. Custom Widget Wrapping with `TypedFieldWrapper`

`TypedFieldWrapper<T>` is the recommended high-performance wrapper for creating or integrating custom inputs (e.g. text inputs, checkboxes, sliders, rating pickers, custom date pickers).

### `TypedFieldWrapper<T>` API Parameters

| Parameter | Type | Description |
|---|---|---|
| `fieldName` | `String` (required) | Unique identifier matching a `FormFieldDefinition.name` |
| `builder` | `Widget Function(BuildContext, TypedFieldState<T>)` (required) | Builder callback receiving field state |
| `initialValue` | `T?` | Optional initial local value |
| `debounceTime` | `Duration?` | Optional delay before sending updates to form state |
| `transformValue` | `T Function(T)?` | Optional processing function (e.g., `.trim()`, `.toLowerCase()`) |
| `onValueChanged` | `void Function(T?)?` | Immediate callback fired when input value changes |
| `onFieldStateChanged` | `void Function(T?, String?, bool)?` | Side-effect listener fired without triggering rebuilds |

### `TypedFieldState<T>` Builder Properties

| Property | Type | Description |
|---|---|---|
| `fieldName` | `String` | Field identifier |
| `value` | `T?` | Current typed field value |
| `error` | `String?` | Active error message |
| `hasError` | `bool` | `true` if `error` is non-null and non-empty |
| `isValidating` | `bool` | `true` if async validator is actively running for this field |
| `displayError` | `String?` | Helper returning `error` only if `hasError` is true |
| `updateValue` | `void Function(T?)` | Callback to update the field value |

---

## 8. API Cheat Sheet & Common Operations

### Controller Methods Quick Reference

```dart
// Field updates
controller.updateField<T>(fieldName: 'email', value: 'a@b.com', context: context);
controller.updateFieldWithDebounce<T>(fieldName: 'search', value: 'query', context: context);
controller.updateFields(fieldValues: {'f1': 'v1', 'f2': 'v2'}, context: context);

// Dynamic validators update
controller.updateFieldValidators<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required(),
    TypedCommonValidators.minLength(10),
  ],
  context: context,
);

// Dynamic field registration / removal
controller.addField<String>(field: newFieldDefinition, context: context);
controller.removeField('oldFieldName', context: context);

// Validation triggers
controller.validateForm(context, onValidationPass: _submit, onValidationFail: _onFail);
controller.validateGroup('step1', context: context, onValidationPass: _nextStep);
controller.validateFields(['email', 'phone'], context: context);
controller.validateFieldImmediately(fieldName: 'email', context: context);

// Touch & reset operations
controller.touchAllFields(context);
controller.touchGroup('step1', context: context);
controller.resetForm();

// Manual error overrides (e.g., handling server API validation responses)
controller.updateError(fieldName: 'email', errorMessage: 'Server rejected email', context: context);
controller.updateErrors(errors: {'email': 'Invalid', 'phone': 'Taken'}, context: context);
```

### Common Validators Reference (`TypedCommonValidators`)

```dart
// Required validator
TypedCommonValidators.required<T>({BuildContext? context, String? errorText});

// Text validators
TypedCommonValidators.email({BuildContext? context, String? errorText});
TypedCommonValidators.minLength(int minLength, {BuildContext? context, String? errorText});
TypedCommonValidators.maxLength(int maxLength, {BuildContext? context, String? errorText});
TypedCommonValidators.pattern(RegExp pattern, {BuildContext? context, String? errorText});

// Number validators
TypedCommonValidators.min(num minValue, {BuildContext? context, String? errorText});
TypedCommonValidators.max(num maxValue, {BuildContext? context, String? errorText});

// Boolean / Selection validators
TypedCommonValidators.mustBeTrue({BuildContext? context, String? errorText});

// Cross-field matching (e.g., password confirmation)
TypedCrossFieldValidators.matches<String>('password', errorText: 'Passwords do not match');
TypedCrossFieldValidators.differentFrom<String>('oldPassword');
TypedCrossFieldValidators.requiredWhen<String>('role', 'admin');

// Conditional validation
TypedConditionalValidators.whenNotEmpty(validator);
TypedConditionalValidator<String>(
  condition: (value, context) => context.getFormValue<bool>('requirePhone') == true,
  validator: TypedCommonValidators.required(errorText: 'Phone is required'),
);
```
