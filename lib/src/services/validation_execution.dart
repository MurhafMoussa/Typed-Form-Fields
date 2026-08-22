import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for handling form validation operations
abstract class ValidationExecution {
  /// Validate a field immediately
  TypedFormState validateFieldImmediately({
    required String fieldName,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Update field validators and re-validate
  TypedFormState updateFieldValidators<T>({
    required String fieldName,
    required List<Validator<T>> validators,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Validate the entire form
  TypedFormState validateForm({
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  });

  /// Touch all fields and validate them
  TypedFormState touchAllFields({
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  });
}

/// Default implementation of ValidationExecution
class DefaultValidationExecution implements ValidationExecution {
  DefaultValidationExecution({
    required this.validationCoordination,
    required this.fieldRegistry,
    required this.stateCalculation,
  });

  final ValidationCoordination validationCoordination;
  final FieldRegistry fieldRegistry;
  final StateCalculation stateCalculation;

  @override
  TypedFormState validateFieldImmediately({
    required String fieldName,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Use orchestrator to validate field existence
    validationCoordination.coordinateFieldValidation(
      fieldName: fieldName,
      value: currentValues[fieldName],
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    final value = currentValues[fieldName];
    final validator = fieldRegistry.validators[fieldName];

    if (validator != null) {
      final error = stateCalculation.validateField(
        validator: validator,
        value: value,
        context: context,
      );

      final newErrors = Map<String, String>.from(currentErrors);
      if (error != null) {
        newErrors[fieldName] = error;
      } else {
        newErrors.remove(fieldName);
      }

      final overallValid = stateCalculation.computeOverallValidity(
        values: currentValues,
        validators: fieldRegistry.validators,
        touchedFields: fieldRegistry.touchedFields,
        context: context,
      );

      return TypedFormState(
        values: currentValues,
        errors: newErrors,
        isValid: overallValid,
        validationStrategy:
            ValidationStrategy.realTimeOnly, // This will be overridden
        fieldTypes: fieldRegistry.fieldTypes,
      );
    }

    // Return current state if no validator
    return TypedFormState(
      values: currentValues,
      errors: currentErrors,
      isValid: false,
      validationStrategy:
          ValidationStrategy.realTimeOnly, // This will be overridden
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  @override
  TypedFormState updateFieldValidators<T>({
    required String fieldName,
    required List<Validator<T>> validators,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Use orchestrator to validate field existence
    validationCoordination.coordinateValidatorUpdate(
      fieldName: fieldName,
      validators: validators,
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    // Update field validators using the field manager
    fieldRegistry.updateFieldValidators<T>(fieldName, validators);

    // Re-validate all fields with the new rules to update errors and form validity
    final newErrors = stateCalculation.validateFields(
      values: currentValues,
      validators: fieldRegistry.validators,
      context: context,
    );
    final newIsValid = stateCalculation.computeOverallValidity(
      values: currentValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return TypedFormState(
      values: currentValues,
      errors: newErrors,
      isValid: newIsValid,
      validationStrategy:
          ValidationStrategy.realTimeOnly, // This will be overridden
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  @override
  TypedFormState validateForm({
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  }) {
    final newErrors = stateCalculation.validateFields(
      values: currentValues,
      validators: fieldRegistry.validators,
      context: context,
    );
    final isValid = stateCalculation.computeOverallValidity(
      values: currentValues,
      validators: fieldRegistry.validators,
      touchedFields: fieldRegistry.touchedFields,
      context: context,
    );

    return TypedFormState(
      values: currentValues,
      errors: newErrors,
      isValid: isValid,
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  @override
  TypedFormState touchAllFields({
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  }) {
    // Mark all fields as touched
    fieldRegistry.touchedFieldsService.markAllFieldsAsTouched();

    // Validate all fields
    final newErrors = stateCalculation.validateFields(
      values: currentValues,
      validators: fieldRegistry.validators,
      context: context,
    );

    return TypedFormState(
      values: currentValues,
      errors: newErrors,
      isValid: stateCalculation.computeOverallValidity(
        values: currentValues,
        validators: fieldRegistry.validators,
        touchedFields: fieldRegistry.touchedFields,
        context: context,
      ),
      validationStrategy: validationStrategy,
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }
}
