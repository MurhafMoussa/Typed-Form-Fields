import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/form_field_registry.dart';
import 'package:typed_form_fields/src/core/form_touched_tracker.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/core/typed_form_state.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/models.dart';
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

  /// Returns an unmodifiable map of field names to touched status.
  Map<String, bool> get touchedFields => _touchedTracker.touchedFields;

  /// Returns whether a specific field is marked as touched.
  bool isTouched(String fieldName) => _touchedTracker.isTouched(fieldName);

  /// Returns initial values for all registered fields.
  Map<String, Object?> get initialValues => _registry.initialValues;

  /// Checks if any field value differs from its initial value.
  bool isDirty(Map<String, Object?> currentValues) {
    final initial = _registry.initialValues;
    if (initial.length != currentValues.length) return true;
    for (final entry in initial.entries) {
      if (!currentValues.containsKey(entry.key)) return true;
      if (currentValues[entry.key] != entry.value) return true;
    }
    return false;
  }

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

  /// Validates the entire form according to the current strategy.
  FutureOr<void> validateForm({
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final strategy = state.validationStrategy;
    final shouldValidate = strategy.shouldValidateOnSubmission();

    if (shouldValidate) {
      final shouldSwitch =
          strategy.hasValidationErrorsFromEmptyValues(state.values);

      _touchedTracker.markAllTouched();

      final newErrors = _validator.validateFields(
        values: state.values,
        validators: _registry.validators,
        context: context,
      );

      bool hasAsyncToRun = false;
      for (final field in _registry.fields) {
        if (newErrors.containsKey(field.name)) {
          _validator.cancelAsyncValidation(field.name);
        } else {
          final asyncVals = _registry.getAsyncValidators(field.name);
          if (asyncVals != null && asyncVals.isNotEmpty) {
            if (!_validator.isFieldValidating(field.name) &&
                !_validator.isFieldDebouncing(field.name)) {
              scheduleFieldAsyncValidation(
                fieldName: field.name,
                value: state.values[field.name],
                asyncValidators: asyncVals,
                context: context,
                getState: getState,
                emitState: emitState,
                customDebounceDelay: Duration.zero,
              );
            }
            hasAsyncToRun = true;
          }
        }
      }

      if (_validator.hasActiveOrPendingAsyncValidations || hasAsyncToRun) {
        return () async {
          await _validator.flushAndAwaitAsyncValidations();
          if (context.mounted) {
            _finishValidation(
              context: context,
              strategy: strategy,
              syncErrors: newErrors,
              shouldSwitch: shouldSwitch,
              getState: getState,
              emitState: emitState,
              onValidationPass: onValidationPass,
              onValidationFail: onValidationFail,
            );
          }
        }();
      } else {
        _finishValidation(
          context: context,
          strategy: strategy,
          syncErrors: newErrors,
          shouldSwitch: shouldSwitch,
          getState: getState,
          emitState: emitState,
          onValidationPass: onValidationPass,
          onValidationFail: onValidationFail,
        );
      }
    } else {
      onValidationPass();
    }
  }

  void _finishValidation({
    required BuildContext context,
    required ValidationStrategy strategy,
    required Map<String, String> syncErrors,
    required bool shouldSwitch,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final state = getState();
    final finalErrors = Map<String, String>.from(state.errors);
    for (final entry in syncErrors.entries) {
      finalErrors[entry.key] = entry.value;
    }

    final isValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: finalErrors,
      touchedFields: _touchedTracker.touchedFields,
      validators: _registry.validators,
      context: context,
      validatingFields: state.validatingFields,
    );

    ValidationStrategy newStrategy = state.validationStrategy;
    if (shouldSwitch) {
      final s = strategy.getStrategyAfterValidationFailure();
      if (s != null) {
        newStrategy = s;
      }
    }

    emitState(
      state.copyWith(
        errors: finalErrors,
        isValid: isValid,
        validationStrategy: newStrategy,
      ),
    );

    if (isValid && finalErrors.isEmpty && state.validatingFields.isEmpty) {
      onValidationPass();
    } else {
      onValidationFail?.call();
    }
  }

  /// Validates a field immediately (no debouncing).
  TypedFormState validateFieldImmediately({
    required String fieldName,
    required BuildContext context,
    required TypedFormState state,
    required TypedFormState Function() getState,
    required void Function(TypedFormState newState) emitState,
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
    final newValidatingFields = Set<String>.from(state.validatingFields);
    final value = state.values[fieldName];

    if (validator != null) {
      final error = validator.validate(value, context);
      if (error != null) {
        newErrors[fieldName] = error;
        _validator.cancelAsyncValidation(fieldName);
        newValidatingFields.remove(fieldName);
      } else {
        newErrors.remove(fieldName);
        final asyncVals = _registry.getAsyncValidators(fieldName);
        if (asyncVals != null && asyncVals.isNotEmpty) {
          scheduleFieldAsyncValidation(
            fieldName: fieldName,
            value: value,
            asyncValidators: asyncVals,
            context: context,
            getState: getState,
            emitState: emitState,
            customDebounceDelay: Duration.zero,
          );
        } else {
          _validator.cancelAsyncValidation(fieldName);
          newValidatingFields.remove(fieldName);
        }
      }
    }

    final isValid = _validator.computeOverallValidityWithErrors(
      values: state.values,
      errors: newErrors,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
      context: context,
      validatingFields: newValidatingFields,
    );

    return state.copyWith(
      errors: newErrors,
      isValid: isValid,
      validatingFields: newValidatingFields,
    );
  }

  /// Resets the form to its initial state.
  TypedFormState resetForm({
    required TypedFormState state,
  }) {
    _touchedTracker.reset();
    _validator.cancelAllAsyncValidations();

    final resetValues = _registry.initialValues;

    return state.copyWith(
      values: resetValues,
      errors: const {},
      isValid: false,
      validatingFields: const {},
    );
  }

  /// Marks all fields as touched and validates them.
  TypedFormState touchAllFields({
    required BuildContext context,
    required TypedFormState state,
  }) {
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

    return state.copyWith(
      errors: newErrors,
      isValid: isValid,
    );
  }

  /// Manually set an error for a specific field.
  TypedFormState updateError({
    required String fieldName,
    String? errorMessage,
    required BuildContext context,
    required TypedFormState state,
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

    return state.copyWith(
      errors: newErrors,
      isValid: overallValid,
    );
  }

  /// Manually set multiple errors at once.
  TypedFormState updateErrors({
    required Map<String, String?> errors,
    required BuildContext context,
    required TypedFormState state,
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

    return state.copyWith(
      errors: newErrors,
      isValid: overallValid,
    );
  }

  /// Add a single field to the form dynamically.
  TypedFormState addField<T>({
    required FormFieldDefinition<T> field,
    required BuildContext context,
    required TypedFormState state,
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

    return state.copyWith(
      values: newValues,
      fieldTypes: newFieldTypes,
      errors: newErrors,
      isValid: newIsValid,
    );
  }

  /// Add multiple fields to the form dynamically.
  TypedFormState addFields({
    required List<FormFieldDefinition> fields,
    required BuildContext context,
    required TypedFormState state,
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

    return state.copyWith(
      values: newValues,
      fieldTypes: newFieldTypes,
      errors: newErrors,
      isValid: newIsValid,
    );
  }

  /// Remove a field from the form dynamically.
  TypedFormState removeField(
    String fieldName, {
    required BuildContext context,
    required TypedFormState state,
  }) {
    _registry.removeField(fieldName, currentValues: state.values);
    _touchedTracker.remove(fieldName);
    _validator.cancelAsyncValidation(fieldName);

    final newValues = Map<String, Object?>.from(state.values)
      ..remove(fieldName);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes)
      ..remove(fieldName);
    final newValidatingFields = Set<String>.from(state.validatingFields)
      ..remove(fieldName);

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidityWithErrors(
      values: newValues,
      errors: validatedErrors,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
      context: context,
      validatingFields: newValidatingFields,
    );

    return state.copyWith(
      values: newValues,
      fieldTypes: newFieldTypes,
      errors: validatedErrors,
      isValid: newIsValid,
      validatingFields: newValidatingFields,
    );
  }

  /// Remove multiple fields from the form dynamically.
  TypedFormState removeFields(
    List<String> fieldNames, {
    required BuildContext context,
    required TypedFormState state,
  }) {
    _registry.removeFields(fieldNames, currentValues: state.values);
    _touchedTracker.removeFields(fieldNames);
    for (final f in fieldNames) {
      _validator.cancelAsyncValidation(f);
    }

    final newValues = Map<String, Object?>.from(state.values);
    final newFieldTypes = Map<String, Type>.from(state.fieldTypes);
    final newValidatingFields = Set<String>.from(state.validatingFields);

    for (final fieldName in fieldNames) {
      newValues.remove(fieldName);
      newFieldTypes.remove(fieldName);
      newValidatingFields.remove(fieldName);
    }

    final validatedErrors = _validator.validateFields(
      values: newValues,
      validators: _registry.validators,
      context: context,
    );

    final newIsValid = _validator.computeOverallValidityWithErrors(
      values: newValues,
      errors: validatedErrors,
      validators: _registry.validators,
      touchedFields: _touchedTracker.touchedFields,
      context: context,
      validatingFields: newValidatingFields,
    );

    return state.copyWith(
      values: newValues,
      fieldTypes: newFieldTypes,
      errors: validatedErrors,
      isValid: newIsValid,
      validatingFields: newValidatingFields,
    );
  }
}
