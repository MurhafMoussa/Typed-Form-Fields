import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/form_field_registry.dart';
import 'package:typed_form_fields/src/core/form_touched_tracker.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/core/typed_form_state.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Package-private orchestrator for form validation strategies and group/subset evaluations.
class FormValidationOrchestrator {
  FormValidationOrchestrator({
    required FormFieldRegistry registry,
    required FormTouchedTracker touchedTracker,
    required FormValidator validator,
    required Duration asyncDebounceDelay,
    void Function(Object error, StackTrace stackTrace, String fieldName)?
        onAsyncValidationError,
  })  : _registry = registry,
        _touchedTracker = touchedTracker,
        _validator = validator,
        _asyncDebounceDelay = asyncDebounceDelay,
        _onAsyncValidationError = onAsyncValidationError;

  final FormFieldRegistry _registry;
  final FormTouchedTracker _touchedTracker;
  final FormValidator _validator;
  final Duration _asyncDebounceDelay;
  final void Function(Object error, StackTrace stackTrace, String fieldName)?
      _onAsyncValidationError;

  /// Schedules async validation for a field with debouncing and token cancellation.
  void scheduleFieldAsyncValidation<T>({
    required String fieldName,
    required T? value,
    required List<AsyncValidator<T>> asyncValidators,
    required BuildContext context,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
    Duration? customDebounceDelay,
  }) {
    _validator.scheduleAsyncValidation<T>(
      fieldName: fieldName,
      value: value,
      asyncValidators: asyncValidators,
      context: context,
      debounceDelay: customDebounceDelay ?? _asyncDebounceDelay,
      onValidationStart: (fName) {
        final state = getState();
        final newValidating = Set<String>.from(state.validatingFields)
          ..add(fName);
        emitState(
          state.copyWith(
            validatingFields: newValidating,
            isValid: false,
          ),
        );
      },
      onValidationComplete: (fName, error) {
        final state = getState();
        final newValidating = Set<String>.from(state.validatingFields)
          ..remove(fName);
        final newErrors = Map<String, String>.from(state.errors);
        if (error != null) {
          newErrors[fName] = error;
        } else {
          newErrors.remove(fName);
        }

        final isValid = _validator.computeOverallValidityWithErrors(
          values: state.values,
          errors: newErrors,
          touchedFields: _touchedTracker.touchedFields,
          validators: _registry.validators,
          context: context,
          validatingFields: newValidating,
        );

        emitState(
          state.copyWith(
            errors: newErrors,
            validatingFields: newValidating,
            isValid: isValid,
          ),
        );
      },
      onError: (error, stackTrace, fName) {
        _onAsyncValidationError?.call(error, stackTrace, fName);
      },
    );
  }

  /// Updates a single field according to the active validation strategy.
  TypedFormState updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
  }) {
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _registry.getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedTracker.markTouched(fieldName);

    final newValues = Map<String, Object?>.from(state.values)
      ..[fieldName] = value;
    final newErrors = Map<String, String>.from(state.errors);
    final newValidatingFields = Set<String>.from(state.validatingFields);

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        _validator.cancelAsyncValidation(fieldName);
        newValidatingFields.remove(fieldName);
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

        if (newErrors.containsKey(fieldName)) {
          _validator.cancelAsyncValidation(fieldName);
          newValidatingFields.remove(fieldName);
        } else {
          final asyncVals = _registry.getAsyncValidators(fieldName);
          if (asyncVals != null && asyncVals.isNotEmpty) {
            scheduleFieldAsyncValidation<T>(
              fieldName: fieldName,
              value: value,
              asyncValidators: asyncVals.cast<AsyncValidator<T>>(),
              context: context,
              getState: getState,
              emitState: emitState,
            );
          } else {
            _validator.cancelAsyncValidation(fieldName);
            newValidatingFields.remove(fieldName);
          }
        }
        break;

      case ValidationStrategy.realTimeOnly:
        final validator = _registry.getValidator(fieldName);
        String? syncError;
        if (validator != null) {
          syncError = validator.validate(value, context);
        }

        if (syncError != null) {
          newErrors[fieldName] = syncError;
          _validator.cancelAsyncValidation(fieldName);
          newValidatingFields.remove(fieldName);
        } else {
          newErrors.remove(fieldName);
          final asyncVals = _registry.getAsyncValidators(fieldName);
          if (asyncVals != null && asyncVals.isNotEmpty) {
            scheduleFieldAsyncValidation<T>(
              fieldName: fieldName,
              value: value,
              asyncValidators: asyncVals.cast<AsyncValidator<T>>(),
              context: context,
              getState: getState,
              emitState: emitState,
            );
          } else {
            _validator.cancelAsyncValidation(fieldName);
            newValidatingFields.remove(fieldName);
          }
        }
        break;

      case ValidationStrategy.disabled:
        _validator.cancelAllAsyncValidations();
        newErrors.clear();
        newValidatingFields.clear();
        break;
    }

    final isValid = state.validationStrategy == ValidationStrategy.disabled
        ? true
        : _validator.computeOverallValidityWithErrors(
            values: newValues,
            errors: newErrors,
            validators: _registry.validators,
            touchedFields: _touchedTracker.touchedFields,
            context: context,
            validatingFields: newValidatingFields,
          );

    return state.copyWith(
      values: newValues,
      errors: newErrors,
      isValid: isValid,
      validatingFields: newValidatingFields,
    );
  }

  /// Updates a single field with debounced validation according to the active validation strategy.
  void updateFieldWithDebounce<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
  }) {
    _registry.checkFieldExists(fieldName, currentValues: state.values);
    _validator.validateValueType(
      fieldName: fieldName,
      value: value,
      expectedType: _registry.getFieldType(fieldName),
      operation: 'orchestrateFieldValidation',
    );

    _touchedTracker.markTouched(fieldName);

    final newValues = Map<String, Object?>.from(state.values)
      ..[fieldName] = value;

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        _validator.cancelAsyncValidation(fieldName);
        final newValidating = Set<String>.from(state.validatingFields)
          ..remove(fieldName);
        emitState(
          state.copyWith(values: newValues, validatingFields: newValidating),
        );
        break;

      case ValidationStrategy.allFieldsRealTime:
        _validator.validateAllFieldsWithDebounce(
          values: newValues,
          validators: _registry.validators,
          context: context,
          onValidationComplete: (errors) {
            final currentState = getState();
            if (errors.containsKey(fieldName)) {
              _validator.cancelAsyncValidation(fieldName);
              final newValidating =
                  Set<String>.from(currentState.validatingFields)
                    ..remove(fieldName);
              final overallValid = _validator.computeOverallValidityWithErrors(
                values: newValues,
                errors: errors,
                touchedFields: _touchedTracker.touchedFields,
                validators: _registry.validators,
                context: context,
                validatingFields: newValidating,
              );
              emitState(
                currentState.copyWith(
                  values: newValues,
                  errors: errors,
                  isValid: overallValid,
                  validatingFields: newValidating,
                ),
              );
            } else {
              final asyncVals = _registry.getAsyncValidators(fieldName);
              if (asyncVals != null && asyncVals.isNotEmpty) {
                scheduleFieldAsyncValidation<T>(
                  fieldName: fieldName,
                  value: value,
                  asyncValidators: asyncVals.cast<AsyncValidator<T>>(),
                  context: context,
                  getState: getState,
                  emitState: emitState,
                );
              } else {
                _validator.cancelAsyncValidation(fieldName);
                final newValidating =
                    Set<String>.from(currentState.validatingFields)
                      ..remove(fieldName);
                final overallValid =
                    _validator.computeOverallValidityWithErrors(
                  values: newValues,
                  errors: errors,
                  touchedFields: _touchedTracker.touchedFields,
                  validators: _registry.validators,
                  context: context,
                  validatingFields: newValidating,
                );
                emitState(
                  currentState.copyWith(
                    values: newValues,
                    errors: errors,
                    isValid: overallValid,
                    validatingFields: newValidating,
                  ),
                );
              }
            }
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
            final currentState = getState();
            final newErrors = Map<String, String>.from(currentState.errors);
            if (error != null) {
              newErrors[fieldName] = error;
              _validator.cancelAsyncValidation(fieldName);
              final newValidating =
                  Set<String>.from(currentState.validatingFields)
                    ..remove(fieldName);
              final overallValid = _validator.computeOverallValidityWithErrors(
                values: newValues,
                errors: newErrors,
                touchedFields: _touchedTracker.touchedFields,
                validators: _registry.validators,
                context: context,
                validatingFields: newValidating,
              );
              emitState(
                currentState.copyWith(
                  values: newValues,
                  errors: newErrors,
                  isValid: overallValid,
                  validatingFields: newValidating,
                ),
              );
            } else {
              newErrors.remove(fieldName);
              final asyncVals = _registry.getAsyncValidators(fieldName);
              if (asyncVals != null && asyncVals.isNotEmpty) {
                scheduleFieldAsyncValidation<T>(
                  fieldName: fieldName,
                  value: value,
                  asyncValidators: asyncVals.cast<AsyncValidator<T>>(),
                  context: context,
                  getState: getState,
                  emitState: emitState,
                );
              } else {
                _validator.cancelAsyncValidation(fieldName);
                final newValidating =
                    Set<String>.from(currentState.validatingFields)
                      ..remove(fieldName);
                final overallValid =
                    _validator.computeOverallValidityWithErrors(
                  values: newValues,
                  errors: newErrors,
                  touchedFields: _touchedTracker.touchedFields,
                  validators: _registry.validators,
                  context: context,
                  validatingFields: newValidating,
                );
                emitState(
                  currentState.copyWith(
                    values: newValues,
                    errors: newErrors,
                    isValid: overallValid,
                    validatingFields: newValidating,
                  ),
                );
              }
            }
          },
        );
        break;

      case ValidationStrategy.disabled:
        _validator.cancelAllAsyncValidations();
        emitState(
          state.copyWith(
            values: newValues,
            errors: const {},
            isValid: true,
            validatingFields: const {},
          ),
        );
        break;
    }
  }

  /// Updates multiple fields at once according to the active validation strategy.
  TypedFormState updateFields<T>({
    required Map<String, T?> fieldValues,
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
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
    final newValidatingFields = Set<String>.from(state.validatingFields);

    switch (state.validationStrategy) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
        for (final fieldName in fieldValues.keys) {
          _validator.cancelAsyncValidation(fieldName);
          newValidatingFields.remove(fieldName);
        }
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

        for (final fieldName in fieldValues.keys) {
          if (newErrors.containsKey(fieldName)) {
            _validator.cancelAsyncValidation(fieldName);
            newValidatingFields.remove(fieldName);
          } else {
            final asyncVals = _registry.getAsyncValidators(fieldName);
            if (asyncVals != null && asyncVals.isNotEmpty) {
              scheduleFieldAsyncValidation(
                fieldName: fieldName,
                value: newValues[fieldName],
                asyncValidators: asyncVals,
                context: context,
                getState: getState,
                emitState: emitState,
              );
            } else {
              _validator.cancelAsyncValidation(fieldName);
              newValidatingFields.remove(fieldName);
            }
          }
        }
        break;

      case ValidationStrategy.realTimeOnly:
        for (final fieldName in fieldValues.keys) {
          final validator = _registry.getValidator(fieldName);
          String? syncError;
          if (validator != null) {
            syncError = validator.validate(newValues[fieldName], context);
          }

          if (syncError != null) {
            newErrors[fieldName] = syncError;
            _validator.cancelAsyncValidation(fieldName);
            newValidatingFields.remove(fieldName);
          } else {
            newErrors.remove(fieldName);
            final asyncVals = _registry.getAsyncValidators(fieldName);
            if (asyncVals != null && asyncVals.isNotEmpty) {
              scheduleFieldAsyncValidation(
                fieldName: fieldName,
                value: newValues[fieldName],
                asyncValidators: asyncVals,
                context: context,
                getState: getState,
                emitState: emitState,
              );
            } else {
              _validator.cancelAsyncValidation(fieldName);
              newValidatingFields.remove(fieldName);
            }
          }
        }
        break;

      case ValidationStrategy.disabled:
        _validator.cancelAllAsyncValidations();
        newErrors.clear();
        newValidatingFields.clear();
        break;
    }

    final isValid = state.validationStrategy == ValidationStrategy.disabled
        ? true
        : _validator.computeOverallValidityWithErrors(
            values: newValues,
            errors: newErrors,
            validators: _registry.validators,
            touchedFields: _touchedTracker.touchedFields,
            context: context,
            validatingFields: newValidatingFields,
          );

    return state.copyWith(
      values: newValues,
      errors: newErrors,
      isValid: isValid,
      validatingFields: newValidatingFields,
    );
  }

  /// Updates field validators dynamically and re-evaluates validation state.
  TypedFormState updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    List<AsyncValidator<T>>? asyncValidators,
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
  }) {
    _registry.updateFieldValidators<T>(
      name: name,
      validators: validators,
      asyncValidators: asyncValidators,
      currentValues: state.values,
    );

    final newErrors = Map<String, String>.from(state.errors);
    final newValidatingFields = Set<String>.from(state.validatingFields);

    final validator = _registry.getValidator(name);
    final value = state.values[name];
    final syncError = validator?.validate(value, context);

    if (syncError != null) {
      newErrors[name] = syncError;
      _validator.cancelAsyncValidation(name);
      newValidatingFields.remove(name);
    } else {
      newErrors.remove(name);
      final asyncVals = _registry.getAsyncValidators(name);
      if (asyncVals != null && asyncVals.isNotEmpty) {
        scheduleFieldAsyncValidation(
          fieldName: name,
          value: value,
          asyncValidators: asyncVals,
          context: context,
          getState: getState,
          emitState: emitState,
        );
      } else {
        _validator.cancelAsyncValidation(name);
        newValidatingFields.remove(name);
      }
    }

    final newIsValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
      context: context,
      validatingFields: newValidatingFields,
    );

    return state.copyWith(
      errors: newErrors,
      isValid: newIsValid,
      validatingFields: newValidatingFields,
    );
  }

  /// Validates all fields in a named group.
  TypedFormState validateGroup(
    String groupName, {
    required BuildContext context,
    required TypedFormState state,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final groupFields = _registry.getFieldsByGroup(groupName);
    if (groupFields.isEmpty) {
      onValidationPass?.call();
      return state;
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

    ValidationStrategy newStrategy = state.validationStrategy;
    final hasGroupErrors =
        groupFields.any((f) => newErrors.containsKey(f.name));
    if (hasGroupErrors) {
      onValidationFail?.call();
      if (state.validationStrategy == ValidationStrategy.onSubmitThenRealTime) {
        newStrategy = ValidationStrategy.realTimeOnly;
      }
    } else {
      onValidationPass?.call();
    }

    return state.copyWith(
      errors: newErrors,
      isValid: isValid,
      validationStrategy: newStrategy,
    );
  }

  /// Validates a specific subset of fields by name.
  TypedFormState validateFields(
    List<String> fieldNames, {
    required BuildContext context,
    required TypedFormState state,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    if (fieldNames.isEmpty) {
      onValidationPass?.call();
      return state;
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

    ValidationStrategy newStrategy = state.validationStrategy;
    final hasSubsetErrors =
        uniqueNames.any((name) => newErrors.containsKey(name));
    if (hasSubsetErrors) {
      onValidationFail?.call();
      if (state.validationStrategy == ValidationStrategy.onSubmitThenRealTime) {
        newStrategy = ValidationStrategy.realTimeOnly;
      }
    } else {
      onValidationPass?.call();
    }

    return state.copyWith(
      errors: newErrors,
      isValid: isValid,
      validationStrategy: newStrategy,
    );
  }

  /// Passively checks validity of all fields in [groupName].
  bool isGroupValid(
    String groupName, {
    required BuildContext context,
    required TypedFormState state,
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
  bool areFieldsValid(
    List<String> fieldNames, {
    required BuildContext context,
    required TypedFormState state,
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
  TypedFormState touchGroup(
    String groupName, {
    required BuildContext context,
    required TypedFormState state,
  }) {
    final groupFields = _registry.getFieldsByGroup(groupName);
    if (groupFields.isEmpty) return state;

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

    return state.copyWith(
      errors: newErrors,
      isValid: isValid,
    );
  }
}
