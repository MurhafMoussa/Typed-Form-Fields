# Typed Form Fields

[![pub version](https://img.shields.io/pub/v/typed_form_fields.svg)](https://pub.dev/packages/typed_form_fields)
[![pub points](https://img.shields.io/pub/points/typed_form_fields.svg)](https://pub.dev/packages/typed_form_fields/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

A **production-ready** Flutter package for **type-safe form validation** with **universal widget integration**. The high-performance `TypedFieldWrapper<T>` widget makes any Flutter widget work seamlessly with reactive form validation.

## Installation

```bash
flutter pub add typed_form_fields
```

## Quick Start

### 🎯 **TypedFieldWrapper Integration (Recommended)**

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MyForm extends StatelessWidget {
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
          name: 'subscribe',
          validators: [],
          initialValue: false,
        ),
      ],
      child: (context) => Column(
        children: [
          // Email field using TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'email',
            debounceTime: Duration(milliseconds: 300),
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

          SizedBox(height: 16),

          // Checkbox field using TypedFieldWrapper
          TypedFieldWrapper<bool>(
            fieldName: 'subscribe',
            builder: (context, field) {
              return CheckboxListTile(
                title: Text('Subscribe to newsletter'),
                value: field.value ?? false,
                onChanged: (val) => field.updateValue(val ?? false),
              );
            },
          ),

          SizedBox(height: 24),

          // Submit button with reactive validation
          TypedFormBuilder(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isValid && state.validatingFields.isEmpty
                    ? () {
                        context.validateForm(
                          onValidationPass: () {
                            // Type-safe access to form values
                            final email = state.getValue<String>('email');
                            final subscribe = state.getValue<bool>('subscribe');
                            print('Email: $email, Subscribe: $subscribe');
                          },
                        );
                      }
                    : null,
                child: Text('Submit'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## 📥 **Accessing Field Values & Form State**

You can get the value of any field in your form using the `getValue<T>(fieldName)` method on the form state or context extensions. You can also inspect dirty state, initial values, and touched status.

```dart
// Accessing field values
final email = state.getValue<String>('email');
final subscribe = state.getValue<bool>('subscribe');

// Form state inspection
final controller = context.formCubit;
print('Is form dirty? ${controller.isDirty}'); // True if any value changed from initialValue
print('Initial values: ${controller.initialValues}'); // Map of field name -> initial value
print('Touched fields: ${controller.touchedFields}'); // Map of field name -> bool
print('Is email touched? ${controller.isTouched('email')}');
```

## 🚀 **Key Features**

- **Type-safe, universal form field wrapper** (`TypedFieldWrapper<T>`)
- **Zero dependencies** - no `flutter_bloc` required for consumers
- **UI-Agnostic** - works with Material, Cupertino, Shadcn, Fluent, or custom design systems
- **Async Validation Pipeline** - debounced async validators (`AsyncValidator<T>`), submission flushing, and error safety
- **Real-time Async Progress** - `state.validatingFields` and `field.isValidating` for live UI feedback
- **Form State Tracking** - `isDirty`, `initialValues`, `touchedFields`, and `isTouched`
- **Field Grouping & Multi-step Validation** (`validateGroup`, `isGroupValid`, `touchGroup`, `validateFields`, `areFieldsValid`)
- **5 Validation Strategies** (`onSubmitOnly`, `onSubmitThenRealTime`, `realTimeOnly`, `allFieldsRealTime`, `disabled`)
- **Cross-field, conditional, and composite validation**
- **Localization** in 5 languages out of the box (English, Spanish, French, German, Arabic)
- **Official AI Agent Skill** included (`.agents/skills/typed-form-fields/SKILL.md`) for AI coding assistant integration

## ⚡ **Async Validation Pipeline & Debouncing**

Perform asynchronous checks (e.g. checking username availability against a backend API) without blocking UI rendering or spamming network endpoints:

```dart
// 1. Create an AsyncValidator
class CheckUsernameAvailabilityValidator extends AsyncValidator<String> {
  const CheckUsernameAvailabilityValidator(this.apiService);
  final ApiService apiService;

  @override
  Future<String?> validate(String? value, BuildContext context) async {
    if (value == null || value.isEmpty) return null;
    final isTaken = await apiService.isUsernameTaken(value);
    return isTaken ? 'Username is already taken' : null;
  }
}

// 2. Add to FormFieldDefinition
FormFieldDefinition<String>(
  name: 'username',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.minLength(3),
  ],
  asyncValidators: [
    CheckUsernameAvailabilityValidator(apiService),
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

**Key Async Features:**
- **Automatic Debouncing:** Async validation triggers after static sync validation passes and waits `asyncDebounceDelay` (default 300ms).
- **Submission Flushing:** Calling `validateForm()` flushes pending debouncers and awaits all in-flight async validators before triggering `onValidationPass` or `onValidationFail`.
- **Form Reset Cancellation:** Resetting the form automatically cancels in-flight async validation timers.
- **Exception Safety:** Catch uncaught async exceptions cleanly with `onAsyncValidationError`.

## ⚡ **Performance Optimizations**

The package uses **BLoC internally** for maximum performance while maintaining a **zero-dependency API** for users:

### **Field-Specific Rebuilds**

- **`buildWhen`** - Only rebuilds when the specific field's value, error, or validation status changes
- **`listenWhen`** - Only triggers listeners for relevant field changes
- **Prevents unnecessary rebuilds** - Other fields changing won't affect unrelated widgets

### **Optimized State Management**

- **BlocConsumer** for `TypedFieldWrapper` with field-specific conditions
- **BlocBuilder** for `TypedFormBuilder` with direct state access
- **BlocListener** for `TypedFormListener` with automatic lifecycle management
- **BlocProvider** for `TypedFormProvider` with battle-tested performance

## 🎨 **Universal Integration via `TypedFieldWrapper<T>`**

`TypedFieldWrapper<T>` connects **any UI widget or design system** to the form engine with zero coupling:

### 📝 **Text Input Example**

```dart
TypedFieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  builder: (context, field) {
    return TextFormField(
      initialValue: field.value,
      onChanged: field.updateValue,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        errorText: field.displayError,
      ),
    );
  },
)
```

### ✅ **Selection / Toggle Example**

```dart
TypedFieldWrapper<bool>(
  fieldName: 'terms',
  builder: (context, field) {
    return CheckboxListTile(
      title: Text('I agree to terms'),
      value: field.value ?? false,
      onChanged: (val) => field.updateValue(val ?? false),
      subtitle: field.hasError ? Text(field.error!, style: TextStyle(color: Colors.red)) : null,
    );
  },
)
```

### 🔽 **Dropdown Example**

```dart
TypedFieldWrapper<String>(
  fieldName: 'country',
  builder: (context, field) {
    return DropdownButtonFormField<String>(
      value: (field.value == null || field.value!.isEmpty) ? null : field.value,
      onChanged: field.updateValue,
      decoration: InputDecoration(
        labelText: 'Select Country',
        errorText: field.displayError,
      ),
      items: ['USA', 'Canada', 'UK']
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
    );
  },
)
```

## 📋 **Common Validators (`TypedCommonValidators`)**

| Validator             | Description              | Example                                                                                                   |
| --------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------- |
| `required<T>()`       | Field cannot be empty    | `TypedCommonValidators.required<String>()`                                                                |
| `email()`             | Valid email format       | `TypedCommonValidators.email()`                                                                           |
| `minLength(int)`      | Minimum character length | `TypedCommonValidators.minLength(8)`                                                                      |
| `maxLength(int)`      | Maximum character length | `TypedCommonValidators.maxLength(50)`                                                                     |
| `pattern(RegExp)`     | Matches regex pattern    | `TypedCommonValidators.pattern(RegExp(r'^\d+$'))`                                                         |
| `min(num)`            | Minimum numeric value    | `TypedCommonValidators.min(18)`                                                                           |
| `max(num)`            | Maximum numeric value    | `TypedCommonValidators.max(100)`                                                                          |
| `phoneNumber()`       | Valid phone number       | `TypedCommonValidators.phoneNumber()`                                                                     |
| `creditCard()`        | Valid credit card        | `TypedCommonValidators.creditCard()`                                                                      |
| `url()`               | Valid URL format         | `TypedCommonValidators.url()`                                                                             |
| `custom<T>(function)` | **Custom logic**         | `TypedCommonValidators.custom<String>((v, ctx) => v?.contains('x') == true ? null : 'Must contain x')`    |
| `mustBeTrue()`        | **Boolean must be true** | `TypedCommonValidators.mustBeTrue()` (for required checkboxes)                                            |

## 🔗 **Cross-Field Validation**

```dart
// Password confirmation using built-in validator
TypedCrossFieldValidators.matches<String>('password')

// Custom cross-field validator
final customCrossValidator = TypedCrossFieldValidator<double>(
  dependentFields: ['marketingBudget', 'developmentBudget'],
  validator: (value, allValues, context) {
    final marketing = allValues['marketingBudget'] as double? ?? 0;
    final development = allValues['developmentBudget'] as double? ?? 0;
    final total = value ?? 0;

    if (total < marketing + development) {
      return 'Total budget must be at least ${marketing + development}';
    }

    return null;
  },
);
```

## 🧩 **Conditional Validation**

`TypedConditionalValidator` lets you apply validation rules conditionally based on context or form state:

```dart
// Only require a field if user selected specific option
final validator = TypedConditionalValidator<String>(
  condition: (value, context) => context.getFormValue<bool>('requirePhone') == true,
  validator: TypedCommonValidators.required<String>(),
);

// Built-in helper: validate only when field is not empty
final emailValidator = TypedConditionalValidators.whenNotEmpty(
  TypedCommonValidators.email(),
);
```

## ⚙️ **Validation Strategies**

Control exactly when field validation triggers:

| Strategy                 | Description                                                           |
| ------------------------ | --------------------------------------------------------------------- |
| **onSubmitOnly**         | Validates only on form submission (does not auto-switch)               |
| **onSubmitThenRealTime** | Validates on submit; switches to real-time after first failed submit  |
| **realTimeOnly**         | Validates edited fields in real time (Default)                        |
| **allFieldsRealTime**    | Re-validates all fields on every value change                         |
| **disabled**             | Disables automatic validation                                         |

## 🧱 **Field Grouping & Multi-Step Forms**

Tag form fields with a `group` metadata tag to build multi-step wizards or tabbed form flows:

```dart
// 1. Assign group tag to FormFieldDefinition
FormFieldDefinition<String>(
  name: 'fullName',
  group: 'personal_info',
  validators: [TypedCommonValidators.required<String>()],
  initialValue: '',
)

// 2. Validate step on navigation
context.validateGroup(
  'personal_info',
  onValidationPass: () => advanceToNextStep(),
  onValidationFail: () => showErrorMessage(),
);

// 3. Passive validity check (e.g. for enabling step buttons without marking touched)
final isStepValid = context.isGroupValid('personal_info');
```

## 🔄 **Dynamic Form Management APIs**

```dart
// Update single or multiple values
context.updateFormField<String>('email', 'user@example.com');
controller.updateFields(fieldValues: {'f1': 'v1', 'f2': 'v2'}, context: context);

// Dynamic validators update
controller.updateFieldValidators<String>(
  name: 'password',
  validators: [TypedCommonValidators.required(), TypedCommonValidators.minLength(12)],
  context: context,
);

// Add / remove fields at runtime
controller.addField<String>(field: myNewField, context: context);
controller.removeField('oldField', context: context);

// Manual error overrides (e.g. from backend API error responses)
controller.updateError(fieldName: 'email', errorMessage: 'Email already registered', context: context);
controller.updateErrors(errors: {'email': 'Invalid', 'phone': 'Taken'}, context: context);

// Reset form
controller.resetForm();
```

## 🌍 **Localization**

Built-in support for 5 languages: English, Spanish, French, German, and Arabic.

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

## 🤖 **AI Agent Skill Included**

This package ships with an official **AI Agent Skill** located at `.agents/skills/typed-form-fields/SKILL.md`. AI coding assistants (e.g., OpenCode, Claude Code, Cursor, GitHub Copilot Workspace) can use this skill to generate, refactor, and integrate forms cleanly and accurately according to best practices.

## 🧪 **Testing & Quality**

- **High Test Coverage**: Extensive test suite covering unit, widget, and integration scenarios
- **Zero Linting Warnings**: Clean pass on `flutter analyze`
- **100% Core Architecture Coverage**: `TypedFormController`, `FormValidator`, `FormValidationOrchestrator`, and `FormFieldRegistry` fully tested

## 📄 **License**

This package is licensed under the [MIT License](LICENSE).

## 👨‍💻 Author

**Murhaf Moussa** - Software Engineer
- 🌐 **GitHub**: [@MurhafMoussa](https://github.com/MurhafMoussa)
- 💼 **LinkedIn**: [murhaf-n-moussa](https://www.linkedin.com/in/murhaf-n-moussa/)
- 📺 **YouTube**: [@QualityAddict](https://www.youtube.com/@QualityAddict)
