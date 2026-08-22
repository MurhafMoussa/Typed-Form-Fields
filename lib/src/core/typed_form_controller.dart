import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

import 'form_errors.dart';
import 'validation_strategy.dart';

part 'typed_form_state.dart';

/// Form cubit with type-safe state access
class TypedFormController extends Cubit<TypedFormState> {
  TypedFormController({
    List<FormFieldDefinition> fields = const [],
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
  }) : super(TypedFormState.initial()) {
    _fields = List<FormFieldDefinition>.from(fields);
    _validators = {};
    _touchedFields = {};

    for (final field in _fields) {
      _validators[field.name] = field.createValidator();
      _touchedFields[field.name] = false;
    }

    final initialValues = <String, Object?>{
      for (final field in _fields) field.name: field.initialValue
    };
    final initialFieldTypes = <String, Type>{
      for (final field in _fields) field.name: field.valueType
    };

    emit(
      TypedFormState(
        values: initialValues,
        errors: const {},
        isValid: validationStrategy.initialValidationState,
        validationStrategy: validationStrategy,
        fieldTypes: initialFieldTypes,
      ),
    );
  }

  late final List<FormFieldDefinition> _fields;
  late final Map<String, Validator> _validators;
  late final Map<String, bool> _touchedFields;
  final FormValidator _validator = FormValidator();

  bool _fieldExists(String fieldName) =>
      _fields.any((field) => field.name == fieldName);

  Type? _getFieldType(String fieldName) {
    for (final field in _fields) {
      if (field.name == fieldName) return field.valueType;
    }
    return null;
  }

  void _checkFieldExists(String fieldName) {
    if (!_fieldExists(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: _fields.map((f) => f.name).toList(),
        fieldTypes: {for (final f in _fields) f.name: f.valueType},
        currentValues: state.values,
      );
    }
  }

  /// Type-safe getter for field values
  T? getValue<T>(String fieldName) => state.getValue<T>(fieldName);

  /// Type-safe update method for a single field
  void updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    _checkFieldExists(fieldName);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedFields[fieldName] = true;

    final newValues = Map<String, Object?>.from(state.values)..[fieldName] = value;
    final newErrors = Map<String, String>.from(state.errors);

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        break;
      case ValidationStrategy.allFieldsRealTime:
        newErrors.clear();
        newErrors.addAll(
          _validator.validateFields(
            values: newValues,
            validators: _validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        final validator = _validators[fieldName];
        if (validator != null) {
          final error = validator.validate(value, context);
          if (error != null) {
            newErrors[fieldName] = error;
          } else {
            newErrors.remove(fieldName);
          }
        }
        break;
      case ValidationStrategy.disabled:
        newErrors.clear();
        break;
    }

    final isValid = state.validationStrategy == ValidationStrategy.disabled
        ? true
        : _validator.computeOverallValidity(
            values: newValues,
            validators: _validators,
            touchedFields: _touchedFields,
            context: context,
          );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        errors: newErrors,
        isValid: isValid,
      ),
    );
  }

  /// Type-safe update method for a single field with debouncing
  void updateFieldWithDebounce<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    _checkFieldExists(fieldName);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedFields[fieldName] = true;

    final newValues = Map<String, Object?>.from(state.values)..[fieldName] = value;

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        _emitIfChanged(state.copyWith(values: newValues));
        break;

      case ValidationStrategy.allFieldsRealTime:
        _validator.validateAllFieldsWithDebounce(
          values: newValues,
          validators: _validators,
          context: context,
          onValidationComplete: (errors) {
            final overallValid = _validator.computeOverallValidity(
              values: newValues,
              validators: _validators,
              touchedFields: _touchedFields,
              context: context,
            );
            _emitIfChanged(
              state.copyWith(
                values: newValues,
                errors: errors,
                isValid: overallValid,
              ),
            );
          },
        );
        break;

      case ValidationStrategy.realTimeOnly:
        _validator.validateFieldWithDebounce(
          fieldName: fieldName,
          value: value,
          validators: _validators,
          context: context,
          onValidationComplete: (error) {
            final newErrors = Map<String, String>.from(state.errors);
            if (error != null) {
              newErrors[fieldName] = error;
            } else {
              newErrors.remove(fieldName);
            }

            final overallValid = _validator.computeOverallValidity(
              values: newValues,
              validators: _validators,
              touchedFields: _touchedFields,
              context: context,
            );

            _emitIfChanged(
              state.copyWith(
                values: newValues,
                errors: newErrors,
                isValid: overallValid,
              ),
            );
          },
        );
        break;

      case ValidationStrategy.disabled:
        _emitIfChanged(
          state.copyWith(
            values: newValues,
            errors: const {},
            isValid: true,
          ),
        );
        break;
    }
  }

  /// Updates multiple fields at once with a single state emission
  void updateFields<T>({
    required Map<String, T?> fieldValues,
    required BuildContext context,
  }) {
    for (final entry in fieldValues.entries) {
      _checkFieldExists(entry.key);
      _validator.validateValueType(
        fieldName: entry.key,
        value: entry.value,
        expectedType: _getFieldType(entry.key),
        operation: 'orchestrateFieldValidation',
      );
      _touchedFields[entry.key] = true;
    }

    final newValues = Map<String, Object?>.from(state.values);
    fieldValues.forEach((key, value) {
      newValues[key] = value;
    });

    final newErrors = Map<String, String>.from(state.errors);

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        break;
      case ValidationStrategy.allFieldsRealTime:
        newErrors.clear();
        newErrors.addAll(
          _validator.validateFields(
            values: newValues,
            validators: _validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        for (final fieldName in fieldValues.keys) {
          final validator = _validators[fieldName];
          if (validator != null) {
            final value = newValues[fieldName];
            final error = validator.validate(value, context);
            if (error != null) {
              newErrors[fieldName] = error;
            } else {
              newErrors.remove(fieldName);
            }
          }
        }
        break;
      case ValidationStrategy.disabled:
        newErrors.clear();
        break;
    }

    final isValid = state.validationStrategy == ValidationStrategy.disabled
        ? true
        : _validator.computeOverallValidity(
            values: newValues,
            validators: _validators,
            touchedFields: _touchedFields,
            context: context,
          );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        errors: newErrors,
        isValid: isValid,
      ),
    );
  }

  /// Call this when you need to change the validation rules for a field based on
  /// other state in your application (e.g., making a field required based on a checkbox).
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    required BuildContext context,
  }) {
    _checkFieldExists(name);

    final fieldIndex = _fields.indexWhere((f) => f.name == name);
    if (fieldIndex != -1) {
      final field = _fields[fieldIndex];
      final updatedField = FormFieldDefinition<T>(
        name: name,
        validators: validators,
        initialValue: field.initialValue as T?,
      );
      _fields[fieldIndex] = updatedField;
      _validators[name] = updatedField.createValidator();
    }

    final newErrors = _validator.validateFields(
      values: state.values,
      validators: _validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: state.values,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Emits new state only if it's different from the current state
  void _emitIfChanged(TypedFormState newState) {
    if (newState != state) {
      emit(newState);
    }
  }

  /// Sets a new validation type for the form
  void setValidationStrategy(ValidationStrategy validationStrategy) {
    _emitIfChanged(state.copyWith(validationStrategy: validationStrategy));
  }

  /// Validates the entire form
  void validateForm(
    BuildContext context, {
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final strategy = state.validationStrategy;
    final shouldValidate = strategy.shouldValidateOnSubmission();

    if (shouldValidate) {
      final shouldSwitch = strategy.hasValidationErrorsFromEmptyValues(state.values);

      final newErrors = _validator.validateFields(
        values: state.values,
        validators: _validators,
        context: context,
      );
      final isValid = _validator.computeOverallValidity(
        values: state.values,
        validators: _validators,
        touchedFields: _touchedFields,
        context: context,
      );

      _emitIfChanged(state.copyWith(errors: newErrors, isValid: isValid));

      if (newErrors.isEmpty) {
        onValidationPass();
      } else {
        onValidationFail?.call();
      }

      if (shouldSwitch) {
        final newStrategy = strategy.getStrategyAfterValidationFailure();
        if (newStrategy != null) {
          setValidationStrategy(newStrategy);
        }
      }
    } else {
      onValidationPass();
    }
  }

  /// Validates a field immediately (no debouncing)
  ///
  /// This is useful for blur events, form submission, etc.
  void validateFieldImmediately({
    required String fieldName,
    required BuildContext context,
  }) {
    _checkFieldExists(fieldName);
    _validator.validateValueType(
      fieldName: fieldName,
      value: state.values[fieldName],
      expectedType: _getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    final validator = _validators[fieldName];
    final newErrors = Map<String, String>.from(state.errors);
    if (validator != null) {
      final value = state.values[fieldName];
      final error = validator.validate(value, context);
      if (error != null) {
        newErrors[fieldName] = error;
      } else {
        newErrors.remove(fieldName);
      }
    }

    final isValid = _validator.computeOverallValidity(
      values: state.values,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: isValid,
      ),
    );
  }

  /// Resets the form to its initial state
  void resetForm() {
    for (final key in _touchedFields.keys) {
      _touchedFields[key] = false;
    }

    final resetValues = <String, Object?>{
      for (final field in _fields) field.name: field.initialValue
    };

    _emitIfChanged(
      state.copyWith(values: resetValues, errors: const {}, isValid: false),
    );
  }

  /// Marks all fields as touched and validates them
  void touchAllFields(BuildContext context) {
    for (final key in _touchedFields.keys) {
      _touchedFields[key] = true;
    }

    final newErrors = _validator.validateFields(
      values: state.values,
      validators: _validators,
      context: context,
    );

    final isValid = _validator.computeOverallValidity(
      values: state.values,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: isValid,
      ),
    );
  }

  /// Manually set an error for a specific field
  ///
  /// This allows setting custom validation errors from outside the normal validation flow.
  /// Useful for server-side validation errors or custom validation logic.
  ///
  /// Parameters:
  /// - [fieldName]: The name of the field to set the error for
  /// - [errorMessage]: The error message to display. If null, any existing error is cleared.
  void updateError({
    required String fieldName,
    String? errorMessage,
    required BuildContext context,
  }) {
    _checkFieldExists(fieldName);
    _touchedFields[fieldName] = true;

    final newErrors = Map<String, String>.from(state.errors);
    if (errorMessage != null) {
      newErrors[fieldName] = errorMessage;
    } else {
      newErrors.remove(fieldName);
    }

    final overallValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedFields,
      validators: _validators,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: overallValid,
      ),
    );
  }

  /// Manually set multiple errors at once
  ///
  /// This allows setting custom validation errors for multiple fields.
  /// Useful for handling server-side validation responses.
  ///
  /// Parameters:
  /// - [errors]: Map of field names to error messages. If a field's error is null, any existing error is cleared.
  void updateErrors({
    required Map<String, String?> errors,
    required BuildContext context,
  }) {
    for (final fieldName in errors.keys) {
      _checkFieldExists(fieldName);
      _touchedFields[fieldName] = true;
    }

    final newErrors = Map<String, String>.from(state.errors);
    for (final entry in errors.entries) {
      if (entry.value != null) {
        newErrors[entry.key] = entry.value!;
      } else {
        newErrors.remove(entry.key);
      }
    }

    final overallValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedFields,
      validators: _validators,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: overallValid,
      ),
    );
  }

  /// Add a single field to the form dynamically
  void addField<T>({
    required FormFieldDefinition<T> field,
    required BuildContext context,
  }) {
    if (_fieldExists(field.name)) {
      throw FormFieldError.fieldAlreadyExists(fieldName: field.name);
    }

    _fields.add(field);
    _validators[field.name] = field.createValidator();
    _touchedFields[field.name] = false;

    final newValues = Map<String, Object?>.from(state.values);
    newValues[field.name] = field.initialValue;

    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);
    newFieldTypes[field.name] = T;

    final newErrors = _validator.validateFields(
      values: newValues,
      validators: _validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        fieldTypes: newFieldTypes,
        errors: newErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Add multiple fields to the form dynamically
  void addFields({
    required List<FormFieldDefinition> fields,
    required BuildContext context,
  }) {
    for (final field in fields) {
      if (_fieldExists(field.name)) {
        throw FormFieldError.fieldAlreadyExists(fieldName: field.name);
      }
    }

    for (final field in fields) {
      _fields.add(field);
      _validators[field.name] = field.createValidator();
      _touchedFields[field.name] = false;
    }

    final newValues = Map<String, Object?>.from(state.values);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);

    for (final field in fields) {
      newValues[field.name] = field.initialValue;
      newFieldTypes[field.name] = field.valueType;
    }

    final newErrors = _validator.validateFields(
      values: newValues,
      validators: _validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        fieldTypes: newFieldTypes,
        errors: newErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Remove a field from the form dynamically
  void removeField(String fieldName, {required BuildContext context}) {
    _checkFieldExists(fieldName);

    _fields.removeWhere((field) => field.name == fieldName);
    _validators.remove(fieldName);
    _touchedFields.remove(fieldName);

    final newValues = Map<String, Object?>.from(state.values)..remove(fieldName);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes)..remove(fieldName);

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        fieldTypes: newFieldTypes,
        errors: validatedErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Remove multiple fields from the form dynamically
  void removeFields(List<String> fieldNames, {required BuildContext context}) {
    for (final fieldName in fieldNames) {
      _checkFieldExists(fieldName);
    }

    for (final fieldName in fieldNames) {
      _fields.removeWhere((field) => field.name == fieldName);
      _validators.remove(fieldName);
      _touchedFields.remove(fieldName);
    }

    final newValues = Map<String, Object?>.from(state.values);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);

    for (final fieldName in fieldNames) {
      newValues.remove(fieldName);
      newFieldTypes.remove(fieldName);
    }

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _validators,
      touchedFields: _touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        values: newValues,
        fieldTypes: newFieldTypes,
        errors: validatedErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Disposes of all resources
  @override
  Future<void> close() {
    _validator.dispose();
    return super.close();
  }
}
