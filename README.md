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
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  errorText: hasError ? error : null,
                ),
              );
            },
          ),

          SizedBox(height: 16),

          // Checkbox field using TypedFieldWrapper
          TypedFieldWrapper<bool>(
            fieldName: 'subscribe',
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return CheckboxListTile(
                title: Text('Subscribe to newsletter'),
                value: value ?? false,
                onChanged: (val) => updateValue(val ?? false),
              );
            },
          ),

          SizedBox(height: 24),

          // Submit button with reactive validation
          TypedFormBuilder(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isValid ? () {
                  // Type-safe access to form values
                  final email = state.getValue<String>('email');
                  final subscribe = state.getValue<bool>('subscribe');
                  print('Email: $email, Subscribe: $subscribe');
                } : null,
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

## 📥 **Accessing Field Values from Form State**

You can get the value of any field in your form using the `getValue<T>(fieldName)` method on the form state. This is type-safe and works for any field type.

```dart
// Inside a BlocBuilder or after form submission:
final email = state.getValue<String>('email');
final subscribe = state.getValue<bool>('subscribe');
final age = state.getValue<int>('age');

if (state.isValid) {
  print('Email: $email, Subscribed: $subscribe, Age: $age');
}
```

- Returns `null` if the field is not set or the type does not match.
- Use this for form submission, validation, or any business logic that needs the current form values.

## 🚀 **Key Features**

- **Type-safe, universal form field wrapper**
- **Zero dependencies** - no flutter_bloc required for users
- **UI-Agnostic** - works with Material, Cupertino, Shadcn, Fluent, or custom design systems
- **TypedFormProvider** for clean, simple API
- **High performance** - uses BLoC internally with buildWhen/listenWhen optimizations
- **5 validation strategies** (onSubmitOnly, onSubmitThenRealTime, realTimeOnly, allFieldsRealTime, disabled)
- **Field grouping & multi-step validation** (validateGroup, isGroupValid, touchGroup)
- **Debouncing, performance optimizations**
- **Cross-field, conditional, and composite validation**
- **Localization** in 5 languages

## ⚡ **Performance Optimizations**

The package uses **BLoC internally** for maximum performance while maintaining a **zero-dependency API** for users:

### **Field-Specific Rebuilds**

- **`buildWhen`** - Only rebuilds when the specific field's value or error changes
- **`listenWhen`** - Only triggers listeners for relevant field changes
- **Prevents unnecessary rebuilds** - Other fields changing won't affect unrelated widgets

### **Optimized State Management**

- **BlocConsumer** for TypedFieldWrapper with field-specific conditions
- **BlocBuilder** for FormBuilder with direct state access
- **BlocListener** for FormListener with automatic lifecycle management
- **BlocProvider** for FormProvider with battle-tested performance

### **Memory Efficiency**

- **No manual stream subscriptions** - BLoC handles lifecycle automatically
- **Optimized rebuilds** - Uses Flutter BLoC's proven optimization patterns
- **Debouncing support** - Configurable delays to reduce update frequency

## 🎨 **Universal Integration via `TypedFieldWrapper<T>`**

`TypedFieldWrapper<T>` connects **any UI widget or design system** to the form engine with zero coupling to Material or Cupertino:

### 📝 **Text Input Example**

```dart
TypedFieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  builder: (context, value, error, hasError, isValidating, updateValue) {
    return TextFormField(
      initialValue: value,
      onChanged: updateValue,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        errorText: hasError ? error : null,
      ),
    );
  },
)
```

### ✅ **Selection / Toggle Example**

```dart
TypedFieldWrapper<bool>(
  fieldName: 'terms',
  builder: (context, value, error, hasError, isValidating, updateValue) {
    return CheckboxListTile(
      title: Text('I agree to terms'),
      value: value ?? false,
      onChanged: (val) => updateValue(val ?? false),
      subtitle: hasError ? Text(error!, style: TextStyle(color: Colors.red)) : null,
    );
  },
)
```

### 🔽 **Dropdown Example**

```dart
TypedFieldWrapper<String>(
  fieldName: 'country',
  builder: (context, value, error, hasError, isValidating, updateValue) {
    return DropdownButtonFormField<String>(
      value: (value == null || value.isEmpty) ? null : value,
      onChanged: updateValue,
      decoration: InputDecoration(
        labelText: 'Select Country',
        errorText: hasError ? error : null,
      ),
      items: ['USA', 'Canada', 'UK']
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
    );
  },
)
```
- **Validation** - Built-in error display and validation
- **Customization** - All original widget parameters supported
- **Controllers** - Optional `TextEditingController` support with proper disposal
- **Debouncing** - Configurable update delays
- **Value Transformation** - Transform values before storing
- **Localization** - Error messages in 5 languages

## ✅ **TypedFieldWrapper<T> - High-Performance Universal Form Integration**

The `TypedFieldWrapper<T>` is the **core widget** that transforms any Flutter widget into a reactive, validated form field with **optimized performance**:

```dart
TypedFieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  onFieldStateChanged: (value, error, hasError) {
    // React to changes without rebuilding
    print('Field changed: $value, hasError: $hasError');
  },
  builder: (context, value, error, hasError, isValidating, updateValue) {
    // Use ANY Flutter widget here!
    return TextFormField(
      initialValue: value,
      onChanged: updateValue,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: hasError ? error : null,
      ),
    );
  },
)
```

**Performance Features**:

- 🚀 **BlocConsumer** with `buildWhen`/`listenWhen` for minimal rebuilds
- 🎯 **Field-specific updates** - only rebuilds when the specific field's value or error changes
- 📡 **Listener support** - react to changes without triggering rebuilds
- ⚡ **Debouncing** - optimized for rapid input scenarios
- 🔥 **High Performance** - uses BLoC internally for maximum efficiency

**Works with ANY widget**: TextField, Checkbox, Slider, Dropdown, Radio, Switch, or your custom widgets!

## 🎨 **Custom Validators**

Create powerful custom validators with full type safety:

```dart
// Simple custom validator
final customValidator = TypedCommonValidators.custom<String>(
  (value) => value?.contains('@company.com') == true
      ? null
      : 'Must be a company email',
);

// Advanced custom validator with context
class CompanyEmailValidator extends Validator<String> {
  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    final allowedDomains = ['company.com', 'subsidiary.com'];
    final domain = value.split('@').last;

    return allowedDomains.contains(domain)
        ? null
        : 'Email must be from: ${allowedDomains.join(', ')}';
  }
}
```

## 📋 **Common Validators**

| Validator             | Description              | Example                                                                                           |
| --------------------- | ------------------------ | ------------------------------------------------------------------------------------------------- |
| `required<T>()`       | Field cannot be empty    | `TypedCommonValidators.required<String>()`                                                        |
| `email()`             | Valid email format       | `TypedCommonValidators.email()`                                                                   |
| `minLength(int)`      | Minimum character length | `TypedCommonValidators.minLength(8)`                                                              |
| `maxLength(int)`      | Maximum character length | `TypedCommonValidators.maxLength(50)`                                                             |
| `pattern(RegExp)`     | Matches regex pattern    | `TypedCommonValidators.pattern(RegExp(r'^\d+$'))`                                                 |
| `min(num)`            | Minimum numeric value    | `TypedCommonValidators.min(18)`                                                                   |
| `max(num)`            | Maximum numeric value    | `TypedCommonValidators.max(100)`                                                                  |
| `phoneNumber()`       | Valid phone number       | `TypedCommonValidators.phoneNumber()`                                                             |
| `creditCard()`        | Valid credit card        | `TypedCommonValidators.creditCard()`                                                              |
| `url()`               | Valid URL format         | `TypedCommonValidators.url()`                                                                     |
| `custom<T>(function)` | **Your custom logic**    | `TypedCommonValidators.custom<String>((v) => v?.contains('x') == true ? null : 'Must contain x')` |
| `mustBeTrue()`        | **Boolean must be true** | `TypedCommonValidators.mustBeTrue()` (for checkboxes that must be checked)                        |

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

`TypedConditionalValidator` lets you apply validation rules only when certain conditions are met (e.g., only validate if a checkbox is checked, or if a value is not empty).

```dart
// Only require a field if the user checked a box
final validator = TypedConditionalValidator<String>(
  condition: (value, context) => TypedFormProvider.of(context).getValue<bool>('isChecked') == true,
  validator: TypedCommonValidators.required<String>(),
);

// Use with TypedFieldWrapper or TypedFormField
FormFieldDefinition<String>(
  name: 'details',
  validators: [validator],
  initialValue: '',
)
```

You can also use the built-in helpers in `TypedConditionalValidators`:

```dart
// Only validate if not empty
final validator = TypedConditionalValidators.whenNotEmpty(
  TypedCommonValidators.email(),
);
```

See also: `SwitchValidator`, `ChainValidator`, and more for advanced conditional flows.

## ⚙️ **Validation Strategies**

The package supports **5 different validation strategies** to control when and how validation occurs:

### 🎨 **Visual Strategy Comparison**

| Strategy                 | Visual                                                    | Description                            |
| ------------------------ | --------------------------------------------------------- | -------------------------------------- |
| **onSubmitOnly**         | ![onSubmitOnly](https://github.com/user-attachments/assets/64e3e251-1e5c-471a-9ff5-d876d8211131)                 | Validation only on form submission     |
| **onSubmitThenRealTime** | ![onSubmitThenRealTime](https://github.com/user-attachments/assets/f2c2dcf1-afc7-4723-8892-140f598ad841) | Validation on submit, then real-time   |
| **realTimeOnly**         | ![realTimeOnly](https://github.com/user-attachments/assets/c574636e-1194-4c99-9c8a-0f9a07fa18cb)                 | Real-time validation for edited fields |
| **allFieldsRealTime**    | ![allFieldsRealTime](https://github.com/user-attachments/assets/addca2a5-fc46-40bd-a864-adf3e2e4d8a4)       | Real-time validation for all fields    |
| **disabled**             | ![disabled](https://github.com/user-attachments/assets/72e4fa9c-9e1f-4102-a322-9bdd54e28170)                         | No validation occurs                   |

### **ValidationStrategy.onSubmitOnly**

Validation only occurs when the form is submitted. Perfect for forms where you want to avoid showing errors until the user attempts to submit.

**Important:** When using `ValidationStrategy.onSubmitOnly`, the validation strategy does NOT automatically switch to real-time validation after a failed submit. This provides a consistent "submit-only" experience.

### **ValidationStrategy.onSubmitThenRealTime**

Validation only occurs when the form is submitted initially, but if validation fails during form submission, the validation strategy automatically switches to `ValidationStrategy.realTimeOnly` to provide immediate feedback as the user corrects the errors.

```dart
TypedFormController(
  fields: fields,
  validationStrategy: ValidationStrategy.onSubmitThenRealTime,
)

// Trigger validation on form submission
TypedFormProvider.of(context).validateForm(
  context,
  onValidationPass: () {
    // Form is valid, proceed with submission
    print('Form submitted successfully!');
  },
  onValidationFail: () {
    // Form has errors, show feedback to user
    // Validation strategy automatically changes to realTimeOnly
    print('Please fix the errors before submitting');
  },
);

// Example: Submit button implementation
ElevatedButton(
  onPressed: () {
    TypedFormProvider.of(context).validateForm(
      context,
      onValidationPass: () {
        // Get form values and submit
        final email = TypedFormProvider.of(context).getValue<String>('email');
        final password = TypedFormProvider.of(context).getValue<String>('password');

        // Submit to API or handle form data
        submitUserData(email!, password!);
      },
      onValidationFail: () {
        // Show error message to user
        // Note: Validation strategy automatically switches to realTimeOnly
        // so users will see real-time validation as they fix errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors before submitting')),
        );
      },
    );
  },
  child: const Text('Submit'),
)
```

### **ValidationStrategy.realTimeOnly** (Default)

Only validates fields that are currently being edited. This provides a balanced approach between user experience and performance.

```dart
TypedFormController(
  fields: fields,
  validationStrategy: ValidationStrategy.realTimeOnly,
)
```

### **ValidationStrategy.allFieldsRealTime**

Validates all fields whenever any field is updated. Provides immediate feedback but may impact performance with large forms.

```dart
TypedFormController(
  fields: fields,
  validationStrategy: ValidationStrategy.allFieldsRealTime,
)
```

### **ValidationStrategy.disabled**

Disables automatic validation. When disabled, the form is always considered valid. Useful when you want to handle validation manually or in specific scenarios.

```dart
TypedFormController(
  fields: fields,
  validationStrategy: ValidationStrategy.disabled,
)
```

### **Dynamic Validation Strategy Changes**

You can change the validation strategy at runtime:

```dart
// Change validation behavior dynamically
TypedFormProvider.of(context).setValidationStrategy(ValidationStrategy.onSubmitOnly);

// Available validation strategies:
// - ValidationStrategy.allFieldsRealTime: Validate all fields on every change
// - ValidationStrategy.realTimeOnly: Only validate fields being edited
// - ValidationStrategy.onSubmitOnly: Only validate on form submission (no auto-switch)
// - ValidationStrategy.onSubmitThenRealTime: Validate on submit, then switch to real-time
// - ValidationStrategy.disabled: Disable automatic validation (always valid)
```

**Automatic Validation Strategy Switching:**
When using `ValidationStrategy.onSubmitThenRealTime`, the form automatically switches to `ValidationStrategy.realTimeOnly` if validation fails during submission. This provides a better user experience by showing real-time validation feedback as users correct their errors.

**No Auto-Switch for onSubmitOnly:**
When using `ValidationStrategy.onSubmitOnly`, the form maintains the submit-only behavior even after validation failures, providing a consistent experience.

## 🧱 **Field Grouping & Multi-Step Forms**

Tag form fields with an optional `group` metadata tag to validate and control multi-step forms, wizards, or tabbed form views with a single method call:

### **1. Tag Fields with a Group Name**

```dart
TypedFormProvider(
  fields: [
    // Step 1: Personal Info
    FormFieldDefinition<String>(
      name: 'fullName',
      group: 'personal_info',
      validators: [TypedCommonValidators.required<String>()],
      initialValue: '',
    ),
    FormFieldDefinition<String>(
      name: 'email',
      group: 'personal_info',
      validators: [TypedCommonValidators.required<String>(), TypedCommonValidators.email()],
      initialValue: '',
    ),
    // Step 2: Address Info
    FormFieldDefinition<String>(
      name: 'street',
      group: 'address_info',
      validators: [TypedCommonValidators.required<String>()],
      initialValue: '',
    ),
  ],
  child: (context) => MultiStepWizardView(),
);
```

### **2. Validate Step / Group on Navigation**

Use `context.validateGroup('group_name')` to validate all fields matching the group tag and mark them as touched. Triggers `onValidationPass` or `onValidationFail` callbacks automatically:

```dart
ElevatedButton(
  onPressed: () {
    context.validateGroup(
      'personal_info',
      onValidationPass: () {
        // Step 1 is valid, advance to Step 2
        setState(() => currentStep = 1);
      },
      onValidationFail: () {
        // Show step error notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix errors before proceeding.')),
        );
      },
    );
  },
  child: const Text('Next Step'),
);
```

### **3. Passive Group & Subset Validity Checks**

Passively check if a step or subset of fields is valid without triggering debouncing, without altering `touched` state, and without showing error messages prematurely (ideal for enabling/disabling "Next" buttons):

```dart
TypedFormBuilder(
  builder: (context, state) {
    // Passive check returns bool
    final isStep1Valid = context.isGroupValid('personal_info');
    final areFieldsValid = context.areFieldsValid(['fullName', 'email']);

    return ElevatedButton(
      onPressed: isStep1Valid ? () => advanceToNextStep() : null,
      child: const Text('Next Step'),
    );
  },
);
```

### **4. Group & Subset Control APIs**

- **`context.validateGroup('group_name')`** - Validates group fields, marks touched = true, and triggers pass/fail callbacks.
- **`context.validateFields(['field1', 'field2'])`** - Validates explicit list of field names.
- **`context.isGroupValid('group_name')`** - Passively returns `true` if all group fields pass validation.
- **`context.areFieldsValid(['field1', 'field2'])`** - Passively returns `true` if all specified fields pass validation.
- **`context.touchGroup('group_name')`** - Marks all fields matching the group as touched without callbacks.

## 🔄 **Dynamic Form Updates**

The `TypedFormController` provides comprehensive APIs for **real-time form updates**:

### ✅ **Update Error Messages**

```dart
// Set custom error for a specific field (e.g., from API response)
TypedFormProvider.of(context).updateError(
  fieldName: 'email',
  errorMessage: 'Email already exists',
  context: context,
);

// Clear error for a specific field
TypedFormProvider.of(context).updateError(
  fieldName: 'email',
  errorMessage: null, // null clears the error
  context: context,
);

// Update multiple errors at once
TypedFormProvider.of(context).updateErrors(
  errors: {
    'email': 'Email already exists',
    'username': 'Username is taken',
    'phone': null, // Clear phone error
  },
  context: context,
);
```

### ✅ **Update Validation Rules**

```dart
// Update validators for a field dynamically
TypedFormProvider.of(context).updateFieldValidators<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required<String>(),
    TypedCommonValidators.minLength(12), // Increased security requirement
    TypedCommonValidators.pattern(RegExp(r'^(?=.*[A-Z])(?=.*[!@#$%^&*])')),
  ],
  context: context,
);
```

### ✅ **Update Field Values**

```dart
// Update single field value
TypedFormProvider.of(context).updateField<String>(
  fieldName: 'country',
  value: 'USA',
  context: context,
);

// Update multiple fields at once
TypedFormProvider.of(context).updateFields<String>(
  fieldValues: {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'john.doe@example.com',
  },
  context: context,
);
```

### ✅ **Update Validation Type**

```dart
// Change validation behavior for the entire form
TypedFormProvider.of(context).setvalidationStrategy(validationStrategy.onSubmit);

// See the "Validation Types" section above for detailed explanations
// of all available validation strategies
```

### ✅ **Dynamic Field Management**

```dart
// Add new fields dynamically
TypedFormProvider.of(context).addField<String>(
  field: FormFieldDefinition<String>(
    name: 'newField',
    validators: [TypedCommonValidators.required<String>()],
    initialValue: '',
  ),
  context: context,
);

// Add multiple fields at once
TypedFormProvider.of(context).addFields(
  fields: [
    FormFieldDefinition<String>(name: 'field1', validators: [], initialValue: ''),
    FormFieldDefinition<bool>(name: 'field2', validators: [], initialValue: false),
  ],
  context: context,
);

// Remove fields dynamically
TypedFormProvider.of(context).removeField('fieldName', context: context);
TypedFormProvider.of(context).removeFields(['field1', 'field2'], context: context);
```

### ✅ **Form Control Methods**

```dart
// Validate entire form (useful for submit buttons)
TypedFormProvider.of(context).validateForm(
  context,
  onValidationPass: () => print('Form is valid!'),
  onValidationFail: () => print('Form has errors'),
);

// Validate a specific field group (step validation)
TypedFormProvider.of(context).validateGroup(
  'step1',
  context: context,
  onValidationPass: () => print('Step 1 valid!'),
  onValidationFail: () => print('Step 1 invalid'),
);

// Validate specific subset of fields
TypedFormProvider.of(context).validateFields(
  ['firstName', 'lastName'],
  context: context,
);

// Passive validity checks (returns bool without altering touched state)
final step1Valid = TypedFormProvider.of(context).isGroupValid('step1', context: context);
final subsetValid = TypedFormProvider.of(context).areFieldsValid(['firstName', 'lastName'], context: context);

// Validate specific field immediately (no debouncing)
TypedFormProvider.of(context).validateFieldImmediately(
  fieldName: 'email',
  context: context,
);

// Mark all fields as touched and validate them
TypedFormProvider.of(context).touchAllFields(context);

// Touch fields in a group
TypedFormProvider.of(context).touchGroup('step1', context: context);

// Reset form to initial state
TypedFormProvider.of(context).resetForm();
```

**Use Cases:**

- 🌐 **API Integration** - Handle server-side validation errors
- 🔐 **Conditional Validation** - Change rules based on user selections
- 📱 **Progressive Forms** - Add/remove fields as user progresses
- 🎯 **Dynamic Requirements** - Adjust validation based on business logic
- 🔄 **Multi-step Forms** - Update validation per step

## 🌍 **Localization**

Built-in support for 5 languages: English, Spanish, French, German, and Arabic.

### **Setup**

To enable localization for validation error messages, add `ValidatorLocalizationsDelegate` to your `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

MaterialApp(
  localizationsDelegates: [
    ValidatorLocalizationsDelegate.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('ar'), // Arabic
  ],
  // ... rest of your app configuration
)
```

### **Usage**

Once configured, validation messages will automatically use the current locale:

```dart
// Automatic localization based on app locale
TypedCommonValidators.required<String>().validate(null, context)
// Returns "Este campo es obligatorio." in Spanish
// Returns "هذا الحقل مطلوب." in Arabic
```

## 🏗 **Architecture**

### Current Features (Production Ready)

- ✅ **TypedFieldWrapper<T>** - Universal, UI-agnostic widget integration
- ✅ **Type-safe validation** - Compile-time type checking
- ✅ **Custom validators** - Easy to create and reuse
- ✅ **BLoC integration** - Reactive state management
- ✅ **Cross-field validation** - Field interdependencies
- ✅ **Conditional validation** - Dynamic validation rules
- ✅ **Localization** - 5 languages supported (English, Spanish, French, German, Arabic)
- ✅ **Performance** - Debouncing, caching, efficient updates

## 🧪 **Testing & Quality**

### **Comprehensive Test Coverage**

- **564 Tests**: Extensive test suite covering all functionality
- **100% Coverage**: Core files achieve 100% test coverage

- **Zero Linting Issues**: All code passes `flutter analyze` with no warnings
- **Service Architecture**: Fully tested service layer with dependency injection
- **Edge Cases**: Comprehensive testing of error scenarios and edge cases

### **Quality Assurance**

- **Production Ready**: Battle-tested in production environments
- **Type Safety**: Full compile-time type checking
- **Performance Optimized**: Efficient state management and minimal rebuilds
- **Maintainable Code**: Clean architecture with single-responsibility services

## 🎯 **Why TypedFieldWrapper?**

**Before TypedFieldWrapper:**

```dart
// Lots of boilerplate, manual state management
TextFormField(
  controller: _controller,
  onChanged: (value) => _cubit.updateField('email', value, context),
  validator: (value) => _validator.validate(value, context),
  decoration: InputDecoration(
    errorText: _cubit.state.getError('email'),
  ),
)
```

**With TypedFieldWrapper:**

```dart
// Clean, declarative, works with ANY widget
TypedFieldWrapper<String>(
  fieldName: 'email',
  debounceTime: Duration(milliseconds: 300),
  transformValue: (value) => value.toLowerCase().trim(),
  builder: (context, value, error, hasError, isValidating, updateValue) {
    return TextFormField(
      initialValue: value,
      onChanged: updateValue,
      decoration: InputDecoration(
        errorText: hasError ? error : null,
      ),
    );
  },
)
```

**Benefits:**

- 🎯 **Universal** - Works with any Flutter widget
- 🔒 **Type-safe** - Compile-time type checking
- ⚡ **High Performance** - Uses BlocConsumer with buildWhen/listenWhen for field-specific rebuilds
- 🧩 **Composable** - Easy to combine and reuse
- 🎨 **Flexible** - Full control over UI while handling validation
- 🔄 **Reactive** - Automatic UI updates on state changes
- 🚀 **Optimized** - Only rebuilds when the specific field's value or error changes

## 📄 **License**

This package is licensed under the [MIT License](LICENSE):

```
MIT License

Copyright (c) 2025 Murhaf Moussa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> **Note:** This package may depend on other open-source packages, each with their own licenses. See their respective repositories for details.

## 👨‍💻 Author

**Murhaf Moussa** - Software Engineer

- 🌐 **GitHub**: [@MurhafMoussa](https://github.com/MurhafMoussa)
- 💼 **LinkedIn**: [murhaf-n-moussa](https://www.linkedin.com/in/murhaf-n-moussa/)
- 📺 **YouTube**: [@QualityAddict](https://www.youtube.com/@QualityAddict)
- 📱 **Experience**: 3+ years building and launching mobile applications
- 🏆 **Achievements**: 7+ mobile applications published on Google Play Store

## 🤝 Contributing

We welcome contributions of all kinds! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on bug reports, feature requests, code contributions, and our branching strategy.

---

**Ready to build better forms?** Start with `TypedFieldWrapper<T>` and create your custom validators! 🚀
