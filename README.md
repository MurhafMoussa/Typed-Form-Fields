# Typed Form Fields

[![pub version](https://img.shields.io/pub/v/typed_form_fields.svg)](https://pub.dev/packages/typed_form_fields)
[![pub points](https://img.shields.io/pub/points/typed_form_fields.svg)](https://pub.dev/packages/typed_form_fields/score)
[![Live Web Demo](https://img.shields.io/badge/Live_Demo-GitHub_Pages-2ea44f?logo=github)](https://murhafmoussa.github.io/Typed-Form-Fields/)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

A **production-ready**, highly performant Flutter package for **type-safe form validation** with **universal widget integration**. The generic `TypedFieldWrapper<T>` widget seamlessly connects any Flutter widget (Material, Cupertino, Shadcn, Fluent, or custom design systems) to a reactive, zero-dependency state management engine.

---

## 📋 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [GitHub Pages Live Demo & Deep-Linking](#github-pages-live-demo--deep-linking)
- [Exhaustive API Reference](#exhaustive-api-reference)
  - [Core Controllers & State Models](#1-core-controllers--state-models)
    - [TypedFormController](#typedformcontroller)
    - [TypedFormState](#typedformstate)
    - [FormFieldDefinition\<T\>](#formfielddefinitiont)
    - [ValidationStrategy](#validationstrategy)
  - [UI Widgets & Context Extensions](#2-ui-widgets--context-extensions)
    - [TypedFormProvider](#typedformprovider)
    - [TypedFormBuilder](#typedformbuilder)
    - [TypedFormListener](#typedformlistener)
    - [TypedFieldWrapper\<T\>](#typedfieldwrappert)
    - [TypedFieldState\<T\>](#typedfieldstatet)
    - [TypedFormProviderExtension](#typedformproviderextension)
  - [Validators Catalog](#3-validators-catalog)
    - [TypedCommonValidators](#typedcommonvalidators)
    - [TypedConditionalValidators](#typedconditionalvalidators)
    - [Conditional Classes](#conditional-classes-typedconditionalvalidator-switchvalidator-chainvalidator)
    - [TypedCrossFieldValidators](#typedcrossfieldvalidators)
    - [TypedCrossFieldValidator\<T\>](#typedcrossfieldvalidatort)
    - [CompositeValidator\<T\> & Base Interfaces](#compositevalidatort--base-interfaces)
  - [Localizations & Error Handling](#4-localizations--error-handling)
    - [ValidatorLocalizations & Delegate](#validatorlocalizations--validatorlocalizationsdelegate)
    - [FormFieldError](#formfielderror)
- [Feature Guides & Code Snippets](#feature-guides--code-snippets)
  - [Async Validation Pipeline](#async-validation-pipeline--debouncing)
  - [Performance & BLoC Architecture](#performance--bloc-architecture)
  - [Universal Widget Integration](#universal-widget-integration)
  - [Cross-Field & Conditional Validation](#cross-field--conditional-validation)
  - [Field Grouping & Multi-Step Forms](#field-grouping--multi-step-forms)
  - [Dynamic Form Management](#dynamic-form-management)
- [AI Agent Skill](#ai-agent-skill)
- [License & Author](#license--author)

---

🌐 **Live Web Demo & Interactive Documentation Hub:** [murhafmoussa.github.io/Typed-Form-Fields/](https://murhafmoussa.github.io/Typed-Form-Fields/)

## Installation

Add `typed_form_fields` to your `pubspec.yaml` or run:

```bash
flutter pub add typed_form_fields
```

Import the package in your Dart code:

```dart
import 'package:typed_form_fields/typed_form_fields.dart';
```

---

## Quick Start

Wrap your view with `TypedFormProvider` and use `TypedFieldWrapper<T>` for individual inputs:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class QuickStartForm extends StatelessWidget {
  const QuickStartForm({super.key});

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
          initialValue: '',
        ),
        FormFieldDefinition<bool>(
          name: 'agreeToTerms',
          validators: [
            TypedCommonValidators.mustBeTrue(),
          ],
          initialValue: false,
        ),
      ],
      child: (context) => Scaffold(
        appBar: AppBar(title: const Text('Quick Start Form')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. Universal Email Input Wrapper
              TypedFieldWrapper<String>(
                fieldName: 'email',
                debounceTime: const Duration(milliseconds: 300),
                builder: (context, field) {
                  return TextFormField(
                    initialValue: field.value,
                    onChanged: field.updateValue,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      errorText: field.displayError,
                      suffixIcon: field.isValidating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Universal Checkbox Wrapper
              TypedFieldWrapper<bool>(
                fieldName: 'agreeToTerms',
                builder: (context, field) {
                  return CheckboxListTile(
                    title: const Text('I agree to the terms and conditions'),
                    value: field.value ?? false,
                    onChanged: (val) => field.updateValue(val ?? false),
                    subtitle: field.hasError
                        ? Text(field.error!, style: const TextStyle(color: Colors.red))
                        : null,
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Reactive Submit Button
              TypedFormBuilder(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isValid && state.validatingFields.isEmpty
                        ? () {
                            context.validateForm(
                              onValidationPass: () {
                                final email = state.getValue<String>('email');
                                final agree = state.getValue<bool>('agreeToTerms');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Submitted $email (Agree: $agree)')),
                                );
                              },
                            );
                          }
                        : null,
                    child: const Text('Submit Form'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## GitHub Pages Live Demo & Deep-Linking

The interactive Web Example App hosted on GitHub Pages utilizes hash/path routing (`/#/docs/:docId`) to allow direct deep-linking into specific documentation topics and live interactive widget showcases.

### Direct Web Deep-Link Routes (`/#/docs/:docId`)

| Route URL | Documentation Target | Description & Topic Covered |
| :--- | :--- | :--- |
| `/#/docs/getting-started` | Getting Started | Package setup, basic form initialization, and `TypedFieldWrapper<T>` usage |
| `/#/docs/core-concepts` | Core Concepts | Controllers, immutable form state, typed getters, and context extensions |
| `/#/docs/validation-strategies` | Validation Strategies | Comparison of submission and real-time validation execution strategies |
| `/#/docs/async-validation` | Async Validation | Async pipelines, debouncing, active validation spinners, and exception handling |
| `/#/docs/field-grouping` | Field Grouping | Group-level validation (`validateGroup`), step navigation, and wizards |
| `/#/docs/dynamic-form-management` | Dynamic Management | Runtime field addition/removal, error overrides, and validator updates |

When embedding documentation or linking from external websites, append any of the above paths to the live GitHub Pages base URL to navigate users directly to that topic.

---

## Exhaustive API Reference

### 1. Core Controllers & State Models

#### `TypedFormController`

The primary BLoC cubit managing form lifecycle, state transitions, validation routines, and dynamic modifications.

##### Constructor
```dart
TypedFormController({
  List<FormFieldDefinition> fields = const [],
  ValidationStrategy validationStrategy = ValidationStrategy.allFieldsRealTime,
  Duration asyncDebounceDelay = const Duration(milliseconds: 300),
  void Function(Object error, StackTrace stackTrace, String fieldName)? onAsyncValidationError,
})
```

##### Getters & Properties
- `Duration get asyncDebounceDelay`: Time delay before triggering asynchronous validation requests.
- `void Function(Object error, StackTrace stackTrace, String fieldName)? get onAsyncValidationError`: Callback triggered when an uncaught exception occurs during async validation.
- `Map<String, bool> get touchedFields`: Unmodifiable map of field names to their touched status (`true` if user interacted).
- `Map<String, Object?> get initialValues`: Initial value map captured when fields were registered or reset.
- `bool get isDirty`: Returns `true` if any field's current value differs from its `initialValue`.

##### Public Methods (Complete Signature List)

1. `T? getValue<T>(String fieldName)`  
   Retrieves the value of `fieldName` typed as `T?`. Throws `FormFieldError.fieldNotFound` if field is missing, or `FormFieldError.typeMismatch` if `T` doesn't match the field's declared type.
2. `void updateField<T>({required String fieldName, T? value, required BuildContext context, bool touched = true})`  
   Updates a single field's value, runs synchronous and debounced asynchronous validation according to the current strategy, and emits new state.
3. `void updateFieldWithDebounce<T>({required String fieldName, T? value, required BuildContext context})`  
   Updates a single field's value using debouncing logic for rapid inputs.
4. `void updateFields<T>({required Map<String, T?> fieldValues, required BuildContext context})`  
   Updates multiple field values simultaneously in a single atomic state emission.
5. `void updateFieldValidators<T>({required String name, required List<Validator<T>> validators, List<AsyncValidator<T>>? asyncValidators, required BuildContext context})`  
   Replaces the active sync and async validators for `name` at runtime and re-evaluates validity.
6. `void validateGroup(String groupName, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`  
   Executes validation for all fields tagged with `groupName`. Marks them touched and triggers `onValidationPass` or `onValidationFail`.
7. `void validateFields(List<String> fieldNames, {required BuildContext context, VoidCallback? onValidationPass, VoidCallback? onValidationFail})`  
   Executes validation for an explicit list of field names. Marks them touched and triggers callbacks.
8. `bool isGroupValid(String groupName, {required BuildContext context})`  
   Passively evaluates whether all fields in `groupName` are valid without modifying touched status or state.
9. `bool areFieldsValid(List<String> fieldNames, {required BuildContext context})`  
   Passively evaluates whether a list of field names are all valid without modifying touched status.
10. `void touchGroup(String groupName, {required BuildContext context})`  
    Marks all fields in `groupName` as touched and triggers a form state update.
11. `void setValidationStrategy(ValidationStrategy validationStrategy)`  
    Changes the active form `ValidationStrategy` dynamically.
12. `FutureOr<void> validateForm(BuildContext context, {required VoidCallback onValidationPass, VoidCallback? onValidationFail})`  
    Validates all form fields, flushes pending async debouncers, awaits all in-flight async validators, marks all fields touched, and executes `onValidationPass` or `onValidationFail`.
13. `void validateFieldImmediately({required String fieldName, required BuildContext context})`  
    Immediately executes synchronous and asynchronous validation for `fieldName`, bypassing debounce timers.
14. `void resetForm()`  
    Resets all fields to their `initialValue`, clears errors, resets touched tracking, and cancels in-flight async operations.
15. `void touchAllFields(BuildContext context)`  
    Marks every registered field as touched and re-validates the form.
16. `void updateError({required String fieldName, String? errorMessage, required BuildContext context})`  
    Manually injects or clears an error message for `fieldName` (e.g. backend server errors).
17. `void updateErrors({required Map<String, String?> errors, required BuildContext context})`  
    Manually sets or clears multiple field error messages at once.
18. `void addField<T>({required FormFieldDefinition<T> field, required BuildContext context})`  
    Dynamically registers a new `FormFieldDefinition<T>` into the form controller at runtime.
19. `void addFields({required List<FormFieldDefinition> fields, required BuildContext context})`  
    Dynamically registers multiple field definitions into the form controller at runtime.
20. `void removeField(String fieldName, {required BuildContext context})`  
    Dynamically unregisters a field from the form and removes its values/errors.
21. `void removeFields(List<String> fieldNames, {required BuildContext context})`  
    Dynamically unregisters multiple fields from the form.
22. `bool isTouched(String fieldName)`  
    Checks whether `fieldName` has been touched by user interaction or explicit validation.
23. `Future<void> close()`  
    Disposes all internal timers, async token completers, and cancels active validations.

---

#### `TypedFormState`

Immutable snapshot representing form values, error state, overall validity, and validating status.

```dart
const TypedFormState({
  required Map<String, Object?> values,
  required Map<String, String> errors,
  required bool isValid,
  ValidationStrategy validationStrategy = ValidationStrategy.realTimeOnly,
  required Map<String, Type> fieldTypes,
  Set<String> validatingFields = const {},
})
```

##### Properties
- `final Map<String, Object?> values`: Map of field name to current raw value.
- `final Map<String, String> errors`: Map of field name to active error text.
- `final bool isValid`: `true` if all fields pass validation and no fields are currently undergoing async validation.
- `final ValidationStrategy validationStrategy`: Active validation rule strategy.
- `final Map<String, Type> fieldTypes`: Map of field name to declared Dart value `Type`.
- `final Set<String> validatingFields`: Set of field names currently running asynchronous validation.
- `bool get isValidating`: Returns `true` if `validatingFields` is not empty.

##### Helper Methods
- `T? getValue<T>(String fieldName)`: Type-safe getter for field values with `FormFieldError` safety checks.
- `String? getError(String fieldName)`: Returns error string for `fieldName`, or `null`.
- `bool hasError(String fieldName)`: Returns `true` if `errors` contains a key for `fieldName`.
- `TypedFormState copyWith(...)`: Returns a modified copy of the form state.

---

#### `FormFieldDefinition<T>`

Immutable definition declaring a field's identity, static/async validators, initial value, and optional group tag.

```dart
const FormFieldDefinition({
  required String name,
  required List<Validator<T>> validators,
  List<AsyncValidator<T>>? asyncValidators,
  T? initialValue,
  String? group,
})
```

##### Properties
- `final String name`: Unique identifier for the field.
- `final List<Validator<T>> validators`: Synchronous validation rules.
- `final List<AsyncValidator<T>>? asyncValidators`: Optional asynchronous validation rules.
- `final T? initialValue`: Initial value assigned during creation and form resets.
- `final String? group`: Optional group tag for step/group validation.
- `Type get valueType`: Returns `T`.

##### Methods
- `Validator<T> createValidator()`: Returns a `CompositeValidator<T>` wrapping all synchronous validators.
- `FormFieldDefinition<T> copyWith(...)`: Returns a modified clone of this definition.

---

#### `ValidationStrategy`

Enum controlling when form validation rules execute.

```dart
enum ValidationStrategy {
  onSubmitOnly,
  onSubmitThenRealTime,
  realTimeOnly,
  allFieldsRealTime,
  disabled;
}
```

##### Strategy Behavior Matrix

| Strategy | Validation Trigger | Auto-Switch Behavior | `initialValidationState` |
| :--- | :--- | :--- | :--- |
| `onSubmitOnly` | Executes only when `validateForm()` or submit is called | None | `true` |
| `onSubmitThenRealTime` | Silent until submit; switches to real-time on first failure | Switches to `realTimeOnly` on failure | `true` |
| `realTimeOnly` | Validates edited fields in real time | None | `false` |
| `allFieldsRealTime` | Re-validates every field in the form on any value change | None | `false` |
| `disabled` | Automatic validation is completely disabled | None | `true` |

##### Getters & Methods
- `bool get isSubmissionSpecific`: `true` for `onSubmitOnly` and `onSubmitThenRealTime`.
- `bool get initialValidationState`: Default `isValid` value before user interaction.
- `bool shouldValidateOnFieldUpdate()`: Returns `true` unless strategy is `disabled`.
- `bool shouldValidateOnSubmission()`: Returns `true` unless strategy is `disabled`.
- `bool shouldSwitchAfterValidationFailure()`: Returns `true` for `onSubmitThenRealTime`.
- `ValidationStrategy? getStrategyAfterValidationFailure()`: Returns `realTimeOnly` if switching is needed.
- `bool hasValidationErrorsFromEmptyValues(Map<String, Object?> currentValues)`: Checks if empty values exist during submission strategy evaluation.

---

### 2. UI Widgets & Context Extensions

#### `TypedFormProvider`

Provides form state and `TypedFormController` to descendant widgets without requiring external dependencies like `flutter_bloc`.

```dart
TypedFormProvider({
  Key? key,
  required List<FormFieldDefinition> fields,
  required Widget Function(BuildContext context) child,
  ValidationStrategy validationStrategy = ValidationStrategy.realTimeOnly,
  void Function(TypedFormState state)? onFormStateChanged,
})
```

##### Static Methods
- `static TypedFormController of(BuildContext context)`: Retrieves the active `TypedFormController` from context, or throws a detailed `FlutterError` if not found.

---

#### `TypedFormBuilder`

Rebuilds its child widget whenever the overall `TypedFormState` changes.

```dart
TypedFormBuilder({
  Key? key,
  required Widget Function(BuildContext context, TypedFormState state) builder,
})
```

---

#### `TypedFormListener`

Listens for `TypedFormState` changes to execute side effects (such as showing dialogs, analytics logging, or screen navigation) without triggering widget rebuilds.

```dart
TypedFormListener({
  Key? key,
  required void Function(BuildContext context, TypedFormState state) listener,
  required Widget child,
})
```

---

#### `TypedFieldWrapper<T>`

Universal integration widget that binds any input widget to a form field using field-level `buildWhen` and `listenWhen` performance optimizations.

```dart
TypedFieldWrapper({
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

#### `TypedFieldState<T>`

Field-scoped state payload supplied to `TypedFieldWrapper` builder callbacks.

##### Properties
- `final String fieldName`: Field identifier.
- `final T? value`: Current typed value.
- `final String? error`: Active error text, or `null`.
- `final bool hasError`: `true` if `error` is non-null and non-empty.
- `final bool isValidating`: `true` if this specific field is running async validation.
- `final void Function(T? value) updateValue`: Callback to send updated value to controller.
- `String? get displayError`: Returns `error` if `hasError` is `true`, else `null`.

##### Methods
- `TypedFieldState<T> copyWith(...)`: Returns a modified clone of this field state.

---

#### `TypedFormProviderExtension`

Convenience extension methods on `BuildContext` for direct form access.

```dart
extension TypedFormProviderExtension on BuildContext {
  TypedFormController get formCubit;
  TypedFormState get formState;
  T? getFormValue<T>(String fieldName);
  void updateFormField<T>(String fieldName, T? value, {bool touched = true});
  FutureOr<void> validateForm({required VoidCallback onValidationPass, VoidCallback? onValidationFail});
  void validateGroup(String groupName, {VoidCallback? onValidationPass, VoidCallback? onValidationFail});
  void validateFields(List<String> fieldNames, {VoidCallback? onValidationPass, VoidCallback? onValidationFail});
  bool isGroupValid(String groupName);
  bool areFieldsValid(List<String> fieldNames);
  void touchGroup(String groupName);
}
```

---

### 3. Validators Catalog

#### `TypedCommonValidators`

Catalog of 19 out-of-the-box synchronous validators with built-in localization support.

```dart
class TypedCommonValidators {
  // 1. Value presence
  static Validator<T> required<T>({BuildContext? context, String? errorText});

  // 2. Email format
  static Validator<String> email({BuildContext? context, String? errorText});

  // 3. String minimum length
  static Validator<String> minLength(int minLength, {BuildContext? context, String? errorText});

  // 4. String maximum length
  static Validator<String> maxLength(int maxLength, {BuildContext? context, String? errorText});

  // 5. RegExp pattern matching
  static Validator<String> pattern(RegExp pattern, {BuildContext? context, String? errorText});

  // 6. Numeric string validation
  static Validator<String> numeric({BuildContext? context, String? errorText});

  // 7. Minimum numeric value
  static Validator<num> min(num minValue, {BuildContext? context, String? errorText});

  // 8. Maximum numeric value
  static Validator<num> max(num maxValue, {BuildContext? context, String? errorText});

  // 9. URL address format
  static Validator<String> url({BuildContext? context, String? errorText});

  // 10. Phone number format
  static Validator<String> phoneNumber({BuildContext? context, String? errorText});

  // 11. Credit card format (Luhn algorithm verified)
  static Validator<String> creditCard({BuildContext? context, String? errorText});

  // 12. Date string format (DateTime.parse)
  static Validator<String> dateString({BuildContext? context, String? errorText});

  // 13. IPv4 & IPv6 format
  static Validator<String> ipAddress({BuildContext? context, String? errorText});

  // 14. UUID format
  static Validator<String> uuid({BuildContext? context, String? errorText});

  // 15. Valid JSON string
  static Validator<String> json({BuildContext? context, String? errorText});

  // 16. Alphanumeric characters only
  static Validator<String> alphanumeric({BuildContext? context, String? errorText});

  // 17. Alphabetic letters only
  static Validator<String> alphabetic({BuildContext? context, String? errorText});

  // 18. Boolean must be true (for terms & checkboxes)
  static Validator<bool> mustBeTrue({BuildContext? context, String? errorText});

  // 19. Custom inline validator function
  static Validator<T> custom<T>(
    String? Function(T? value, BuildContext context) validator, {
    BuildContext? context,
    String? errorText,
  });
}
```

---

#### `TypedConditionalValidators`

Factory helpers for executing conditional validation rules based on field values or context.

- `static TypedConditionalValidator<T> whenNotEmpty<T>(Validator<T> validator)`: Applies validator only when field value is non-null and non-empty.
- `static TypedConditionalValidator<T> whenEmpty<T>(Validator<T> validator)`: Applies validator only when field value is empty.
- `static TypedConditionalValidator<String> byLength(int threshold, Validator<String> shortValidator, Validator<String> longValidator)`: Applies `shortValidator` if `length <= threshold`, else `longValidator`.
- `static TypedConditionalValidator<num> byValue(num threshold, Validator<num> smallValidator, Validator<num> largeValidator)`: Applies `smallValidator` if `value <= threshold`, else `largeValidator`.
- `static TypedConditionalValidator<String> byPattern(RegExp pattern, Validator<String> matchValidator, Validator<String> noMatchValidator)`: Applies `matchValidator` if pattern matches, else `noMatchValidator`.
- `static TypedConditionalValidator<T> custom<T>(bool Function(T? value, BuildContext context) predicate, Validator<T> trueValidator, Validator<T> falseValidator)`: Applies `trueValidator` or `falseValidator` based on custom predicate.
- `static ChainValidator<String> progressive({Validator<String>? basicValidator, Validator<String>? intermediateValidator, Validator<String>? advancedValidator, int intermediateThreshold = 3, int advancedThreshold = 8})`: Applies progressively stricter validation as character length grows.

---

#### Conditional Classes (`TypedConditionalValidator`, `SwitchValidator`, `ChainValidator`)

- `TypedConditionalValidator<T>({required bool Function(T? value, BuildContext context) condition, required Validator<T> validator, Validator<T>? elseValidator})`: Single conditional branch.
- `SwitchValidator<T>({required List<ConditionalCase<T>> validationCases, Validator<T>? defaultValidator})`: Multi-case conditional evaluation (switch statement for validators).
- `ConditionalCase<T>({required bool Function(T? value, BuildContext context) condition, required Validator<T> validator})`: Case tuple for `SwitchValidator`.
- `ChainValidator<T>({required List<TypedConditionalValidator<T>> validators, bool stopOnFirstError = true})`: Sequenced chain of conditional validators.

---

#### `TypedCrossFieldValidators`

Factory methods for cross-field dependency validation.

- `static TypedCrossFieldValidator<T> matches<T>(String matchFieldName, {String? errorText})`: Verifies field matches `matchFieldName` (e.g. password confirmation).
- `static TypedCrossFieldValidator<T> differentFrom<T>(String differentFromFieldName, {String? errorText})`: Verifies field differs from `differentFromFieldName`.
- `static TypedCrossFieldValidator<T> requiredWhen<T>(String dependentFieldName, dynamic requiredWhenValue, {String? errorText})`: Field becomes required when `dependentFieldName == requiredWhenValue`.
- `static TypedCrossFieldValidator<T> requiredWhenNotEmpty<T>(String dependentFieldName, {String? errorText})`: Field becomes required when `dependentFieldName` is non-empty.
- `static TypedCrossFieldValidator<DateTime> dateBefore(String endDateFieldName, {String? errorText})`: Verifies `DateTime` is before `endDateFieldName`.
- `static TypedCrossFieldValidator<DateTime> dateAfter(String startDateFieldName, {String? errorText})`: Verifies `DateTime` is after `startDateFieldName`.
- `static TypedCrossFieldValidator<num> greaterThan(String minFieldName, {String? errorText})`: Verifies numeric value is strictly greater than `minFieldName`.
- `static TypedCrossFieldValidator<num> lessThan(String maxFieldName, {String? errorText})`: Verifies numeric value is strictly less than `maxFieldName`.
- `static TypedCrossFieldValidator<num> sumCondition(List<String> fieldNames, bool Function(num sum) condition, {String? errorText})`: Validates sum of multiple fields against a boolean condition function.
- `static TypedCrossFieldValidator<T> atLeastOneRequired<T>(List<String> fieldNames, {String? errorText})`: Ensures at least one field in a named group contains a value.

---

#### `TypedCrossFieldValidator<T>`

Base class for custom cross-field validators.

```dart
class TypedCrossFieldValidator<T> extends Validator<T> {
  const TypedCrossFieldValidator({
    required this.dependentFields,
    required this.validator,
  });

  final List<String> dependentFields;
  final String? Function(
    T? value,
    Map<String, dynamic> fieldValues,
    BuildContext context,
  ) validator;
}
```

---

#### `CompositeValidator<T>` & Base Interfaces

- `abstract class Validator<T>`: Interface for synchronous validation. (`String? validate(T? value, BuildContext context)`).
- `abstract class AsyncValidator<T>`: Interface for asynchronous validation. (`FutureOr<String?> validate(T? value, BuildContext context)`).
- `class CompositeValidator<T> implements Validator<T>`: Combines a `List<Validator<T>>` into a single sequential validator that stops at the first error.

---

### 4. Localizations & Error Handling

#### `ValidatorLocalizations` & `ValidatorLocalizationsDelegate`

The package provides localized validator messages in 5 languages: English (`en`), Spanish (`es`), French (`fr`), German (`de`), and Arabic (`ar`).

##### Setup in MaterialApp
```dart
MaterialApp(
  localizationsDelegates: const [
    ValidatorLocalizationsDelegate.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ar'),
  ],
)
```

##### Accessing Localizations
```dart
final localizations = ValidatorLocalizations.of(context);
print(localizations.requiredFieldError);
```

##### Concrete Localization Classes
- `EnglishValidatorLocalizations`
- `SpanishValidatorLocalizations`
- `FrenchValidatorLocalizations`
- `GermanValidatorLocalizations`
- `ArabicValidatorLocalizations`

---

#### `FormFieldError`

Custom error class thrown during illegal controller operations with clear debug details and suggestions.

##### Properties
- `final String fieldName`: Target field name.
- `final String message`: Error description.
- `final String suggestion`: Actionable fix suggestion for developers.
- `final String? debugInfo`: Diagnostic stack/state information (populated in debug mode).

##### Factory Constructors
- `factory FormFieldError.fieldNotFound({required String fieldName, required List<String> availableFields, required Map<String, Type> fieldTypes, required Map<String, Object?> currentValues})`
- `factory FormFieldError.typeMismatch({required String fieldName, required Type expectedType, required Type actualType, required String operation})`
- `factory FormFieldError.fieldAlreadyExists({required String fieldName})`
- `factory FormFieldError.performanceWarning({required String fieldName, required String issue, required String recommendation})`

---

## Feature Guides & Code Snippets

### Creating Custom Synchronous Validators

You can create custom synchronous validators in two ways:

#### Option A: Class-Based (`extends Validator<T>`)
Extend `Validator<T>` to create reusable, configurable validator classes:

```dart
class AgeRestrictionValidator extends Validator<int> {
  const AgeRestrictionValidator({this.minAge = 18, this.errorText});
  final int minAge;
  final String? errorText;

  @override
  String? validate(int? value, BuildContext context) {
    if (value == null) return null; // Defer null checks to required validator
    if (value < minAge) {
      return errorText ?? 'You must be at least $minAge years old';
    }
    return null;
  }
}

// Attach to FormFieldDefinition
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
Use `TypedCommonValidators.custom<T>` for quick inline validation rules:

```dart
FormFieldDefinition<String>(
  name: 'handle',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.custom<String>(
      (value, context) {
        if (value != null && !value.startsWith('@')) {
          return 'Handle must start with @ symbol';
        }
        return null;
      },
    ),
  ],
  initialValue: '',
)
```

### Async Validation Pipeline & Debouncing

Perform asynchronous checks (e.g. checking username availability against an API) without blocking UI rendering or spamming network endpoints:

```dart
// 1. Define custom AsyncValidator
class UsernameAvailabilityValidator extends AsyncValidator<String> {
  const UsernameAvailabilityValidator(this.apiService);
  final ApiService apiService;

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.isEmpty) return null;
    final isTaken = await apiService.isUsernameTaken(value);
    return isTaken ? 'Username is already taken' : null;
  }
}

// 2. Attach to FormFieldDefinition
FormFieldDefinition<String>(
  name: 'username',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.minLength(3),
  ],
  asyncValidators: [
    UsernameAvailabilityValidator(apiService),
  ],
  initialValue: '',
)

// 3. Render spinner reactively with field.isValidating
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
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
    );
  },
)
```

#### Coexistence of Synchronous and Asynchronous Validators

When a field contains both `validators` (synchronous) and `asyncValidators` (asynchronous):

1. **Synchronous First**: Synchronous static validators execute **instantly and first** on input changes.
2. **Short-Circuiting on Failure**: If any synchronous validator fails (e.g., required field empty or minLength unmet), the synchronous error displays immediately. Any pending or active async validation tasks for that field are **automatically cancelled**, preventing unnecessary API calls and database load.
3. **Async Execution on Sync Success**: Async validators are debounced and executed **only after** all synchronous validators pass cleanly.
4. **Error Precedence**: If the user modifies input and triggers a synchronous error while an async check is running or failed, the synchronous error immediately replaces the async error and cancels pending async operations.

---

### Performance & BLoC Architecture

The package leverages **BLoC internally** while exposing a zero-dependency API to consumers:

- **Field-Specific Rebuilds (`buildWhen` / `listenWhen`):** `TypedFieldWrapper` only rebuilds when its specific field's value, error text, or `isValidating` status changes.
- **Form State Isolation:** Unrelated text changes in Field A will never trigger rebuilds in Field B.
- **No Extra Dependencies:** You do not need `flutter_bloc` in your `pubspec.yaml`.

---

### Universal Widget Integration

Connect any third-party or custom UI component to `typed_form_fields`:

#### Material Dropdown
```dart
TypedFieldWrapper<String>(
  fieldName: 'country',
  builder: (context, field) {
    return DropdownButtonFormField<String>(
      value: (field.value == null || field.value!.isEmpty) ? null : field.value,
      onChanged: field.updateValue,
      decoration: InputDecoration(
        labelText: 'Country',
        errorText: field.displayError,
      ),
      items: const [
        DropdownMenuItem(value: 'US', child: Text('United States')),
        DropdownMenuItem(value: 'CA', child: Text('Canada')),
      ],
    );
  },
)
```

#### Custom Switch Tile
```dart
TypedFieldWrapper<bool>(
  fieldName: 'notifications',
  builder: (context, field) {
    return SwitchListTile(
      title: const Text('Enable Push Notifications'),
      value: field.value ?? false,
      onChanged: field.updateValue,
    );
  },
)
```

---

### Cross-Field & Conditional Validation

```dart
// Password confirmation
FormFieldDefinition<String>(
  name: 'confirmPassword',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCrossFieldValidators.matches<String>('password'),
  ],
  initialValue: '',
)

// Conditional validation rule
FormFieldDefinition<String>(
  name: 'taxId',
  validators: [
    TypedConditionalValidators.custom<String>(
      (value, context) => context.getFormValue<bool>('isBusiness') == true,
      TypedCommonValidators.required<String>(),
      TypedCommonValidators.custom<String>((val, ctx) => null),
    ),
  ],
  initialValue: '',
)
```

---

### Field Grouping & Multi-Step Forms

Tag definitions with `group` tags to create step-by-step wizards:

```dart
// 1. Tag definition with group name
FormFieldDefinition<String>(
  name: 'street',
  group: 'address_step',
  validators: [TypedCommonValidators.required<String>()],
  initialValue: '',
)

// 2. Validate step on button press
void onNextStepPressed(BuildContext context) {
  context.validateGroup(
    'address_step',
    onValidationPass: () => goToNextStep(),
    onValidationFail: () => showToast('Please fix address errors'),
  );
}
```

---

### Dynamic Form Management

Modify form structure dynamically at runtime:

```dart
final controller = context.formCubit;

// Add new field dynamically
controller.addField<String>(
  field: FormFieldDefinition<String>(
    name: 'middleName',
    validators: [],
    initialValue: '',
  ),
  context: context,
);

// Remove field dynamically
controller.removeField('middleName', context: context);

// Inject server-side validation error
controller.updateError(
  fieldName: 'email',
  errorMessage: 'Email already registered on server.',
  context: context,
);

// Reset form to initial values
controller.resetForm();
```

---

## AI Agent Skill

This package includes an official **AI Agent Skill** located at `.agents/skills/typed-form-fields/SKILL.md`. AI coding tools (such as OpenCode, Claude Code, Cursor, GitHub Copilot Workspace) can read this skill file to generate, refactor, and inspect forms adhering to package best practices.

---

## License & Author

This package is licensed under the [MIT License](LICENSE).

### Author

**Murhaf Moussa** — Software Engineer
- 🌐 **GitHub**: [@MurhafMoussa](https://github.com/MurhafMoussa)
- 💼 **LinkedIn**: [murhaf-n-moussa](https://www.linkedin.com/in/murhaf-n-moussa/)
- 📺 **YouTube**: [@QualityAddict](https://www.youtube.com/@QualityAddict)
