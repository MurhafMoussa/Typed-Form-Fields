import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

import 'form_errors.dart';
import 'form_field_registry.dart';
import 'form_touched_tracker.dart';
import 'validation_strategy.dart';

part 'typed_form_state.dart';

/// Form cubit with type-safe state access
class TypedFormController extends Cubit<TypedFormState> {
  TypedFormController({
    List<FormFieldDefinition> fields = const [],
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
  })  : _registry = FormFieldRegistry(fields),
        _touchedTracker = FormTouchedTracker(fields.map((f) => f.name)),
        super(TypedFormState.initial()) {
    emit(
      TypedFormState(
        values: _registry.initialValues,
        errors: const {},
        isValid: validationStrategy.initialValidationState,
        validationStrategy: validationStrategy,
        fieldTypes: _registry.fieldTypes,
      ),
    );
  }

  final FormFieldRegistry _registry;
  final FormTouchedTracker _touchedTracker;
  final FormValidator _validator = FormValidator();

  /// Type-safe getter for field values
  T? getValue<T>(String fieldName) => state.getValue<T>(fieldName);

  /// Type-safe update method for a single field
  void updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _registry.getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedTracker.markTouched(fieldName);

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
            validators: _registry.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        final validator = _registry.getValidator(fieldName);
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
            validators: _registry.validators,
            touchedFields: _touchedTracker.touchedFields,
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
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _registry.getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedTracker.markTouched(fieldName);

    final newValues = Map<String, Object?>.from(state.values)..[fieldName] = value;

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        _emitIfChanged(state.copyWith(values: newValues));
        break;

      case ValidationStrategy.allFieldsRealTime:
        _validator.validateAllFieldsWithDebounce(
          values: newValues,
          validators: _registry.validators,
          context: context,
          onValidationComplete: (errors) {
            final overallValid = _validator.computeOverallValidity(
              values: newValues,
              validators: _registry.validators,
              touchedFields: _touchedTracker.touchedFields,
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
          validators: _registry.validators,
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
              validators: _registry.validators,
              touchedFields: _touchedTracker.touchedFields,
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
      _registry.checkFieldExists(entry.key, currentValues: state.values);
      _validator.validateValueType(
        fieldName: entry.key,
        value: entry.value,
        expectedType: _registry.getFieldType(entry.key),
        operation: 'orchestrateFieldValidation',
      );
      _touchedTracker.markTouched(entry.key);
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
            validators: _registry.validators,
            context: context,
          ),
        );
        break;
      case ValidationStrategy.realTimeOnly:
        for (final fieldName in fieldValues.keys) {
          final validator = _registry.getValidator(fieldName);
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
            validators: _registry.validators,
            touchedFields: _touchedTracker.touchedFields,
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
    _registry.updateFieldValidators<T>(
      name: name,
      validators: validators,
      currentValues: state.values,
    );

    final newErrors = _validator.validateFields(
      values: state.values,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: state.values,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: newIsValid,
      ),
    );
  }

  /// Validates all fields in a named group.
  ///
  /// Marks fields in the group as touched, calculates validation errors for them,
  /// merges errors into state, re-evaluates overall form validity, invokes callbacks,
  /// and switches validation strategy from [ValidationStrategy.onSubmitThenRealTime] to
  /// [ValidationStrategy.realTimeOnly] if group validation fails.
  ///
  /// Returns cleanly without error if [groupName] matches no fields (empty or unknown group).
  void validateGroup(
    String groupName, {
    required BuildContext context,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final groupFields = _registry.getFieldsByGroup(groupName);
    if (groupFields.isEmpty) {
      onValidationPass?.call();
      return;
    }

    for (final field in groupFields) {
      _touchedTracker.markTouched(field.name);
    }

    final newErrors = Map<String, String>.from(state.errors);
    for (final field in groupFields) {
      final error = _validator.validateFieldByName(
        fieldName: field.name,
        values: state.values,
        validators: _registry.validators,
        context: context,
      );
      if (error != null) {
        newErrors[field.name] = error;
      } else {
        newErrors.remove(field.name);
      }
    }

    final isValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: isValid,
      ),
    );

    final hasGroupErrors = groupFields.any((f) => newErrors.containsKey(f.name));
    if (hasGroupErrors) {
      onValidationFail?.call();
      if (state.validationStrategy == ValidationStrategy.onSubmitThenRealTime) {
        setValidationStrategy(ValidationStrategy.realTimeOnly);
      }
    } else {
      onValidationPass?.call();
    }
  }

  /// Validates a specific subset of fields by name.
  ///
  /// Marks specified fields as touched, calculates validation errors for them,
  /// merges errors into state, re-evaluates overall form validity, invokes callbacks,
  /// and switches validation strategy from [ValidationStrategy.onSubmitThenRealTime] to
  /// [ValidationStrategy.realTimeOnly] if subset validation fails.
  ///
  /// Throws [FormFieldError.fieldNotFound] if any specified field does not exist.
  /// Input list is deduplicated. Empty list passes validation cleanly.
  void validateFields(
    List<String> fieldNames, {
    required BuildContext context,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    if (fieldNames.isEmpty) {
      onValidationPass?.call();
      return;
    }

    final uniqueNames = fieldNames.toSet().toList();

    for (final fieldName in uniqueNames) {
      _registry.checkFieldExists(fieldName, currentValues: state.values);
    }

    for (final fieldName in uniqueNames) {
      _touchedTracker.markTouched(fieldName);
    }

    final newErrors = Map<String, String>.from(state.errors);
    for (final fieldName in uniqueNames) {
      final error = _validator.validateFieldByName(
        fieldName: fieldName,
        values: state.values,
        validators: _registry.validators,
        context: context,
      );
      if (error != null) {
        newErrors[fieldName] = error;
      } else {
        newErrors.remove(fieldName);
      }
    }

    final isValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: isValid,
      ),
    );

    final hasSubsetErrors =
        uniqueNames.any((name) => newErrors.containsKey(name));
    if (hasSubsetErrors) {
      onValidationFail?.call();
      if (state.validationStrategy == ValidationStrategy.onSubmitThenRealTime) {
        setValidationStrategy(ValidationStrategy.realTimeOnly);
      }
    } else {
      onValidationPass?.call();
    }
  }

  /// Passively checks validity of all fields in [groupName].
  ///
  /// Returns `true` if all fields in group pass validation or if [groupName] is empty/unknown.
  /// Does not alter touched state, trigger debouncing, or emit state updates.
  bool isGroupValid(
    String groupName, {
    required BuildContext context,
  }) {
    final groupFields = _registry.getFieldsByGroup(groupName);
    if (groupFields.isEmpty) return true;

    for (final field in groupFields) {
      final error = _validator.validateFieldByName(
        fieldName: field.name,
        values: state.values,
        validators: _registry.validators,
        context: context,
      );
      if (error != null) return false;
    }
    return true;
  }

  /// Passively checks validity of a list of fields by name.
  ///
  /// Returns `true` if all fields pass validation or if [fieldNames] is empty.
  /// Returns `false` if any field fails validation or is missing.
  /// Does not alter touched state, trigger debouncing, or emit state updates.
  bool areFieldsValid(
    List<String> fieldNames, {
    required BuildContext context,
  }) {
    if (fieldNames.isEmpty) return true;

    final uniqueNames = fieldNames.toSet();
    for (final fieldName in uniqueNames) {
      if (!_registry.containsField(fieldName)) return false;
      final error = _validator.validateFieldByName(
        fieldName: fieldName,
        values: state.values,
        validators: _registry.validators,
        context: context,
      );
      if (error != null) return false;
    }
    return true;
  }

  /// Marks all fields in [groupName] as touched and updates form state.
  ///
  /// Re-evaluates form state errors and overall form validity.
  /// Does not invoke callbacks or switch validation strategies.
  /// Returns cleanly without error if [groupName] matches no fields.
  void touchGroup(
    String groupName, {
    required BuildContext context,
  }) {
    final groupFields = _registry.getFieldsByGroup(groupName);
    if (groupFields.isEmpty) return;

    for (final field in groupFields) {
      _touchedTracker.markTouched(field.name);
    }

    final newErrors = Map<String, String>.from(state.errors);
    for (final field in groupFields) {
      final error = _validator.validateFieldByName(
        fieldName: field.name,
        values: state.values,
        validators: _registry.validators,
        context: context,
      );
      if (error != null) {
        newErrors[field.name] = error;
      } else {
        newErrors.remove(field.name);
      }
    }

    final isValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
      context: context,
    );

    _emitIfChanged(
      state.copyWith(
        errors: newErrors,
        isValid: isValid,
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
        validators: _registry.validators,
        context: context,
      );
      final isValid = _validator.computeOverallValidity(
        values: state.values,
        validators: _registry.validators,
        touchedFields: _touchedTracker.touchedFields,
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
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _validator.validateValueType(
      fieldName: fieldName,
      value: state.values[fieldName],
      expectedType: _registry.getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    final validator = _registry.getValidator(fieldName);
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
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
    _touchedTracker.reset();

    final resetValues = _registry.initialValues;

    _emitIfChanged(
      state.copyWith(values: resetValues, errors: const {}, isValid: false),
    );
  }

  /// Marks all fields as touched and validates them
  void touchAllFields(BuildContext context) {
    _touchedTracker.markAllTouched();

    final newErrors = _validator.validateFields(
      values: state.values,
      validators: _registry.validators,
      context: context,
    );

    final isValid = _validator.computeOverallValidity(
      values: state.values,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _touchedTracker.markTouched(fieldName);

    final newErrors = Map<String, String>.from(state.errors);
    if (errorMessage != null) {
      newErrors[fieldName] = errorMessage;
    } else {
      newErrors.remove(fieldName);
    }

    final overallValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
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
      _registry.checkFieldExists(fieldName, currentValues: state.values);
      _touchedTracker.markTouched(fieldName);
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
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
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
    _registry.addField<T>(field);
    _touchedTracker.markTouched(field.name, false);

    final newValues = Map<String, Object?>.from(state.values);
    newValues[field.name] = field.initialValue;

    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);
    newFieldTypes[field.name] = T;

    final newErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
    _registry.addFields(fields);
    for (final field in fields) {
      _touchedTracker.markTouched(field.name, false);
    }

    final newValues = Map<String, Object?>.from(state.values);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);

    for (final field in fields) {
      newValues[field.name] = field.initialValue;
      newFieldTypes[field.name] = field.valueType;
    }

    final newErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
    _registry.removeField(fieldName, currentValues: state.values);
    _touchedTracker.remove(fieldName);

    final newValues = Map<String, Object?>.from(state.values)..remove(fieldName);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes)..remove(fieldName);

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
    _registry.removeFields(fieldNames, currentValues: state.values);
    _touchedTracker.removeFields(fieldNames);

    final newValues = Map<String, Object?>.from(state.values);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);

    for (final fieldName in fieldNames) {
      newValues.remove(fieldName);
      newFieldTypes.remove(fieldName);
    }

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidity(
      values: newValues,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
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
