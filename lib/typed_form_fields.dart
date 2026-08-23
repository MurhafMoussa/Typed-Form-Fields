/// A type-safe, universal form field wrapper with zero dependencies and high performance.
///
/// This library provides generic `TypedFieldWrapper<T>` for any data type with built-in
/// validation, debouncing, and performance optimizations. Uses TypedFormProvider for
/// clean, dependency-free form state management with BLoC internally for maximum performance.
library;

// Core exports
export 'src/core/form_errors.dart';
export 'src/core/form_validator.dart';
export 'src/core/typed_form_controller.dart';
export 'src/core/validation_strategy.dart';
// Models exports
export 'src/models/form_field_definition.dart';
export 'src/models/typed_field_state.dart';
// Validators exports
export 'src/validators/composite_validator.dart';
export 'src/validators/validator_localizations.dart';
export 'src/validators/validator_localizations_delegate.dart';
export 'src/validators/validators.dart';
// Widgets exports
export 'src/widgets/typed_field_wrapper.dart';
export 'src/widgets/typed_form_provider.dart';
