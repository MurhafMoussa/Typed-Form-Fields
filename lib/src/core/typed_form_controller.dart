import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/services/error_management.dart';
import 'package:typed_form_fields/src/services/field_lifecycle.dart';
import 'package:typed_form_fields/src/services/field_mutations.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/submission_handling.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';
import 'package:typed_form_fields/src/services/validation_execution.dart';
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
    FieldRegistry? fieldService,
    ValidationCoordination? validationOrchestrator,
    SubmissionHandling? submissionService,
    FieldLifecycle? fieldManagementService,
    FieldMutations? fieldUpdateService,
    ValidationExecution? validationService,
    ErrorManagement? errorService,
  }) : super(TypedFormState.initial()) {
    _fieldService = fieldService ?? DefaultFieldRegistry(fields: fields);
    _stateComputer = StateCalculation();
    _validationOrchestrator = validationOrchestrator ??
        DefaultValidationCoordination(fieldRegistry: _fieldService);
    _submissionService = submissionService ?? DefaultSubmissionHandling();
    _fieldManagementService = fieldManagementService ??
        DefaultFieldLifecycle(
          stateCalculation: _stateComputer,
          fieldRegistry: _fieldService,
        );
    _fieldUpdateService = fieldUpdateService ??
        DefaultFieldMutations(
          validationCoordination: _validationOrchestrator,
          fieldRegistry: _fieldService,
          stateCalculation: _stateComputer,
        );
    _validationService = validationService ??
        DefaultValidationExecution(
          validationCoordination: _validationOrchestrator,
          fieldRegistry: _fieldService,
          stateCalculation: _stateComputer,
        );
    _errorService = errorService ??
        DefaultErrorManagement(
          validationCoordination: _validationOrchestrator,
          fieldRegistry: _fieldService,
          stateCalculation: _stateComputer,
        );

    // Single emit call with all initial values
    emit(
      _validationOrchestrator.getInitialValidationState(
        validationStrategy: validationStrategy,
      ),
    );
  }

  late final FieldRegistry _fieldService;
  late final StateCalculation _stateComputer;
  late final ValidationCoordination _validationOrchestrator;
  late final SubmissionHandling _submissionService;
  late final FieldLifecycle _fieldManagementService;
  late final FieldMutations _fieldUpdateService;
  late final ValidationExecution _validationService;
  late final ErrorManagement _errorService;

  /// Type-safe getter for field values
  T? getValue<T>(String fieldName) => state.getValue<T>(fieldName);

  /// Type-safe update method for a single field
  void updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    final newState = _fieldUpdateService.updateField<T>(
      fieldName: fieldName,
      value: value,
      currentValues: state.values,
      currentErrors: state.errors,
      validationStrategy: state.validationStrategy,
      context: context,
    );

    _emitIfChanged(newState);
  }

  /// Type-safe update method for a single field with debouncing
  void updateFieldWithDebounce<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    _fieldUpdateService.updateFieldWithDebounce<T>(
      fieldName: fieldName,
      value: value,
      currentValues: state.values,
      currentErrors: state.errors,
      validationStrategy: state.validationStrategy,
      context: context,
      onStateComputed: (newState) {
        _emitIfChanged(newState);
      },
    );
  }

  /// Updates multiple fields at once with a single state emission
  void updateFields<T>({
    required Map<String, T?> fieldValues,
    required BuildContext context,
  }) {
    final newState = _fieldUpdateService.updateFields<T>(
      fieldValues: fieldValues,
      currentValues: state.values,
      currentErrors: state.errors,
      validationStrategy: state.validationStrategy,
      context: context,
    );

    _emitIfChanged(newState);
  }

  /// Call this when you need to change the validation rules for a field based on
  /// other state in your application (e.g., making a field required based on a checkbox).
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    required BuildContext context,
  }) {
    final newState = _validationService.updateFieldValidators<T>(
      fieldName: name,
      validators: validators,
      currentValues: state.values,
      currentErrors: state.errors,
      context: context,
    );

    // Emit the new state with updated errors and validity
    _emitIfChanged(state.copyWith(
      errors: newState.errors,
      isValid: newState.isValid,
    ));
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
    // Use orchestrator to determine validation behavior
    final orchestrationResult =
        _validationOrchestrator.coordinateFormSubmission(
      strategy: state.validationStrategy,
      currentValues: state.values,
      currentErrors: state.errors,
      context: context,
      onValidationPass: onValidationPass,
      onValidationFail: onValidationFail,
    );

    if (orchestrationResult.shouldValidate) {
      final newErrors = _stateComputer.validateFields(
        values: state.values,
        validators: _fieldService.validators,
        context: context,
      );
      final isValid = _stateComputer.computeOverallValidity(
        values: state.values,
        validators: _fieldService.validators,
        touchedFields: _fieldService.touchedFields,
        context: context,
      );
      _emitIfChanged(
        state.copyWith(errors: newErrors, isValid: isValid),
      );

      // Use submission service to handle form submission workflow
      _submissionService.submitForm(
        currentValues: state.values,
        currentErrors: newErrors,
        context: context,
        onValidationPass: onValidationPass,
        onValidationFail: onValidationFail,
      );

      // Handle strategy switching based on orchestrator result
      if (orchestrationResult.shouldSwitchStrategy &&
          orchestrationResult.newStrategy != null) {
        setValidationStrategy(orchestrationResult.newStrategy!);
      }
    } else {
      // If validation is disabled, use submission service with validation disabled
      _submissionService.submitFormWithValidationDisabled(
        currentValues: state.values,
        context: context,
        onValidationPass: onValidationPass,
        onValidationFail: onValidationFail,
      );
    }
  }

  /// Validates a field immediately (no debouncing)
  ///
  /// This is useful for blur events, form submission, etc.
  void validateFieldImmediately({
    required String fieldName,
    required BuildContext context,
  }) {
    final newState = _validationService.validateFieldImmediately(
      fieldName: fieldName,
      currentValues: state.values,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      errors: newState.errors,
      isValid: newState.isValid,
    ));
  }

  /// Resets the form to its initial state
  void resetForm() {
    // Reset all fields to their initial values
    _fieldService.touchedFieldsService.resetTouchedFields();

    // Reset to initial values
    final resetValues = _fieldService.getInitialValues();

    _emitIfChanged(
      state.copyWith(values: resetValues, errors: {}, isValid: false),
    );
  }

  /// Marks all fields as touched and validates them
  void touchAllFields(BuildContext context) {
    final newState = _validationService.touchAllFields(
      currentValues: state.values,
      currentErrors: state.errors,
      validationStrategy: state.validationStrategy,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      errors: newState.errors,
      isValid: newState.isValid,
    ));
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
    final newState = _errorService.updateError(
      fieldName: fieldName,
      errorMessage: errorMessage,
      currentValues: state.values,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      errors: newState.errors,
      isValid: newState.isValid,
    ));
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
    final newState = _errorService.updateErrors(
      errors: errors,
      currentValues: state.values,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      errors: newState.errors,
      isValid: newState.isValid,
    ));
  }

  /// Add a single field to the form dynamically
  void addField<T>({
    required FormFieldDefinition<T> field,
    required BuildContext context,
  }) {
    // Use field management service to handle field addition
    final result = _fieldManagementService.addField<T>(
      field: field,
      currentValues: state.values,
      currentFieldTypes: state.fieldTypes,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      values: result.newValues,
      fieldTypes: result.newFieldTypes,
      errors: result.newErrors,
      isValid: result.newIsValid,
    ));
  }

  /// Add multiple fields to the form dynamically
  void addFields({
    required List<FormFieldDefinition> fields,
    required BuildContext context,
  }) {
    // Use field management service to handle multiple field addition
    final result = _fieldManagementService.addFields(
      fields: fields,
      currentValues: state.values,
      currentFieldTypes: state.fieldTypes,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      values: result.newValues,
      fieldTypes: result.newFieldTypes,
      errors: result.newErrors,
      isValid: result.newIsValid,
    ));
  }

  /// Remove a field from the form dynamically
  void removeField(String fieldName, {required BuildContext context}) {
    // Use field management service to handle field removal
    final result = _fieldManagementService.removeField(
      fieldName: fieldName,
      currentValues: state.values,
      currentFieldTypes: state.fieldTypes,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      values: result.newValues,
      fieldTypes: result.newFieldTypes,
      errors: result.newErrors,
      isValid: result.newIsValid,
    ));
  }

  /// Remove multiple fields from the form dynamically
  void removeFields(List<String> fieldNames, {required BuildContext context}) {
    // Use field management service to handle multiple field removal
    final result = _fieldManagementService.removeFields(
      fieldNames: fieldNames,
      currentValues: state.values,
      currentFieldTypes: state.fieldTypes,
      currentErrors: state.errors,
      context: context,
    );

    _emitIfChanged(state.copyWith(
      values: result.newValues,
      fieldTypes: result.newFieldTypes,
      errors: result.newErrors,
      isValid: result.newIsValid,
    ));
  }

  /// Disposes of all resources
  @override
  Future<void> close() {
    _stateComputer.validationDebounce.dispose();
    // Service container removed - no disposal needed
    return super.close();
  }
}
