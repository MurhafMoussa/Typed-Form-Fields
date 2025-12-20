import 'package:typed_form_fields/src/models/models.dart';
import 'package:typed_form_fields/src/services/field_tracking.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

/// Service responsible for managing form fields and their operations.
/// This service encapsulates all field-related functionality and provides
/// a clean interface for field management operations.
abstract class FieldRegistry {
  /// Get the list of fields
  List<FormFieldDefinition> get fields;

  /// Get the validators map
  Map<String, Validator> get validators;

  /// Get the touched fields service
  FieldTracking get touchedFieldsService;

  /// Get the touched fields map (delegated to touchedFieldsService)
  Map<String, bool> get touchedFields;

  /// Get the list of field names
  List<String> get fieldNames;

  /// Get the map of field types
  Map<String, Type> get fieldTypes;

  /// Check if a field exists
  bool fieldExists(String fieldName);

  /// Get the expected type for a field
  Type? getFieldType(String fieldName);

  /// Get initial values for all fields
  Map<String, Object?> getInitialValues();

  /// Add a new field to the form
  void addField(FormFieldDefinition field);

  /// Remove a field from the form
  void removeField(String fieldName);

  /// Update field validators
  void updateFieldValidators<T>(
      String fieldName, List<Validator<T>> validators);
}

/// Default implementation of FieldRegistry
class DefaultFieldRegistry implements FieldRegistry {
  late final List<FormFieldDefinition> _fields;
  late final Map<String, Validator> _validators;
  late final FieldTracking _fieldTracking;
  DefaultFieldRegistry({
    List<FormFieldDefinition> fields = const [],
    FieldTracking? touchedFieldsService,
  }) {
    _validators = {};
    _fields = fields;

    // Initialize touched fields service with field names
    final fieldNames = fields.map((field) => field.name).toList();
    _fieldTracking =
        touchedFieldsService ?? DefaultFieldTracking(fieldNames: fieldNames);

    // Initialize validators
    for (final field in fields) {
      _validators[field.name] = field.createValidator();
    }
  }

  @override
  List<FormFieldDefinition> get fields => _fields;

  @override
  Map<String, Validator> get validators => _validators;

  @override
  FieldTracking get touchedFieldsService => _fieldTracking;

  @override
  Map<String, bool> get touchedFields => _fieldTracking.touchedFields;

  @override
  List<String> get fieldNames => _fields.map((field) => field.name).toList();

  @override
  Map<String, Type> get fieldTypes => {
        for (final field in _fields) field.name: field.valueType,
      };

  @override
  bool fieldExists(String fieldName) {
    return _fields.any((field) => field.name == fieldName);
  }

  @override
  Type? getFieldType(String fieldName) {
    final field = _fields.firstWhere(
      (field) => field.name == fieldName,
      orElse: () => throw ArgumentError('Field "$fieldName" does not exist'),
    );
    return field.valueType;
  }

  @override
  Map<String, Object?> getInitialValues() {
    final values = <String, Object?>{};
    for (final field in _fields) {
      values[field.name] = field.initialValue;
    }
    return values;
  }

  @override
  void addField(FormFieldDefinition field) {
    _fields.add(field);
    _validators[field.name] = field.createValidator();
    _fieldTracking.initializeFieldTouchedState(field.name);
  }

  @override
  void removeField(String fieldName) {
    _fields.removeWhere((field) => field.name == fieldName);
    _validators.remove(fieldName);
    _fieldTracking.removeFieldTouchedState(fieldName);
  }

  @override
  void updateFieldValidators<T>(
      String fieldName, List<Validator<T>> validators) {
    if (!_validators.containsKey(fieldName)) {
      throw ArgumentError('Field "$fieldName" does not exist');
    }

    // Find the field and update its validators
    final fieldIndex = _fields.indexWhere((field) => field.name == fieldName);
    if (fieldIndex != -1) {
      final field = _fields[fieldIndex];
      final updatedField = FormFieldDefinition<T>(
        name: fieldName,
        validators: validators,
        initialValue: field.initialValue as T?,
      );
      _fields[fieldIndex] = updatedField;
      _validators[fieldName] = updatedField.createValidator();
    }
  }
}
