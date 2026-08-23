import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/validators/typed_cross_field_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';
import 'package:typed_form_fields/src/validators/validator_localizations.dart';

/// FormValidator handles validation routines, strategy rules, and debouncing timer lifecycle.
class FormValidator {
  FormValidator({
    Duration debounceDelay = const Duration(milliseconds: 300),
  }) : _debounceDelay = debounceDelay;

  final Duration _debounceDelay;
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, Timer> _asyncDebounceTimers = {};
  final Map<String, int> _asyncRequestTokens = {};
  final Set<String> _activeValidatingFields = {};

  /// Set of field names currently undergoing async validation.
  Set<String> get activeValidatingFields => Set.unmodifiable(_activeValidatingFields);

  /// Helper check for type matching generics
  bool _isA<T>(dynamic value) => value is T;

  /// Checks if a value is compatible with an expected type
  bool isValueCompatibleWithExpectedType(dynamic value, Type expectedType) {
    if (expectedType == dynamic) return true;

    // Handle basic non-nullable types
    if (expectedType == String) return _isA<String>(value);
    if (expectedType == int) return _isA<int>(value);
    if (expectedType == double) return _isA<double>(value);
    if (expectedType == num) return _isA<num>(value);
    if (expectedType == bool) return _isA<bool>(value);

    // Handle nullable types using string comparison
    final typeString = expectedType.toString();
    if (typeString == 'String?') return _isA<String?>(value);
    if (typeString == 'int?') return _isA<int?>(value);
    if (typeString == 'double?') return _isA<double?>(value);
    if (typeString == 'num?') return _isA<num?>(value);
    if (typeString == 'bool?') return _isA<bool?>(value);

    // Handle complex generic types
    if (typeString == 'List<String>') return _isA<List<String>>(value);

    if (value == null) {
      return typeString.endsWith('?') || typeString == 'dynamic';
    }
    return value.runtimeType == expectedType;
  }

  /// Validates field type compatibility and throws FormFieldError.typeMismatch if invalid
  void validateValueType({
    required String fieldName,
    required dynamic value,
    required Type? expectedType,
    required String operation,
  }) {
    if (value != null && expectedType != null) {
      if (!isValueCompatibleWithExpectedType(value, expectedType)) {
        throw FormFieldError.typeMismatch(
          fieldName: fieldName,
          expectedType: expectedType,
          actualType: value.runtimeType,
          operation: operation,
        );
      }
    }
  }

  /// Validates a single value using a validator
  String? validateField<T>({
    required Validator? validator,
    T? value,
    required BuildContext context,
  }) {
    if (validator == null) return null;
    return validator.validate(value, context);
  }

  /// Validates a single field by name
  String? validateFieldByName({
    required String fieldName,
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final validator = validators[fieldName];
    if (validator == null) return null;
    final value = values[fieldName];
    return validator.validate(value, context);
  }

  /// Validates all fields and returns a map of field name to error message
  Map<String, String> validateFields({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final errors = <String, String>{};
    for (final fieldName in validators.keys) {
      final error = validateFieldByName(
        fieldName: fieldName,
        values: values,
        validators: validators,
        context: context,
      );
      if (error != null) {
        errors[fieldName] = error;
      }
    }
    return errors;
  }

  /// Computes the overall form validity based on values, validators, touched state, and validating fields
  bool computeOverallValidity({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required Map<String, bool> touchedFields,
    required BuildContext context,
    Set<String> validatingFields = const {},
  }) {
    if (validatingFields.isNotEmpty) return false;
    for (final fieldName in validators.keys) {
      if (touchedFields[fieldName] != true) return false;
      final error = validateFieldByName(
        fieldName: fieldName,
        values: values,
        validators: validators,
        context: context,
      );
      if (error != null) return false;
    }
    return true;
  }

  /// Computes overall form validity when custom errors or validating fields are present
  bool computeOverallValidityWithErrors({
    required Map<String, Object?> values,
    required Map<String, String> errors,
    required Map<String, bool> touchedFields,
    required Map<String, Validator> validators,
    required BuildContext context,
    Set<String> validatingFields = const {},
  }) {
    if (validatingFields.isNotEmpty) return false;
    if (errors.isNotEmpty) return false;

    for (final field in values.keys) {
      if (touchedFields[field] != true) return false;

      final validator = validators[field];
      if (validator != null) {
        final value = values[field];
        if (validator.validate(value, context) != null) {
          return false;
        }
      }
    }
    return true;
  }

  /// Validates fields that depend on the changed field
  Map<String, String> validateDependentFields({
    required String changedFieldName,
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
  }) {
    final errors = <String, String>{};

    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;

      if (validator is TypedCrossFieldValidator) {
        if (validator.dependentFields.contains(changedFieldName)) {
          final value = values[fieldName];
          final error = validator.validate(value, context);
          if (error != null) {
            errors[fieldName] = error;
          }
        }
      }
    }

    return errors;
  }

  /// Validates a single field with debouncing
  void validateFieldWithDebounce({
    required String fieldName,
    required Object? value,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(String? error) onValidationComplete,
  }) {
    _debounceTimers[fieldName]?.cancel();

    _debounceTimers[fieldName] = Timer(_debounceDelay, () {
      final validator = validators[fieldName];
      if (validator == null) {
        onValidationComplete(null);
        return;
      }
      final error = validator.validate(value, context);
      onValidationComplete(error);
    });
  }

  /// Validates all fields with debouncing
  void validateAllFieldsWithDebounce({
    required Map<String, Object?> values,
    required Map<String, Validator> validators,
    required BuildContext context,
    required void Function(Map<String, String> errors) onValidationComplete,
  }) {
    _cancelAllTimers();

    _debounceTimers['_all_fields'] = Timer(_debounceDelay, () {
      final errors = validateFields(
        values: values,
        validators: validators,
        context: context,
      );
      onValidationComplete(errors);
    });
  }

  /// Schedules async validation for a field with debouncing and token cancellation.
  void scheduleAsyncValidation<T>({
    required String fieldName,
    required T? value,
    required List<AsyncValidator<T>> asyncValidators,
    required BuildContext context,
    required Duration debounceDelay,
    required void Function(String fieldName) onValidationStart,
    required void Function(String fieldName, String? error) onValidationComplete,
    required void Function(Object error, StackTrace stackTrace, String fieldName) onError,
  }) {
    cancelAsyncValidation(fieldName);

    final token = (_asyncRequestTokens[fieldName] ?? 0) + 1;
    _asyncRequestTokens[fieldName] = token;

    _asyncDebounceTimers[fieldName] = Timer(debounceDelay, () async {
      _asyncDebounceTimers.remove(fieldName);

      if (_asyncRequestTokens[fieldName] != token) return;

      _activeValidatingFields.add(fieldName);
      onValidationStart(fieldName);

      String? validationError;
      final fallbackError =
          ValidatorLocalizations.of(context).asyncValidationError;

      for (final asyncValidator in asyncValidators) {
        if (_asyncRequestTokens[fieldName] != token) {
          _activeValidatingFields.remove(fieldName);
          return;
        }

        try {
          final error = await asyncValidator.validate(value, context);
          if (_asyncRequestTokens[fieldName] != token) {
            _activeValidatingFields.remove(fieldName);
            return;
          }

          if (error != null) {
            validationError = error;
            break;
          }
        } catch (err, stackTrace) {
          if (_asyncRequestTokens[fieldName] != token) {
            _activeValidatingFields.remove(fieldName);
            return;
          }

          onError(err, stackTrace, fieldName);
          validationError = fallbackError;
          break;
        }
      }

      if (_asyncRequestTokens[fieldName] != token) {
        _activeValidatingFields.remove(fieldName);
        return;
      }

      _activeValidatingFields.remove(fieldName);
      onValidationComplete(fieldName, validationError);
    });
  }

  /// Cancels debouncing timer for a specific field
  void cancelFieldValidation(String fieldName) {
    _debounceTimers[fieldName]?.cancel();
    _debounceTimers.remove(fieldName);
  }

  /// Cancels active debounce timer and invalidates in-flight async validation for [fieldName].
  void cancelAsyncValidation(String fieldName) {
    _asyncDebounceTimers[fieldName]?.cancel();
    _asyncDebounceTimers.remove(fieldName);
    _asyncRequestTokens[fieldName] = (_asyncRequestTokens[fieldName] ?? 0) + 1;
    _activeValidatingFields.remove(fieldName);
  }

  /// Cancels active debounce timers and invalidates in-flight async validations for all fields.
  void cancelAllAsyncValidations() {
    for (final timer in _asyncDebounceTimers.values) {
      timer.cancel();
    }
    _asyncDebounceTimers.clear();
    for (final field in _asyncRequestTokens.keys.toList()) {
      _asyncRequestTokens[field] = (_asyncRequestTokens[field] ?? 0) + 1;
    }
    _activeValidatingFields.clear();
  }

  /// Cancels all active debouncing timers
  void _cancelAllTimers() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// Cleanly disposes all resources and timers
  void dispose() {
    _cancelAllTimers();
    cancelAllAsyncValidations();
  }
}
