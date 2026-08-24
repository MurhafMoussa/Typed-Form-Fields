import 'package:meta/meta.dart';

/// Represents the field-scoped state and update callback passed to [TypedFieldWrapper]'s builder.
@immutable
class TypedFieldState<T> {
  /// Creates a [TypedFieldState] instance.
  const TypedFieldState({
    required this.fieldName,
    required this.value,
    required this.error,
    required this.hasError,
    required this.isValidating,
    required this.updateValue,
  });

  /// Unique identifier for the field within the form.
  final String fieldName;

  /// Current field value.
  final T? value;

  /// Current error message, if any.
  final String? error;

  /// Whether the field currently has a non-empty error message.
  final bool hasError;

  /// Whether the field is currently undergoing asynchronous validation.
  final bool isValidating;

  /// Callback function to update the field's value in the form controller.
  final void Function(T? value) updateValue;

  /// Convenience getter for error text in InputDecoration.
  ///
  /// Returns [error] if [hasError] is true, else `null`.
  String? get displayError => hasError ? error : null;

  /// Creates a copy of this [TypedFieldState] with the given fields replaced.
  TypedFieldState<T> copyWith({
    String? fieldName,
    T? value,
    String? error,
    bool? hasError,
    bool? isValidating,
    void Function(T? value)? updateValue,
  }) {
    return TypedFieldState<T>(
      fieldName: fieldName ?? this.fieldName,
      value: value ?? this.value,
      error: error ?? this.error,
      hasError: hasError ?? this.hasError,
      isValidating: isValidating ?? this.isValidating,
      updateValue: updateValue ?? this.updateValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypedFieldState<T>) return false;
    return fieldName == other.fieldName &&
        value == other.value &&
        error == other.error &&
        hasError == other.hasError &&
        isValidating == other.isValidating;
  }

  @override
  int get hashCode =>
      Object.hash(fieldName, value, error, hasError, isValidating);

  @override
  String toString() {
    return 'TypedFieldState<$T>(fieldName: $fieldName, value: $value, error: $error, hasError: $hasError, isValidating: $isValidating)';
  }
}
