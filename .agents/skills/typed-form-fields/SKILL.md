---
name: typed-form-fields
description: Comprehensive LLM guide and API reference for the typed_form_fields package. Covers TypedFormController lifecycle, state reactivity, validation strategies, async validation pipeline, field grouping, state management integration (BLoC/Provider), and custom widget wrapping using TypedFieldWrapper.
---

# Typed Form Fields Agent Skill

Use this skill whenever building, refactoring, or integrating form management using the `typed_form_fields` package in Dart and Flutter.

---

## Architecture & Overview

`typed_form_fields` is a zero-dependency, high-performance form state management library built on top of Flutter's BLoC pattern (`Cubit<TypedFormState>`). It provides generic type-safe form field validation, field grouping, dynamic field manipulation, debouncing, and custom widget wrapping.

### Key Components

1. **`FormFieldDefinition<T>`**: Declarative definition of a form field (name, static validators, async validators, initial value, group name).
2. **`TypedFormController`**: BLoC Cubit managing form state, values, error maps, touched states, async validation tasks, field definitions, and group validation.
3. **`TypedFormState`**: Immutable state snapshot containing `values`, `errors`, `isValid`, `validationStrategy`, `validatingFields`, and `fieldTypes`.
4. **`TypedFormProvider`**: Provider widget exposing `TypedFormController` to child widgets without requiring direct `flutter_bloc` installation or setup.
5. **`TypedFormBuilder`**: Builder widget that rebuilds whenever form state updates.
6. **`TypedFormListener`**: Listener widget for triggering side effects (snackbars, navigation, logging) on state changes.
7. **`TypedFieldWrapper<T>`**: High-performance wrapper targeting individual fields with selective rebuilds via `buildWhen`/`listenWhen`.
8. **`TypedFieldState<T>`**: Builder object passed to `TypedFieldWrapper` containing field-scoped value, error, validation status, and update callback.
9. **`TypedFormProviderExtension`**: `BuildContext` extensions for succinct form controller access and form actions.

---

## 1. Core Controllers & State Reference

### `TypedFormController`

Extends `Cubit<TypedFormState>`. Central controller for form management.

#### Constructor

```dart
TypedFormController({
  List<FormFieldDefinition> fields = const [],
  ValidationStrategy validationStrategy = ValidationStrategy.allFieldsRealTime,
  Duration asyncDebounceDelay = const Duration(milliseconds: 300),
  void Function(Object error, StackTrace stackTrace, String fieldName)? onAsyncValidationError,
})
```

#### Properties & Getters

- `asyncDebounceDelay` (`Duration`): Delay before executing async validators for a field.
- `onAsyncValidationError` (`void Function(Object, StackTrace, String)?`): Callback when uncaught exception occurs during async validation.
- `touchedFields` (`Map<String, bool>`): Unmodifiable map of field names to touched status.
- `initialValues` (`Map<String, Object?>`): Map of initial field values supplied when form was created or reset.
- `isDirty` (`bool`): `true` if any current field value differs from its initial value.

#### Public Methods Catalog

##### 1. `getValue<T>(String fieldName)`
- **Returns**: `T?`
- **Description**: Returns the typed value of the specified field from current form state. Throws `FormFieldError.fieldNotFound` if the field does not exist, or `FormFieldError.typeMismatch` if type parameter `T` disagrees with registered field type.

```dart
final String? email = controller.getValue<String>('email');
```

##### 2. `updateField<T>({required String fieldName, T? value, required BuildContext context, bool touched = true})`
- **Returns**: `void`
- **Description**: Updates a single field value and re-validates based on the current `ValidationStrategy`.

```dart
controller.updateField<String>(
  fieldName: 'email',
  value: 'user@example.com',
  context: context,
);
```

##### 3. `updateFieldWithDebounce<T>({required String fieldName, T? value, required BuildContext context})`
- **Returns**: `void`
- **Description**: Updates field value with debouncing before running validation logic.

```dart
controller.updateFieldWithDebounce<String>(
  fieldName: 'searchQuery',
  value: 'flutter',
  context: context,
);
```

##### 4. `updateFields<T>({required Map<String, T?> fieldValues, required BuildContext context})`
- **Returns**: `void`
- **Description**: Updates multiple field values simultaneously with a single state emission.

```dart
controller.updateFields(
  fieldValues: {
    'firstName': 'Jane',
    'lastName': 'Doe',
  },
  context: context,
);
```

##### 5. `updateFieldValidators<T>({required String name, required List<Validator<T>> validators, List<AsyncValidator<T>>? asyncValidators, required BuildContext context})`
- **Returns**: `void`
- **Description**: Dynamically modifies validation rules for an existing field at runtime.

```dart
controller.updateFieldValidators<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required(),
    TypedCommonValidators.minLength(12),
  ],
  context: context,
);
```

##### 6. `validateGroup(String groupName, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`
- **Returns**: `void`
- **Description**: Marks all fields belonging to `groupName` as touched and evaluates their validation. Invokes `onValidationPass` or `onValidationFail`.

```dart
controller.validateGroup(
  'account_info',
  context: context,
  onValidationPass: () => navigateToStep2(),
  onValidationFail: () => showStepError(),
);
```

##### 7. `validateFields(List<String> fieldNames, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`
- **Returns**: `void`
- **Description**: Marks specific fields as touched and evaluates their validation rules.

```dart
controller.validateFields(
  ['email', 'phone'],
  context: context,
  onValidationPass: () => proceed(),
);
```

##### 8. `isGroupValid(String groupName, {required BuildContext context})`
- **Returns**: `bool`
- **Description**: Passively checks if all fields in `groupName` are valid without changing touched state or emitting errors.

```dart
final bool isValid = controller.isGroupValid('billing', context: context);
```

##### 9. `areFieldsValid(List<String> fieldNames, {required BuildContext context})`
- **Returns**: `bool`
- **Description**: Passively checks if a specific subset of fields is valid.

```dart
final bool valid = controller.areFieldsValid(['username', 'password'], context: context);
```

##### 10. `touchGroup(String groupName, {required BuildContext context})`
- **Returns**: `void`
- **Description**: Marks all fields in `groupName` as touched and triggers re-validation for that group.

```dart
controller.touchGroup('personal_details', context: context);
```

##### 11. `setValidationStrategy(ValidationStrategy validationStrategy)`
- **Returns**: `void`
- **Description**: Dynamically updates the form's active validation strategy.

```dart
controller.setValidationStrategy(ValidationStrategy.onSubmitThenRealTime);
```

##### 12. `validateForm(BuildContext context, {required VoidCallback onValidationPass, VoidCallback? onValidationFail})`
- **Returns**: `FutureOr<void>`
- **Description**: Flushes pending async debounce timers, marks all fields as touched, runs all sync/async validators, and invokes appropriate callback.

```dart
await controller.validateForm(
  context,
  onValidationPass: () => submitData(),
  onValidationFail: () => highlightErrors(),
);
```

##### 13. `validateFieldImmediately({required String fieldName, required BuildContext context})`
- **Returns**: `void`
- **Description**: Forces immediate execution of synchronous and asynchronous validators for `fieldName` without waiting for debounce delay.

```dart
controller.validateFieldImmediately(fieldName: 'promoCode', context: context);
```

##### 14. `resetForm()`
- **Returns**: `void`
- **Description**: Resets all field values to their `initialValue`, clears errors, resets touched states, and cancels all active async timers.

```dart
controller.resetForm();
```

##### 15. `touchAllFields(BuildContext context)`
- **Returns**: `void`
- **Description**: Marks every field in the form as touched and runs form validation.

```dart
controller.touchAllFields(context);
```

##### 16. `updateError({required String fieldName, String? errorMessage, required BuildContext context})`
- **Returns**: `void`
- **Description**: Manually overrides or clears the error message for a specific field (e.g., displaying server API responses).

```dart
controller.updateError(
  fieldName: 'email',
  errorMessage: 'Email already registered on server',
  context: context,
);
```

##### 17. `updateErrors({required Map<String, String?> errors, required BuildContext context})`
- **Returns**: `void`
- **Description**: Manually sets or clears error messages for multiple fields simultaneously.

```dart
controller.updateErrors(
  errors: {
    'username': 'Username taken',
    'password': 'Password too weak',
  },
  context: context,
);
```

##### 18. `addField<T>({required FormFieldDefinition<T> field, required BuildContext context})`
- **Returns**: `void`
- **Description**: Dynamically registers a new field definition into the form at runtime.

```dart
controller.addField<String>(
  field: FormFieldDefinition<String>(
    name: 'middleName',
    validators: [TypedCommonValidators.maxLength(30)],
  ),
  context: context,
);
```

##### 19. `addFields({required List<FormFieldDefinition> fields, required BuildContext context})`
- **Returns**: `void`
- **Description**: Dynamically registers multiple new field definitions into the form.

```dart
controller.addFields(fields: newFieldsList, context: context);
```

##### 20. `removeField(String fieldName, {required BuildContext context})`
- **Returns**: `void`
- **Description**: Dynamically unregisters a field from the form and removes its values and errors.

```dart
controller.removeField('spouseName', context: context);
```

##### 21. `removeFields(List<String> fieldNames, {required BuildContext context})`
- **Returns**: `void`
- **Description**: Unregisters multiple fields from the form dynamically.

```dart
controller.removeFields(['field1', 'field2'], context: context);
```

##### 22. `isTouched(String fieldName)`
- **Returns**: `bool`
- **Description**: Checks whether a specific field has been touched by the user.

```dart
final bool touched = controller.isTouched('email');
```

##### 23. `close()`
- **Returns**: `Future<void>`
- **Description**: Cancels all pending timers, disposes async validation handles, and disposes the BLoC cubit.

---

### `TypedFormState`

Immutable snapshot of form state.

#### Properties
- `values` (`Map<String, Object?>`): Map of field names to current raw values.
- `errors` (`Map<String, String>`): Map of field names to active error messages.
- `isValid` (`bool`): `true` if all fields pass validation and no active errors/validations exist.
- `validationStrategy` (`ValidationStrategy`): Current active validation timing rule.
- `fieldTypes` (`Map<String, Type>`): Map of field names to their expected Dart runtime types.
- `validatingFields` (`Set<String>`): Set of field names currently executing async validation routines.
- `isValidating` (`bool`): Getter returning `true` if `validatingFields.isNotEmpty`.

#### Methods & Factories
- `factory TypedFormState.initial()`: Constructs initial empty form state (`values: {}, errors: {}, isValid: false`).
- `getValue<T>(String fieldName)`: Type-safe field value getter.
- `getError(String fieldName)`: Returns error string for `fieldName` or `null`.
- `hasError(String fieldName)`: Returns `true` if `fieldName` has an active error.
- `copyWith(...)`: Returns a copy of state with specified fields replaced.

---

### `FormFieldDefinition<T>`

Declarative definition for a single form field.

#### Constructor Parameters

```dart
const FormFieldDefinition<T>({
  required String name,
  required List<Validator<T>> validators,
  List<AsyncValidator<T>>? asyncValidators,
  T? initialValue,
  String? group,
})
```

#### Properties
- `name` (`String`): Unique field identifier.
- `validators` (`List<Validator<T>>`): Synchronous validator rules.
- `asyncValidators` (`List<AsyncValidator<T>>?`): Asynchronous validator rules.
- `initialValue` (`T?`): Default initial value for this field.
- `group` (`String?`): Optional group identifier for partial form validation.
- `valueType` (`Type`): Getter returning type parameter `T`.

#### Methods
- `createValidator()`: Returns a `CompositeValidator<T>` combining `validators`.
- `copyWith(...)`: Creates a copy with modified properties.

---

### `ValidationStrategy` (Enum)

Determines when form validation rules are executed.

```dart
enum ValidationStrategy {
  onSubmitThenRealTime,  // Validates on submit; after first submission, validates in real-time
  allFieldsRealTime,     // Re-validates all fields in real-time on any value update
  realTimeOnly,          // Validates only the field currently being edited
  disabled,              // Disables automatic validation
  onSubmitOnly,          // Validates only when validateForm/validateGroup is called
}
```

#### Helper Properties & Methods
- `isSubmissionSpecific`: `true` for `onSubmitOnly` and `onSubmitThenRealTime`.
- `initialValidationState`: Default `isValid` boolean for initial form state (`true` for submission-specific/disabled, `false` for real-time).
- `shouldValidateOnFieldUpdate()`: Returns `true` for all strategies except `disabled`.
- `shouldValidateOnSubmission()`: Returns `true` for all strategies except `disabled`.
- `shouldSwitchAfterValidationFailure()`: Returns `true` for `onSubmitThenRealTime`.
- `getStrategyAfterValidationFailure()`: Returns `realTimeOnly` if strategy is `onSubmitThenRealTime`.
- `hasValidationErrorsFromEmptyValues(Map<String, Object?> currentValues)`: Checks if any value in `currentValues` is null or empty.

---

## 2. Widgets & Context Extensions Catalog

### `TypedFormProvider`

Stateful widget that initializes and provides `TypedFormController` to the widget subtree.

```dart
TypedFormProvider({
  Key? key,
  required List<FormFieldDefinition> fields,
  required Widget Function(BuildContext context) child,
  ValidationStrategy validationStrategy = ValidationStrategy.realTimeOnly,
  void Function(TypedFormState state)? onFormStateChanged,
})
```

- Static method: `TypedFormProvider.of(BuildContext context)` returns `TypedFormController`.

---

### `TypedFormBuilder`

Widget that rebuilds whenever `TypedFormState` changes.

```dart
TypedFormBuilder({
  Key? key,
  required Widget Function(BuildContext context, TypedFormState state) builder,
})
```

---

### `TypedFormListener`

Widget that listens to `TypedFormState` changes for side effects without rebuilding children.

```dart
TypedFormListener({
  Key? key,
  required void Function(BuildContext context, TypedFormState state) listener,
  required Widget child,
})
```

---

### `TypedFieldWrapper<T>`

High-performance widget for connecting any input widget to form state.

```dart
TypedFieldWrapper<T>({
  Key? key,
  required String fieldName,
  required Widget Function(BuildContext context, TypedFieldState<T> field) builder,
  T? initialValue,
  Duration? debounceTime,
  T Function(T value)? transformValue,
  void Function(T? value)? onValueChanged,
  void Function(T? value, String? error, bool hasError)? onFieldStateChanged,
})
```

---

### `TypedFieldState<T>`

Field snapshot passed into `TypedFieldWrapper`'s `builder` callback.

#### Properties
- `fieldName` (`String`): Identifier matching `FormFieldDefinition.name`.
- `value` (`T?`): Current typed field value.
- `error` (`String?`): Active error message.
- `hasError` (`bool`): `true` if `error` is non-null and non-empty.
- `isValidating` (`bool`): `true` if async validator is running for this field.
- `displayError` (`String?`): Returns `error` if `hasError` is `true`, otherwise `null`.
- `updateValue` (`void Function(T? value)`): Callback to update field value in form state.

---

### `TypedFormProviderExtension` (on `BuildContext`)

Succinct context extensions for form access:

| Method / Getter | Return Type | Description |
|---|---|---|
| `context.formCubit` | `TypedFormController` | Gets nearest `TypedFormController` |
| `context.formState` | `TypedFormState` | Gets current `TypedFormState` |
| `context.getFormValue<T>(fieldName)` | `T?` | Gets typed field value |
| `context.updateFormField<T>(fieldName, value, {touched = true})` | `void` | Updates field value |
| `context.validateForm({onValidationPass, onValidationFail})` | `FutureOr<void>` | Validates entire form |
| `context.validateGroup(groupName, {onValidationPass, onValidationFail})` | `void` | Validates a field group |
| `context.validateFields(fieldNames, {onValidationPass, onValidationFail})` | `void` | Validates list of fields |
| `context.isGroupValid(groupName)` | `bool` | Passively checks group validity |
| `context.areFieldsValid(fieldNames)` | `bool` | Passively checks fields validity |
| `context.touchGroup(groupName)` | `void` | Marks field group as touched |

---

## 3. Validators & Localizations Catalog

### Base Interfaces

```dart
abstract class Validator<T> {
  const Validator();
  String? validate(T? value, BuildContext context);
}

abstract class AsyncValidator<T> {
  const AsyncValidator();
  FutureOr<String?> validate(T? value, BuildContext context);
}

class CompositeValidator<T> implements Validator<T> {
  CompositeValidator(this.validators);
  final List<Validator<T>> validators;
  @override
  String? validate(T? value, BuildContext context);
}
```

---

### `TypedCommonValidators`

Static factories for standard field validators:

| Factory Method | Targeted Type | Parameters | Description |
|---|---|---|---|
| `required<T>` | `T` | `{BuildContext? context, String? errorText}` | Ensures value is non-null and non-empty |
| `email` | `String` | `{BuildContext? context, String? errorText}` | Validates standard email address format |
| `minLength` | `String` | `int minLength, {BuildContext? context, String? errorText}` | Minimum string length requirement |
| `maxLength` | `String` | `int maxLength, {BuildContext? context, String? errorText}` | Maximum allowed string length |
| `pattern` | `String` | `RegExp pattern, {BuildContext? context, String? errorText}` | Regular expression match requirement |
| `numeric` | `String` | `{BuildContext? context, String? errorText}` | Ensures string parses to valid `num` |
| `min` | `num` | `num minValue, {BuildContext? context, String? errorText}` | Minimum numeric value |
| `max` | `num` | `num maxValue, {BuildContext? context, String? errorText}` | Maximum numeric value |
| `url` | `String` | `{BuildContext? context, String? errorText}` | Validates HTTP/HTTPS URL format |
| `phoneNumber` | `String` | `{BuildContext? context, String? errorText}` | Validates phone number format |
| `creditCard` | `String` | `{BuildContext? context, String? errorText}` | Validates credit card number with Luhn check |
| `dateString` | `String` | `{BuildContext? context, String? errorText}` | Validates ISO date string via `DateTime.parse` |
| `ipAddress` | `String` | `{BuildContext? context, String? errorText}` | Validates IPv4 or IPv6 address format |
| `uuid` | `String` | `{BuildContext? context, String? errorText}` | Validates standard UUID format |
| `json` | `String` | `{BuildContext? context, String? errorText}` | Validates JSON format via `jsonDecode` |
| `alphanumeric` | `String` | `{BuildContext? context, String? errorText}` | Restricts input to letters and digits |
| `alphabetic` | `String` | `{BuildContext? context, String? errorText}` | Restricts input to letters only |
| `mustBeTrue` | `bool` | `{BuildContext? context, String? errorText}` | Requires boolean value to be `true` |
| `custom<T>` | `T` | `String? Function(T?, BuildContext) validator` | Functional custom validator wrapping |

---

### Conditional Validation Utilities

- `TypedConditionalValidator<T>`: Evaluates `condition(value, context)` and applies `validator` or `elseValidator`.
- `SwitchValidator<T>`: Evaluates a list of `ConditionalCase<T>` entries like a switch statement.
- `ChainValidator<T>`: Chains multiple `TypedConditionalValidator<T>` instances.
- `TypedConditionalValidators`:
  - `whenNotEmpty<T>(Validator<T> validator)`: Validates only when value is non-empty.
  - `whenEmpty<T>(Validator<T> validator)`: Validates only when value is empty.
  - `byLength(int threshold, shortValidator, longValidator)`: Switches validation based on string length.
  - `byValue(num threshold, smallValidator, largeValidator)`: Switches validation based on numeric value.
  - `byPattern(RegExp pattern, matchValidator, noMatchValidator)`: Switches based on regex match.
  - `custom<T>(predicate, trueValidator, falseValidator)`: Custom predicate-based branching.
  - `progressive(...)`: Applies increasingly strict validation rules as string length grows.

---

### Cross-Field Validation Utilities

- `TypedCrossFieldValidator<T>`: Base class reading form values from `BuildContext` and referencing `dependentFields`.
- `TypedCrossFieldValidators`:
  - `matches<T>(String matchFieldName, {String? errorText})`: Verifies two fields have equal values.
  - `differentFrom<T>(String otherFieldName, {String? errorText})`: Verifies two fields have different values.
  - `requiredWhen<T>(String dependentFieldName, dynamic requiredWhenValue, {String? errorText})`: Requires field when dependent field equals value.
  - `requiredWhenNotEmpty<T>(String dependentFieldName, {String? errorText})`: Requires field when dependent field is non-empty.
  - `dateBefore(String endDateFieldName, {String? errorText})`: Ensures `DateTime` is before end date.
  - `dateAfter(String startDateFieldName, {String? errorText})`: Ensures `DateTime` is after start date.
  - `greaterThan(String minFieldName, {String? errorText})`: Ensures numeric value is `>` dependent field value.
  - `lessThan(String maxFieldName, {String? errorText})`: Ensures numeric value is `<` dependent field value.
  - `sumCondition(List<String> fieldNames, bool Function(num sum) condition, {String? errorText})`: Validates sum of multiple fields.
  - `atLeastOneRequired<T>(List<String> fieldNames, {String? errorText})`: Ensures at least one field in group has value.

---

### Localization & Errors

- **`ValidatorLocalizations`**: Abstract localization interface containing error getters (`requiredFieldError`, `invalidEmailError`, `minLengthError`, etc.).
- **`ValidatorLocalizationsDelegate`**: `LocalizationsDelegate<ValidatorLocalizations>` with support for English (`en`), Spanish (`es`), French (`fr`), German (`de`), and Arabic (`ar`).
- **`FormFieldError`**: Specialized `Error` class providing `fieldName`, `message`, `suggestion`, and `debugInfo`.
  - Factories: `FormFieldError.fieldNotFound`, `FormFieldError.typeMismatch`, `FormFieldError.fieldAlreadyExists`, `FormFieldError.performanceWarning`.

---

## 4. Complete Code Examples for LLM Code Generation

### 1. Complete Registration Form with Localizations & Validation

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class RegistrationFormPage extends StatelessWidget {
  const RegistrationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      validationStrategy: ValidationStrategy.onSubmitThenRealTime,
      fields: [
        FormFieldDefinition<String>(
          name: 'email',
          initialValue: '',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
        ),
        FormFieldDefinition<String>(
          name: 'password',
          initialValue: '',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(8),
          ],
        ),
        FormFieldDefinition<String>(
          name: 'confirmPassword',
          initialValue: '',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCrossFieldValidators.matches<String>(
              'password',
              errorText: 'Passwords do not match',
            ),
          ],
        ),
        FormFieldDefinition<bool>(
          name: 'terms',
          initialValue: false,
          validators: [
            TypedCommonValidators.mustBeTrue(
              errorText: 'You must accept terms and conditions',
            ),
          ],
        ),
      ],
      child: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Register')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TypedFieldWrapper<String>(
                  fieldName: 'email',
                  transformValue: (val) => val.trim().toLowerCase(),
                  builder: (context, field) {
                    return TextField(
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        errorText: field.displayError,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TypedFieldWrapper<String>(
                  fieldName: 'password',
                  builder: (context, field) {
                    return TextField(
                      obscureText: true,
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
                    return TextField(
                      obscureText: true,
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
                  fieldName: 'terms',
                  builder: (context, field) {
                    return CheckboxListTile(
                      title: const Text('Accept Terms'),
                      value: field.value ?? false,
                      onChanged: field.updateValue,
                      subtitle: field.hasError
                          ? Text(
                              field.error!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : null,
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
                            final email = context.getFormValue<String>('email');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registered: $email')),
                            );
                          },
                        );
                      },
                      child: const Text('Submit'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

### 2. Multi-Step Form Wizard with Field Groups

```dart
class MultiStepWizard extends StatefulWidget {
  const MultiStepWizard({super.key});

  @override
  State<MultiStepWizard> createState() => _MultiStepWizardState();
}

class _MultiStepWizardState extends State<MultiStepWizard> {
  int _currentStep = 0;

  final _fields = <FormFieldDefinition>[
    // Step 0 Group
    FormFieldDefinition<String>(
      name: 'firstName',
      group: 'personal',
      initialValue: '',
      validators: [TypedCommonValidators.required<String>()],
    ),
    FormFieldDefinition<String>(
      name: 'lastName',
      group: 'personal',
      initialValue: '',
      validators: [TypedCommonValidators.required<String>()],
    ),
    // Step 1 Group
    FormFieldDefinition<String>(
      name: 'address',
      group: 'address',
      initialValue: '',
      validators: [TypedCommonValidators.required<String>()],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      fields: _fields,
      child: (context) {
        return Scaffold(
          appBar: AppBar(title: Text('Step ${_currentStep + 1}')),
          body: Column(
            children: [
              if (_currentStep == 0) ...[
                TypedFieldWrapper<String>(
                  fieldName: 'firstName',
                  builder: (context, field) => TextField(
                    onChanged: field.updateValue,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      errorText: field.displayError,
                    ),
                  ),
                ),
                TypedFieldWrapper<String>(
                  fieldName: 'lastName',
                  builder: (context, field) => TextField(
                    onChanged: field.updateValue,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      errorText: field.displayError,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.validateGroup(
                      'personal',
                      onValidationPass: () => setState(() => _currentStep = 1),
                    );
                  },
                  child: const Text('Next'),
                ),
              ] else ...[
                TypedFieldWrapper<String>(
                  fieldName: 'address',
                  builder: (context, field) => TextField(
                    onChanged: field.updateValue,
                    decoration: InputDecoration(
                      labelText: 'Street Address',
                      errorText: field.displayError,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.validateForm(
                          onValidationPass: () {
                            debugPrint('Wizard Complete!');
                          },
                        );
                      },
                      child: const Text('Finish'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
```

---

### 3. Custom Synchronous Validator Implementation

Custom synchronous validators can be created either as reusable classes extending `Validator<T>` or as inline closures using `TypedCommonValidators.custom<T>`:

#### Option A: Custom Class (`extends Validator<T>`)
```dart
class AgeRestrictionValidator extends Validator<int> {
  const AgeRestrictionValidator({this.minAge = 18, this.errorText});
  final int minAge;
  final String? errorText;

  @override
  String? validate(int? value, BuildContext context) {
    if (value == null) return null; // Defer null checks to required validator
    if (value < minAge) {
      return errorText ?? 'Must be at least $minAge years old';
    }
    return null;
  }
}
```

#### Option B: Closure-Based (`TypedCommonValidators.custom<T>`)
```dart
TypedCommonValidators.custom<String>(
  (value, context) {
    if (value != null && !value.startsWith('@')) {
      return 'Handle must start with @ symbol';
    }
    return null;
  },
  errorText: 'Invalid handle format',
)
```

### 4. Custom Async Validator Implementation

```dart
class UniqueUsernameValidator extends AsyncValidator<String> {
  const UniqueUsernameValidator(this.apiService);
  final ApiService apiService;

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.isEmpty) return null;
    final isTaken = await apiService.isUsernameTaken(value);
    if (isTaken) {
      return 'Username is already taken';
    }
    return null;
  }
}
```

### 5. Coexistence of Sync & Async Validators in Form Definition

When `validators` (sync) and `asyncValidators` (async) are provided together in the same field definition:

1. **Synchronous Execution First**: Static synchronous validators evaluate immediately on input mutation.
2. **Short-Circuiting**: If any sync validator fails, the sync error displays immediately and active/pending async validators for that field are **automatically cancelled** without making network/API requests.
3. **Debounced Async Execution**: Async validators are scheduled and debounced only after all synchronous checks return `null`.
4. **Precedence**: Synchronous failures immediately supersede async validation state or errors.
