import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'form_errors.dart';
import 'validation_strategy.dart';

@immutable
class TypedFormState {
  const TypedFormState({
    required this.values,
    required this.errors,
    required this.isValid,
    this.validationStrategy = ValidationStrategy.realTimeOnly,
    required this.fieldTypes,
    this.validatingFields = const {},
  });

  factory TypedFormState.initial() => const TypedFormState(
        values: {},
        errors: {},
        isValid: false,
        fieldTypes: {},
        validatingFields: {},
      );

  final Map<String, Object?> values;
  final Map<String, String> errors;
  final bool isValid;
  final ValidationStrategy validationStrategy;
  final Map<String, Type> fieldTypes;
  final Set<String> validatingFields;

  /// Whether any field in the form is currently undergoing validation
  bool get isValidating => validatingFields.isNotEmpty;

  /// Type-safe getter for field values
  @useResult
  T? getValue<T>(String fieldName) {
    // Check if field exists
    if (!values.containsKey(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: values.keys.toList(),
        fieldTypes: fieldTypes,
        currentValues: values,
      );
    }

    // Check type compatibility
    final expectedType = fieldTypes[fieldName];
    if (expectedType != null && expectedType != T) {
      throw FormFieldError.typeMismatch(
        fieldName: fieldName,
        expectedType: expectedType,
        actualType: T,
        operation: 'getValue',
      );
    }

    // Return value with proper type
    final value = values[fieldName];
    if (value == null) return null;
    if (value is T) return value as T;

    // Fallback for type mismatch
    return null;
  }

  /// Get error for a specific field
  @useResult
  String? getError(String fieldName) => errors[fieldName];

  /// Check if a field has an error
  @useResult
  bool hasError(String fieldName) => errors.containsKey(fieldName);

  TypedFormState copyWith({
    Map<String, Object?>? values,
    Map<String, String>? errors,
    bool? isValid,
    ValidationStrategy? validationStrategy,
    Map<String, Type>? fieldTypes,
    Set<String>? validatingFields,
  }) {
    return TypedFormState(
      values: values ?? this.values,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      validationStrategy: validationStrategy ?? this.validationStrategy,
      fieldTypes: fieldTypes ?? this.fieldTypes,
      validatingFields: validatingFields ?? this.validatingFields,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TypedFormState) return false;
    return isValid == other.isValid &&
        validationStrategy == other.validationStrategy &&
        const MapEquality<String, Object?>().equals(values, other.values) &&
        const MapEquality<String, String>().equals(errors, other.errors) &&
        const MapEquality<String, Type>().equals(fieldTypes, other.fieldTypes) &&
        const SetEquality<String>().equals(validatingFields, other.validatingFields);
  }

  @override
  int get hashCode {
    return Object.hash(
      isValid,
      validationStrategy,
      const MapEquality<String, Object?>().hash(values),
      const MapEquality<String, String>().hash(errors),
      const MapEquality<String, Type>().hash(fieldTypes),
      const SetEquality<String>().hash(validatingFields),
    );
  }

  @override
  String toString() {
    return 'TypedFormState(values: $values, errors: $errors, isValid: $isValid, validationStrategy: $validationStrategy, fieldTypes: $fieldTypes, validatingFields: $validatingFields)';
  }
}
