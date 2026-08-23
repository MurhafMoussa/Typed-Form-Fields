import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

import 'form_field_registry.dart';
import 'form_touched_tracker.dart';
import 'form_validation_orchestrator.dart';
import 'typed_form_state.dart';
import 'validation_strategy.dart';

export 'typed_form_state.dart';

/// Form cubit with type-safe state access
class TypedFormController extends Cubit<TypedFormState> {
  TypedFormController({
    List<FormFieldDefinition> fields = const [],
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
    Duration asyncDebounceDelay = const Duration(milliseconds: 300),
    void Function(Object error, StackTrace stackTrace, String fieldName)?
        onAsyncValidationError,
  }) : this._internal(
          fields: fields,
          validationStrategy: validationStrategy,
          asyncDebounceDelay: asyncDebounceDelay,
          onAsyncValidationError: onAsyncValidationError,
          registry: FormFieldRegistry(fields),
          touchedTracker: FormTouchedTracker(fields.map((f) => f.name)),
          validator: FormValidator(debounceDelay: asyncDebounceDelay),
        );

  TypedFormController._internal({
    required List<FormFieldDefinition> fields,
    required ValidationStrategy validationStrategy,
    required Duration asyncDebounceDelay,
    required void Function(Object error, StackTrace stackTrace, String fieldName)?
        onAsyncValidationError,
    required FormFieldRegistry registry,
    required FormTouchedTracker touchedTracker,
    required FormValidator validator,
  })  : _asyncDebounceDelay = asyncDebounceDelay,
        _onAsyncValidationError = onAsyncValidationError,
        _validator = validator,
        _orchestrator = FormValidationOrchestrator(
          registry: registry,
          touchedTracker: touchedTracker,
          validator: validator,
          asyncDebounceDelay: asyncDebounceDelay,
          onAsyncValidationError: onAsyncValidationError,
        ),
        super(TypedFormState.initial()) {
    emit(
      TypedFormState(
        values: registry.initialValues,
        errors: const {},
        isValid: validationStrategy.initialValidationState,
        validationStrategy: validationStrategy,
        fieldTypes: registry.fieldTypes,
      ),
    );
  }

  final Duration _asyncDebounceDelay;
  final void Function(Object error, StackTrace stackTrace, String fieldName)?
      _onAsyncValidationError;
  final FormValidator _validator;
  final FormValidationOrchestrator _orchestrator;

  /// The delay before executing asynchronous validators for a field
  Duration get asyncDebounceDelay => _asyncDebounceDelay;

  /// Callback invoked when an uncaught exception occurs during async validation
  void Function(Object error, StackTrace stackTrace, String fieldName)?
      get onAsyncValidationError => _onAsyncValidationError;

  /// Returns map of field names to touched status
  Map<String, bool> get touchedFields => _orchestrator.touchedFields;

  /// Returns map of initial field values when form was created or reset
  Map<String, Object?> get initialValues => _orchestrator.initialValues;

  /// Whether any field value currently differs from its initial value
  bool get isDirty => _orchestrator.isDirty(state.values);

  /// Returns whether a specific field is touched
  bool isTouched(String fieldName) => _orchestrator.isTouched(fieldName);

  /// Type-safe getter for field values
  T? getValue<T>(String fieldName) => state.getValue<T>(fieldName);

  /// Type-safe update method for a single field
  void updateField<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    final newState = _orchestrator.updateField<T>(
      fieldName: fieldName,
      value: value,
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
    );
    _emitIfChanged(newState);
  }

  /// Type-safe update method for a single field with debouncing
  void updateFieldWithDebounce<T>({
    required String fieldName,
    T? value,
    required BuildContext context,
  }) {
    _orchestrator.updateFieldWithDebounce<T>(
      fieldName: fieldName,
      value: value,
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
    );
  }

  /// Updates multiple fields at once with a single state emission
  void updateFields<T>({
    required Map<String, T?> fieldValues,
    required BuildContext context,
  }) {
    final newState = _orchestrator.updateFields<T>(
      fieldValues: fieldValues,
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
    );
    _emitIfChanged(newState);
  }

  /// Call this when you need to change the validation rules for a field based on
  /// other state in your application (e.g., making a field required based on a checkbox).
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    List<AsyncValidator<T>>? asyncValidators,
    required BuildContext context,
  }) {
    final newState = _orchestrator.updateFieldValidators<T>(
      name: name,
      validators: validators,
      asyncValidators: asyncValidators,
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
    );
    _emitIfChanged(newState);
  }

  /// Validates all fields in a named group.
  void validateGroup(
    String groupName, {
    required BuildContext context,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final newState = _orchestrator.validateGroup(
      groupName,
      context: context,
      state: state,
      onValidationPass: onValidationPass,
      onValidationFail: onValidationFail,
    );
    _emitIfChanged(newState);
  }

  /// Validates a specific subset of fields by name.
  void validateFields(
    List<String> fieldNames, {
    required BuildContext context,
    VoidCallback? onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    final newState = _orchestrator.validateFields(
      fieldNames,
      context: context,
      state: state,
      onValidationPass: onValidationPass,
      onValidationFail: onValidationFail,
    );
    _emitIfChanged(newState);
  }

  /// Passively checks validity of all fields in [groupName].
  bool isGroupValid(
    String groupName, {
    required BuildContext context,
  }) {
    return _orchestrator.isGroupValid(
      groupName,
      context: context,
      state: state,
    );
  }

  /// Passively checks validity of a list of fields by name.
  bool areFieldsValid(
    List<String> fieldNames, {
    required BuildContext context,
  }) {
    return _orchestrator.areFieldsValid(
      fieldNames,
      context: context,
      state: state,
    );
  }

  /// Marks all fields in [groupName] as touched and updates form state.
  void touchGroup(
    String groupName, {
    required BuildContext context,
  }) {
    final newState = _orchestrator.touchGroup(
      groupName,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Sets a new validation type for the form
  void setValidationStrategy(ValidationStrategy validationStrategy) {
    _emitIfChanged(state.copyWith(validationStrategy: validationStrategy));
  }

  /// Validates the entire form
  FutureOr<void> validateForm(
    BuildContext context, {
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    return _orchestrator.validateForm(
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
      onValidationPass: onValidationPass,
      onValidationFail: onValidationFail,
    );
  }

  /// Validates a field immediately (no debouncing)
  void validateFieldImmediately({
    required String fieldName,
    required BuildContext context,
  }) {
    final newState = _orchestrator.validateFieldImmediately(
      fieldName: fieldName,
      context: context,
      state: state,
      getState: () => state,
      emitState: _emitIfChanged,
    );
    _emitIfChanged(newState);
  }

  /// Resets the form to its initial state
  void resetForm() {
    final newState = _orchestrator.resetForm(state: state);
    _emitIfChanged(newState);
  }

  /// Marks all fields as touched and validates them
  void touchAllFields(BuildContext context) {
    final newState = _orchestrator.touchAllFields(
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Manually set an error for a specific field
  void updateError({
    required String fieldName,
    String? errorMessage,
    required BuildContext context,
  }) {
    final newState = _orchestrator.updateError(
      fieldName: fieldName,
      errorMessage: errorMessage,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Manually set multiple errors at once
  void updateErrors({
    required Map<String, String?> errors,
    required BuildContext context,
  }) {
    final newState = _orchestrator.updateErrors(
      errors: errors,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Add a single field to the form dynamically
  void addField<T>({
    required FormFieldDefinition<T> field,
    required BuildContext context,
  }) {
    final newState = _orchestrator.addField<T>(
      field: field,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Add multiple fields to the form dynamically
  void addFields({
    required List<FormFieldDefinition> fields,
    required BuildContext context,
  }) {
    final newState = _orchestrator.addFields(
      fields: fields,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Remove a field from the form dynamically
  void removeField(String fieldName, {required BuildContext context}) {
    final newState = _orchestrator.removeField(
      fieldName,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Remove multiple fields from the form dynamically
  void removeFields(List<String> fieldNames, {required BuildContext context}) {
    final newState = _orchestrator.removeFields(
      fieldNames,
      context: context,
      state: state,
    );
    _emitIfChanged(newState);
  }

  /// Emits new state only if it's different from the current state
  void _emitIfChanged(TypedFormState newState) {
    if (newState != state) {
      emit(newState);
    }
  }

  /// Disposes of all resources
  @override
  Future<void> close() {
    _validator.dispose();
    return super.close();
  }
}
