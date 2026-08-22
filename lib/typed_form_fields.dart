/// A type-safe, universal form field wrapper with zero dependencies and high performance.
///
/// This library provides generic TypedFieldWrapper&lt;T&gt; for any data type with built-in
/// validation, debouncing, and performance optimizations. Uses TypedFormProvider for
/// clean, dependency-free form state management with BLoC internally for maximum performance.
library;

export 'src/core/form_errors.dart';
// Core exports
export 'src/core/typed_form_controller.dart';
export 'src/core/validation_strategy.dart';
// Models exports
export 'src/models/form_field_definition.dart';
export 'src/services/field_registry.dart';
// Services exports
export 'src/services/field_tracking.dart';
export 'src/services/state_calculation.dart';
export 'src/services/submission_handling.dart';
export 'src/services/validation_coordination.dart';
export 'src/services/validation_debounce.dart';
export 'src/validators/composite_validator.dart';
export 'src/validators/validator_localizations.dart';
export 'src/validators/validator_localizations_delegate.dart';
// Validators exports
export 'src/validators/validators.dart';
export 'src/widgets/typed_checkbox.dart';
export 'src/widgets/typed_date_picker.dart';
export 'src/widgets/typed_dropdown.dart';
// Widgets exports
export 'src/widgets/typed_field_wrapper.dart';
export 'src/widgets/typed_form_provider.dart';
export 'src/widgets/typed_slider.dart';
export 'src/widgets/typed_switch.dart';
// Pre-built widgets
export 'src/widgets/typed_text_field.dart';
export 'src/widgets/typed_time_picker.dart';
