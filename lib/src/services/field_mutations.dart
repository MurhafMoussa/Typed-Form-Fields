import 'package:flutter/widgets.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';

/// Service responsible for handling field update operations
abstract class FieldMutations {
  /// Update a single field with validation
  TypedFormState updateField<T>({
    required String fieldName,
    required T? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  });

  /// Update a single field with debounced validation
  void updateFieldWithDebounce<T>({
    required String fieldName,
    required T? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required Function(TypedFormState) onStateComputed,
  });

  /// Update multiple fields at once
  TypedFormState updateFields<T>({
    required Map<String, T?> fieldValues,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  });
}

/// Default implementation of FieldMutations
class DefaultFieldMutations implements FieldMutations {
  DefaultFieldMutations({
    required this.validationCoordination,
    required this.fieldRegistry,
    required this.stateCalculation,
  });

  final ValidationCoordination validationCoordination;
  final FieldRegistry fieldRegistry;
  final StateCalculation stateCalculation;

  @override
  TypedFormState updateField<T>({
    required String fieldName,
    required T? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  }) {
    // Use orchestrator to validate field existence and type
    validationCoordination.coordinateFieldValidation(
      fieldName: fieldName,
      value: value,
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    // Mark this field as touched
    fieldRegistry.touchedFieldsService.markFieldAsTouched(fieldName);

    // Compute new state using the state computer
    return stateCalculation.computeFieldUpdateState(
      fieldName: fieldName,
      value: value,
      currentValues: currentValues,
      currentErrors: currentErrors,
      validationStrategy: validationStrategy,
      context: context,
      fieldRegistry: fieldRegistry,
    );
  }

  @override
  void updateFieldWithDebounce<T>({
    required String fieldName,
    required T? value,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
    required Function(TypedFormState) onStateComputed,
  }) {
    // Use orchestrator to validate field existence and type
    validationCoordination.coordinateFieldValidation(
      fieldName: fieldName,
      value: value,
      currentValues: currentValues,
      currentErrors: currentErrors,
      context: context,
    );

    // Mark this field as touched
    fieldRegistry.touchedFieldsService.markFieldAsTouched(fieldName);

    // Compute new state using debounced validation
    stateCalculation.computeFieldUpdateStateWithDebounce(
      fieldName: fieldName,
      value: value,
      currentValues: currentValues,
      currentErrors: currentErrors,
      validationStrategy: validationStrategy,
      context: context,
      fieldRegistry: fieldRegistry,
      onStateComputed: onStateComputed,
    );
  }

  @override
  TypedFormState updateFields<T>({
    required Map<String, T?> fieldValues,
    required Map<String, Object?> currentValues,
    required Map<String, String> currentErrors,
    required ValidationStrategy validationStrategy,
    required BuildContext context,
  }) {
    // Validate each field using orchestrator
    for (final entry in fieldValues.entries) {
      validationCoordination.coordinateFieldValidation(
        fieldName: entry.key,
        value: entry.value,
        currentValues: currentValues,
        currentErrors: currentErrors,
        context: context,
      );
    }

    // Mark fields as touched
    fieldRegistry.touchedFieldsService
        .markFieldsAsTouched(fieldValues.keys.toList());

    // Compute new state using the state computer
    return stateCalculation.computeFieldsUpdateState(
      fieldValues: fieldValues,
      currentValues: currentValues,
      currentErrors: currentErrors,
      validationStrategy: validationStrategy,
      context: context,
      fieldRegistry: fieldRegistry,
    );
  }
}
