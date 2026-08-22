import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

import 'form_errors.dart';

/// Internal helper class that encapsulates form field definition storage,
/// validator management, type lookups, and existence validation.
class FormFieldRegistry {
  FormFieldRegistry([List<FormFieldDefinition> fields = const []])
      : _fields = List<FormFieldDefinition>.from(fields),
        _validators = {
          for (final field in fields) field.name: field.createValidator(),
        };

  final List<FormFieldDefinition> _fields;
  final Map<String, Validator> _validators;

  /// Unmodifiable view of registered field definitions.
  List<FormFieldDefinition> get fields => List.unmodifiable(_fields);

  /// Map of field names to their active validators.
  Map<String, Validator> get validators => Map.unmodifiable(_validators);

  /// Map of field names to their registered value types.
  Map<String, Type> get fieldTypes => {
        for (final field in _fields) field.name: field.valueType,
      };

  /// Map of field names to their initial values.
  Map<String, Object?> get initialValues => {
        for (final field in _fields) field.name: field.initialValue,
      };

  /// List of registered field names.
  List<String> get availableFields => _fields.map((f) => f.name).toList();

  /// Checks whether a field with [fieldName] exists in the registry.
  bool containsField(String fieldName) =>
      _fields.any((field) => field.name == fieldName);

  /// Returns the registered value [Type] for [fieldName], or `null` if not found.
  Type? getFieldType(String fieldName) {
    for (final field in _fields) {
      if (field.name == fieldName) return field.valueType;
    }
    return null;
  }

  /// Returns the [Validator] registered for [fieldName], or `null` if not found.
  Validator? getValidator(String fieldName) => _validators[fieldName];

  /// Returns the [FormFieldDefinition] for [fieldName], or `null` if not found.
  FormFieldDefinition? getField(String fieldName) {
    for (final field in _fields) {
      if (field.name == fieldName) return field;
    }
    return null;
  }

  /// Throws [FormFieldError.fieldNotFound] if [fieldName] is not in the registry.
  void checkFieldExists(
    String fieldName, {
    required Map<String, Object?> currentValues,
  }) {
    if (!containsField(fieldName)) {
      throw FormFieldError.fieldNotFound(
        fieldName: fieldName,
        availableFields: availableFields,
        fieldTypes: fieldTypes,
        currentValues: currentValues,
      );
    }
  }

  /// Throws [FormFieldError.fieldAlreadyExists] if [fieldName] already exists.
  void checkFieldDoesNotExist(String fieldName) {
    if (containsField(fieldName)) {
      throw FormFieldError.fieldAlreadyExists(fieldName: fieldName);
    }
  }

  /// Throws [FormFieldError.fieldAlreadyExists] if any field in [fields] already exists.
  void checkFieldsDoNotExist(List<FormFieldDefinition> fields) {
    for (final field in fields) {
      if (containsField(field.name)) {
        throw FormFieldError.fieldAlreadyExists(fieldName: field.name);
      }
    }
  }

  /// Adds a single field definition to the registry.
  void addField<T>(FormFieldDefinition<T> field) {
    checkFieldDoesNotExist(field.name);
    _fields.add(field);
    _validators[field.name] = field.createValidator();
  }

  /// Adds multiple field definitions to the registry atomically.
  void addFields(List<FormFieldDefinition> fields) {
    checkFieldsDoNotExist(fields);
    for (final field in fields) {
      _fields.add(field);
      _validators[field.name] = field.createValidator();
    }
  }

  /// Updates the validators for an existing field.
  void updateFieldValidators<T>({
    required String name,
    required List<Validator<T>> validators,
    required Map<String, Object?> currentValues,
  }) {
    checkFieldExists(name, currentValues: currentValues);
    final fieldIndex = _fields.indexWhere((f) => f.name == name);
    if (fieldIndex != -1) {
      final existingField = _fields[fieldIndex];
      final updatedField = FormFieldDefinition<T>(
        name: name,
        validators: validators,
        initialValue: existingField.initialValue as T?,
      );
      _fields[fieldIndex] = updatedField;
      _validators[name] = updatedField.createValidator();
    }
  }

  /// Removes a single field from the registry.
  void removeField(
    String fieldName, {
    required Map<String, Object?> currentValues,
  }) {
    checkFieldExists(fieldName, currentValues: currentValues);
    _fields.removeWhere((field) => field.name == fieldName);
    _validators.remove(fieldName);
  }

  /// Removes multiple fields from the registry atomically.
  void removeFields(
    List<String> fieldNames, {
    required Map<String, Object?> currentValues,
  }) {
    for (final fieldName in fieldNames) {
      checkFieldExists(fieldName, currentValues: currentValues);
    }
    for (final fieldName in fieldNames) {
      _fields.removeWhere((field) => field.name == fieldName);
      _validators.remove(fieldName);
    }
  }
}
