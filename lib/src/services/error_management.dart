import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';

/// Service responsible for handling form error operations
abstract class ErrorManagement {
  /// Update a single field error
  TypedFormState updateError({
    required String fieldName,
    required String? errorMessage,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });

  /// Update multiple field errors
  TypedFormState updateErrors({
    required Map<String, String?> errors,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  });
}

/// Default implementation of ErrorManagement
class DefaultErrorManagement implements ErrorManagement {
  DefaultErrorManagement({
    required this.validationCoordination,
    required this.fieldRegistry,
    required this.stateCalculation,
  });

  final ValidationCoordination validationCoordination;
  final FieldRegistry fieldRegistry;
  final StateCalculation stateCalculation;

  @override
  TypedFormState updateError({
    required String fieldName,
    required String? errorMessage,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Use orchestrator to handle error update
    final orchestrationResult = validationCoordination.coordinateErrorUpdate(
      fieldName: fieldName,
      errorMessage: errorMessage,
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    // Mark field as touched since we're manually validating it
    fieldRegistry.touchedFieldsService.markFieldAsTouched(fieldName);

    // Compute overall validity based on current values and new errors
    final overallValid = stateCalculation.computeOverallValidityWithErrors(
      values: currentValues,
      errors: orchestrationResult.newErrors,
      touchedFields: fieldRegistry.touchedFields,
      validators: fieldRegistry.validators,
      context: context,
    );

    return TypedFormState(
      values: currentValues,
      errors: orchestrationResult.newErrors,
      isValid: overallValid,
      validationStrategy:
          ValidationStrategy.realTimeOnly, // This will be overridden
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }

  @override
  TypedFormState updateErrors({
    required Map<String, String?> errors,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required BuildContext context,
  }) {
    // Use orchestrator to handle multiple error updates
    final orchestrationResult =
        validationCoordination.coordinateMultipleErrorUpdates(
      errors: errors,
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    // Mark fields as touched since we're manually validating them
    for (final fieldName in errors.keys) {
      fieldRegistry.touchedFieldsService.markFieldAsTouched(fieldName);
    }

    // Compute overall validity based on current values and new errors
    final overallValid = stateCalculation.computeOverallValidityWithErrors(
      values: currentValues,
      errors: orchestrationResult.newErrors,
      touchedFields: fieldRegistry.touchedFields,
      validators: fieldRegistry.validators,
      context: context,
    );

    return TypedFormState(
      values: currentValues,
      errors: orchestrationResult.newErrors,
      isValid: overallValid,
      validationStrategy:
          ValidationStrategy.realTimeOnly, // This will be overridden
      fieldTypes: fieldRegistry.fieldTypes,
    );
  }
}
