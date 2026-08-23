# Changelog

## 2.0.0 - Decoupled Built-in Widgets for Zero UI-Coupling

### 🚀 **Breaking Changes**

- **Removed Pre-built Material Widgets**: Deleted design-system coupled widgets (`TypedTextField`, `TypedCheckbox`, `TypedSwitch`, `TypedDropdown`, `TypedSlider`, `TypedDatePicker`, `TypedTimePicker`) from core package exports.
- **Migration**: Use `TypedFieldWrapper<T>` with any Flutter widget or design system (Material, Cupertino, Shadcn, Fluent, or custom controls).

### 🛠 **Architectural Improvements**

- **100% UI-Agnostic Core**: The package core is now completely decoupled from Material/Cupertino design systems, aligning with Flutter's modular framework direction.
- **Zero UI-Coupling**: `TypedFieldWrapper<T>` provides high-performance, type-safe form field validation and state management for any widget tree without bloated parameter forwarding.
- **Updated Showcase & Documentation**: Refactored example app screens and README documentation to showcase `TypedFieldWrapper<T>` usage across various form field controls.

## 1.3.3 - Dynamic Validator Localization & Comprehensive Test Suite

### 🌍 **Localization & Validator Enhancements**

- **Dynamic Localized Resolution**: Refactored `min`, `max`, `url`, `creditCard`, `dateString`, `ipAddress`, `uuid`, `json`, and `alphanumeric` validators to evaluate `ValidatorLocalizations.of(context)` dynamically at runtime (`validate(value, context)`), supporting instant app locale changes without re-instantiating validators.
- **Type Compatibility Fix**: Updated `isValueCompatibleWithExpectedType` in `FormValidator` to correctly support `dynamic` and custom object runtime types.

### 🧪 **Testing & Quality**

- **Expanded Test Suite**: Added 30+ new unit and edge case tests covering `ValidationStrategy` helpers, `TypedFormController` edge cases (`realTimeOnly` error clearing, `updateFields`, `updateErrors`), `FormFieldDefinition.copyWith()`, and private helper constructors.
- **99.62% Line Coverage**: Achieved near 100% line coverage on all core library files (excluding localizations delegate).

## 1.3.2 - Localization Fix & Improvements

### 🌍 **Localization Fixes**

- **Fixed Localization Not Working**: Validators now properly use context at validation time instead of storing messages at creation time
- **Dynamic Language Switching**: Validation messages now update immediately when language changes
- **Arabic Localization**: Fixed and completed Arabic translations for all validation messages
- **Language Switcher**: Added language switcher to example app for easy testing

### 🔧 **Technical Improvements**

- **Validator Architecture**: Updated validators to use `ValidatorLocalizations.of(context)` at validation time
- **Fallback Support**: Added proper fallback to English when localizations are not found
- **Context-Aware Validation**: All validators now dynamically get localized messages based on current app locale

### 📚 **Documentation**

- **Updated README**: Added localization setup instructions
- **Example App**: Enhanced example app with language switcher demonstrating localization

### 🐛 **Bug Fixes**

- Fixed validators not respecting locale changes
- Fixed Arabic localization returning English messages
- Fixed `ValidatorLocalizations.of()` returning null in some cases

## 1.3.1 - Visual Assets & Documentation Enhancement

### 🎨 **Visual Assets**

- **Validation Strategy Visuals**: Added comprehensive visual representations for all 5 validation strategies
- **External Asset Links**: Integrated GitHub-hosted visual assets for better pub.dev compatibility
- **Visual Strategy Comparison**: Enhanced README.md with visual comparison table showing all validation strategies
- **Improved Package Appeal**: Visual assets make the package more engaging and easier to understand on pub.dev

### 📚 **Documentation**

- **Enhanced README**: Added visual strategy comparison table with external asset links
- **Better User Experience**: Visual representations help users quickly understand each validation strategy
- **Professional Presentation**: Improved package presentation on pub.dev with visual content

## 1.3.0 - Major Refactoring: Service Architecture & 100% Test Coverage

### 🏗️ **Major Refactoring**

- **Service Architecture Redesign**: Completely refactored the internal service architecture for better maintainability and testability
  - Split monolithic services into focused, single-responsibility services
  - New services: `FieldRegistry`, `StateCalculation`, `SubmissionHandling`, `ValidationCoordination`, `ValidationDebounce`, `ValidationExecution`, `ErrorManagement`, `FieldLifecycle`, `FieldMutations`, `FieldTracking`
  - Improved dependency injection and service composition

### 🧪 **Testing & Quality**

- **100% Test Coverage**: Achieved 100% test coverage for all core files
  - `typed_field_wrapper.dart`: 100% coverage
  - `typed_form_controller.dart`: 98.77% coverage (improved from previous versions)
  - `state_calculation.dart`: 100% coverage
  - `validation_execution.dart`: 95.45% coverage (improved from previous versions)
- **564 Tests**: Comprehensive test suite with 564 passing tests
- **Zero Linting Issues**: All code passes `flutter analyze` with no warnings or errors

### 🔧 **Improvements**

- **Better Code Organization**: Services are now properly separated by responsibility
- **Enhanced Maintainability**: Easier to understand, modify, and extend individual components
- **Improved Performance**: Optimized service interactions and reduced unnecessary computations
- **Better Error Handling**: More robust error management across all services

### 🐛 **Bug Fixes**

- **Validation Strategy Fix**: Fixed `ValidationStrategy.disabled` to properly return `shouldValidate: false`
- **Cross-Field Validation**: Improved cross-field validator support and testing
- **Service Dependencies**: Fixed service dependency injection and parameter naming consistency

### 📚 **Documentation**

- **Updated Examples**: All examples updated to reflect the new architecture
- **Comprehensive Tests**: Added extensive test coverage for edge cases and error scenarios
- **API Documentation**: Improved inline documentation for all new services

## 1.2.0 - ValidationStrategy API Redesign: Improved Validation Control

### 🚀 **Breaking Changes**

- **ValidationStrategy API**: Replaced `ValidationType` enum with `ValidationStrategy` for clearer, more descriptive validation behavior control

  - **Before**: `ValidationType.onSubmit`, `ValidationType.fieldsBeingEdited`, `ValidationType.allFields`, `ValidationType.disabled`
  - **After**: `ValidationStrategy.onSubmitOnly`, `ValidationStrategy.onSubmitThenRealTime`, `ValidationStrategy.realTimeOnly`, `ValidationStrategy.allFieldsRealTime`, `ValidationStrategy.disabled`
  - **Migration**: Replace `validationType` parameter with `validationStrategy` in `TypedFormController` and `TypedFormProvider`

- **Method Name Changes**:
  - `setValidationType()` → `setValidationStrategy()`
  - `state.validationType` → `state.validationStrategy`

### ✨ **New Features**

- **ValidationStrategy.onSubmitOnly**: Validation only occurs on form submission, with NO automatic switching to real-time validation after failed submit
- **ValidationStrategy.onSubmitThenRealTime**: Validation occurs on submit, then automatically switches to real-time validation if validation fails (previous default behavior)
- **Enhanced Validation Control**: More granular control over when and how validation occurs
- **Improved API Clarity**: Validation strategy names clearly describe their behavior

### 🔧 **Improvements**

- **Better User Experience**: `onSubmitOnly` provides consistent submit-only behavior without unexpected validation mode changes
- **Flexible Validation Strategies**: 5 distinct validation strategies to choose from based on your specific needs
- **Comprehensive Testing**: 100% test coverage for all validation strategies with TDD approach
- **Clear Documentation**: Updated README with detailed examples for each validation strategy

### 🐛 **Bug Fixes**

- Fixed `ValidationStrategy.disabled` to always return `true` for form validity
- Fixed `onSubmitOnly` behavior to maintain consistent submit-only validation
- Fixed cross-field validation test mock to properly track call counts

### 📚 **Documentation**

- Updated README.md with comprehensive ValidationStrategy documentation
- Added clear examples for each validation strategy
- Documented automatic validation strategy switching behavior
- Updated all code examples to use new API

### 🧪 **Testing**

- Added comprehensive test suite for ValidationStrategy with TDD approach
- Updated all existing tests to use new ValidationStrategy API
- Ensured 538 tests pass with new validation behavior
- Added edge case testing for all validation strategies

## 1.1.0 - Major Architecture Refactor: Typed Prefix Migration

### 🚀 **Breaking Changes**

- **Zero Dependencies Architecture**: Moved from `flutter_bloc` dependency to zero external dependencies

  - **Before**: Required `BlocProvider` and `CoreFormCubit` from `flutter_bloc`
  - **After**: Uses `TypedFormProvider` with built-in state management (no external dependencies)
  - **Migration**: Replace `BlocProvider(create: (context) => CoreFormCubit(...))` with `TypedFormProvider(...)`

- **Renamed core classes** to use "Typed" prefix for better clarity and consistency:
  - `FieldWrapper` → `TypedFieldWrapper`
  - `CoreFormCubit` → `TypedFormController`
  - `CoreFormState` → `TypedFormState`
  - `CommonValidators` → `TypedCommonValidators`
  - `CrossFieldValidators` → `TypedCrossFieldValidators`
  - `ConditionalValidator` → `TypedConditionalValidator`
  - `CompositeValidator` → `TypedCompositeValidator`
  - `ValidatorLocalizations` → `TypedValidatorLocalizations`

### ✨ **New Features**

- **Enhanced Form State Management**: Improved `TypedFormController` with better state handling and validation logic
- **Advanced Cross-Field Validation**: New static helper methods in `TypedCrossFieldValidators`:
  - `matches()` - Field value matching validation
  - `differentFrom()` - Field value difference validation
  - `requiredWhen()` - Conditional required field validation
  - `requiredWhenNotEmpty()` - Required when another field is not empty
  - `dateBefore()` / `dateAfter()` - Date comparison validations
  - `greaterThan()` / `lessThan()` - Numeric comparison validations
  - `sumCondition()` - Sum-based validation
  - `atLeastOneRequired()` - At least one field required validation
- **Improved Form Reset**: `resetForm()` now resets to initial values instead of null
- **Enhanced Form Listener**: `TypedFormListener` converted to StatefulWidget for better lifecycle management

### 🔧 **Improvements**

- **Better Test Coverage**: Achieved 100% test coverage for core validation components
- **Performance Optimizations**: Enhanced form state management and validation performance
- **Integration Testing**: Added comprehensive integration tests for end-to-end form functionality
- **Performance Benchmarking**: Added benchmark tests for form operations
- **Code Quality**: Removed test-specific code from production files
- **Documentation**: Updated README.md with correct class names and examples

### 🐛 **Bug Fixes**

- Fixed form state initialization issues in `TypedFormProvider`
- Fixed cross-field validation triggering in tests
- Fixed form reset behavior to use initial values
- Fixed integration test compilation and runtime errors
- Fixed benchmark test compilation issues
- Fixed logical inconsistencies in test expectations

### 📚 **Documentation**

- Updated all examples to use new "Typed" prefixed class names
- Enhanced README.md with corrected API references
- Improved code examples and usage patterns
- Updated package exports to include all Typed classes

### 🧪 **Testing**

- Added comprehensive integration tests for dynamic form scenarios
- Added performance benchmark tests
- Improved test coverage for cross-field validators
- Enhanced test coverage for common validators
- Added fallback error message testing
- Fixed all test compilation and runtime issues

## 1.0.0 - Initial Release

- 🎉 First public release of `typed_form_fields`!
- Type-safe, universal form field wrapper (`FieldWrapper<T>`) for any widget
- **Required `flutter_bloc` dependency** for state management
- Core form management: `CoreFormCubit`, `CoreFormState` (BLoC-based)
- Validation system: `CommonValidators`, `CrossFieldValidators`, `ConditionalValidator`, `CompositeValidator`
- Form field definition: `TypedFormField<T>` (already "Typed" prefixed)
- 7 pre-built widgets: TypedTextField, TypedCheckbox, TypedSwitch, TypedDropdown, TypedSlider, TypedDatePicker, TypedTimePicker
- Complete validation system: required, email, min/max, pattern, phone, credit card, URL, custom, and more
- Cross-field validation (e.g., password confirmation, field matching)
- Conditional validation (validate only when certain conditions are met)
- Composite and chainable validators
- BLoC integration for reactive state management
- Debouncing and performance optimizations
- Built-in localization for 11 languages
- Dynamic form updates: add/remove fields, update validation rules, update errors at runtime
- Full error handling and type safety
- Comprehensive documentation and examples
