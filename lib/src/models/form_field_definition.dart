import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:typed_form_fields/src/validators/composite_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

@immutable
class FormFieldDefinition<T> {
  const FormFieldDefinition({
    required this.name,
    required this.validators,
    this.initialValue,
  });

  final String name;
  final List<Validator<T>> validators;
  final T? initialValue;

  /// Get the runtime type of the field value
  Type get valueType => T;

  /// Create a validator for this field
  Validator<T> createValidator() => CompositeValidator<T>(validators);

  FormFieldDefinition<T> copyWith({
    String? name,
    List<Validator<T>>? validators,
    T? initialValue,
  }) {
    return FormFieldDefinition<T>(
      name: name ?? this.name,
      validators: validators ?? this.validators,
      initialValue: initialValue ?? this.initialValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormFieldDefinition<T>) return false;
    return name == other.name &&
        initialValue == other.initialValue &&
        const ListEquality<dynamic>().equals(validators, other.validators);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      initialValue,
      const ListEquality<dynamic>().hash(validators),
    );
  }

  @override
  String toString() {
    return 'FormFieldDefinition<$T>(name: $name, validators: $validators, initialValue: $initialValue)';
  }
}
