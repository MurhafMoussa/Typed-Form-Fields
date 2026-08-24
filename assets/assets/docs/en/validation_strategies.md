# Validation Strategies & Rules

`Typed-Form-Fields` offers fine-grained control over validation timing, built-in common rules, cross-field dependency checks, conditional combinators, and internationalized error messaging.

## Overview & Categories

Validation in `Typed-Form-Fields` spans five distinct pillars:
1. **Validation Strategies**: Timing rules controlling when validators execute (`onSubmitThenRealTime`, `realTimeOnly`, `onSubmitOnly`, `allFieldsRealTime`, `disabled`).
2. **Built-in Common Validators**: 19 pre-packaged synchronous validators in `TypedCommonValidators`.
3. **Cross-Field Validators**: 10 reactive cross-field dependency checkers in `TypedCrossFieldValidators`.
4. **Conditional & Composite Combinators**: Logic wrappers (`TypedConditionalValidators`, `SwitchValidator`, `ChainValidator`, `CompositeValidator`).
5. **Localization & Diagnostics**: `ValidatorLocalizations`, `ValidatorLocalizationsDelegate`, and `FormFieldError` structured diagnostic exceptions.

---

## Detailed API Breakdown

### 1. `ValidationStrategy` Modes

Set the active strategy when instantiating `TypedFormProvider` or dynamically via `controller.setValidationStrategy()`.

| Strategy | Description | Key Advantage / Use Case |
| --- | --- | --- |
| `onSubmitThenRealTime` | Silent until user attempts submit; after submission, validates on every change. | **Default.** Optimal balance avoiding premature errors while offering instant feedback once submitted. |
| `realTimeOnly` | Validates active field immediately on every value update. | Best for search boxes or instant-feedback forms. |
| `onSubmitOnly` | Errors remain hidden until `validateForm()`, `validateGroup()`, or submission is triggered. | Best for lengthy linear questionnaires. |
| `allFieldsRealTime` | Re-evaluates every field in the form whenever any single field value changes. | Essential for heavily inter-dependent forms where changes impact distant fields. |
| `disabled` | Disables automatic validation execution entirely. | Best for draft auto-saving or read-only modes. |

---

### 2. Complete Catalog of 19 `TypedCommonValidators`

All common validators accept optional `BuildContext` for localization and `String? errorText` for custom message overrides.

| Validator Method | Target Value Type | Description / Condition |
| --- | --- | --- |
| `required<T>()` | `T?` | Fails if value is `null`, empty string, or empty iterable. |
| `email()` | `String?` | Validates RFC-compliant email address structure. |
| `minLength(int min)` | `String?` / `Iterable?` | Fails if length is strictly less than `min`. |
| `maxLength(int max)` | `String?` / `Iterable?` | Fails if length exceeds `max`. |
| `pattern(RegExp pattern)` | `String?` | Fails if string does not match regex `pattern`. |
| `numeric()` | `String?` | Fails if string cannot be parsed into a `num`. |
| `min(num minValue)` | `num?` / `String?` | Fails if numeric value is strictly less than `minValue`. |
| `max(num maxValue)` | `num?` / `String?` | Fails if numeric value exceeds `maxValue`. |
| `url()` | `String?` | Validates HTTP/HTTPS URI string format. |
| `phoneNumber()` | `String?` | Validates international E.164 / standard phone number structure. |
| `creditCard()` | `String?` | Validates Luhn checksum for payment card numbers. |
| `dateString()` | `String?` | Fails if string is not a valid ISO-8601 date representation. |
| `ipAddress()` | `String?` | Validates IPv4 or IPv6 network address format. |
| `uuid()` | `String?` | Validates standard 36-character UUID string format. |
| `json()` | `String?` | Fails if string cannot be parsed via `jsonDecode`. |
| `alphanumeric()` | `String?` | Fails if string contains non-alphanumeric characters. |
| `alphabetic()` | `String?` | Fails if string contains non-letter characters. |
| `mustBeTrue()` | `bool?` | Fails if boolean value is `false` or `null` (e.g., Terms of Service checkbox). |
| `custom<T>(Validator<T>)` | `T?` | Wraps custom `Validator<T>` instance or closure. |

---

### 3. Cross-Field Dependency Validators (`TypedCrossFieldValidators`)

`TypedCrossFieldValidators` compare field values across the form state.

| Validator Method | Description | Example Use Case |
| --- | --- | --- |
| `matches<T>('field')` | Fails if current field value != `field` value. | Password confirmation matching. |
| `differentFrom<T>('field')` | Fails if current field value == `field` value. | Ensure new password != old password. |
| `requiredWhen<T>('field', val)` | Requires current field if `field` value equals `val`. | Mandatory state box when country == 'USA'. |
| `requiredWhenNotEmpty<T>('field')` | Requires current field when `field` has non-empty value. | Spouse details when marital status entered. |
| `dateBefore('field')` | Fails if current Date/ISO string is not before `field` date. | Check-in date before check-out date. |
| `dateAfter('field')` | Fails if current Date/ISO string is not after `field` date. | Expiration date after issue date. |
| `greaterThan('field')` | Fails if current numeric value is not > `field` numeric value. | Maximum budget > minimum budget. |
| `lessThan('field')` | Fails if current numeric value is not < `field` numeric value. | Min temperature < max temperature. |
| `sumCondition(fields, cond)` | Sums values of `fields` and fails if `cond(sum)` is false. | Multi-part allocation percentages sum to 100%. |
| `atLeastOneRequired(fields)` | Fails if none of the listed `fields` have non-empty values. | Either Email or Phone required for contact. |

---

### 4. Creating Custom Synchronous Validators

Custom synchronous validators can be authored either by creating reusable classes extending `Validator<T>` or by using `TypedCommonValidators.custom<T>` for inline rules.

#### Option A: Class-Based (`extends Validator<T>`)
Extend `Validator<T>` and override `validate(T? value, BuildContext context)`:

```dart
class AgeRestrictionValidator extends Validator<int> {
  const AgeRestrictionValidator({this.minAge = 18, this.errorText});
  final int minAge;
  final String? errorText;

  @override
  String? validate(int? value, BuildContext context) {
    if (value == null) return null; // Defer null check to required validator
    if (value < minAge) {
      return errorText ?? 'You must be at least $minAge years old';
    }
    return null;
  }
}

// Usage in FormFieldDefinition
FormFieldDefinition<int>(
  name: 'age',
  validators: const [
    TypedCommonValidators.required<int>(),
    AgeRestrictionValidator(minAge: 21),
  ],
  initialValue: 0,
)
```

#### Option B: Closure-Based (`TypedCommonValidators.custom<T>`)
Pass an inline validation function to `TypedCommonValidators.custom<T>`:

```dart
FormFieldDefinition<String>(
  name: 'handle',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.custom<String>(
      (value, context) {
        if (value != null && !value.startsWith('@')) {
          return 'Social handle must start with @ symbol';
        }
        return null;
      },
    ),
  ],
  initialValue: '',
)
```

---

### 5. Advanced & Conditional Validator Combinators

| Combinator | Description | Usage Example |
| --- | --- | --- |
| `TypedConditionalValidators.whenNotEmpty(v)` | Runs nested validator `v` only when input is non-empty. | Optional field that must be a valid email if provided. |
| `TypedConditionalValidator(condition, v)` | Runs `v` only when boolean closure `condition(val, ctx)` evaluates `true`. | Conditional rules based on external state or context. |
| `SwitchValidator` | Selects validator branch based on expression match. | Dynamic validation based on selected user role type. |
| `ChainValidator` | Sequentially executes list of validators; halts at first error. | Short-circuiting execution pipeline. |
| `CompositeValidator` | Runs all validators and joins non-null errors into single string. | Collecting all failing password policies simultaneously. |

---

### 6. Coexistence of Synchronous and Asynchronous Validators

When a developer provides both `validators` (synchronous) and `asyncValidators` (asynchronous) in the same field or form definition:

1. **Synchronous Validation Executes First**: Synchronous static validators evaluate immediately on every input change.
2. **Short-Circuiting on Failure**: If any synchronous validator fails (e.g., required or minLength fails), the synchronous error displays immediately. Active or pending async validators for that field are **automatically cancelled** without making API or database calls.
3. **Async Scheduling on Success**: Async validators are debounced and executed **only after** all synchronous checks return `null`.
4. **Error Precedence**: Synchronous errors take immediate precedence over async errors, automatically overriding them whenever the user edits input into a state violating synchronous rules.

---

### 7. Localizations & Structured Diagnostics

`Typed-Form-Fields` provides multi-language support out of the box via `ValidatorLocalizations` (supported locales: `en`, `es`, `fr`, `de`, `ar`).

```dart
// Register delegate in MaterialApp
MaterialApp(
  localizationsDelegates: const [
    ValidatorLocalizationsDelegate.delegate,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'), Locale('es'), Locale('fr'), Locale('de'), Locale('ar'),
  ],
  // ...
)
```

#### Diagnostic Error Factories (`FormFieldError`)

Structured diagnostic exceptions assist during debugging and development:
- `FormFieldError.fieldNotFound(name)`: Thrown when attempting operation on unregistered field.
- `FormFieldError.typeMismatch(name, expected, actual)`: Thrown when `getValue<T>()` cast fails.
- `FormFieldError.fieldAlreadyExists(name)`: Thrown when adding duplicate field name.
- `FormFieldError.performanceWarning(msg)`: Emitted for unoptimized form configurations.

---

## Step-by-Step Code Walkthrough

### Step 1: Choosing a Validation Strategy

Set the global validation timing mode when constructing `TypedFormProvider` or `TypedFormController`:

```dart
TypedFormProvider(
  validationStrategy: ValidationStrategy.onSubmitThenRealTime, // Default strategy
  fields: [ /* ... */ ],
  child: (context) => const FormWidget(),
)
```

### Step 2: Combining Common & Cross-Field Validators

Combine built-in common and cross-field validators in field definitions:

```dart
FormFieldDefinition<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required<String>(errorText: 'Password is required'),
    TypedCommonValidators.minLength(8, errorText: 'Must be at least 8 characters'),
  ],
  initialValue: '',
),
FormFieldDefinition<String>(
  name: 'confirmPassword',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCrossFieldValidators.matches<String>(
      'password',
      errorText: 'Passwords do not match',
    ),
  ],
  initialValue: '',
)
```

### Step 3: Conditional Validation (`TypedConditionalValidator`)

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
        errorText: 'Phone number required for SMS updates',
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
              errorText: 'Passwords do not match',
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
                errorText: 'Note is required when checkbox is enabled',
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
