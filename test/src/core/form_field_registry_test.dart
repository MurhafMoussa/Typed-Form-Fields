import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/form_field_registry.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

class TestValidator<T> implements Validator<T> {
  const TestValidator(this.errorMessage);
  final String? errorMessage;

  @override
  String? validate(T? value, dynamic context) => errorMessage;
}

void main() {
  group('FormFieldRegistry', () {
    late FormFieldDefinition<String> usernameField;
    late FormFieldDefinition<int> ageField;

    setUp(() {
      usernameField = const FormFieldDefinition<String>(
        name: 'username',
        validators: [TestValidator('Required')],
        initialValue: 'John',
      );
      ageField = const FormFieldDefinition<int>(
        name: 'age',
        validators: [],
        initialValue: 20,
      );
    });

    group('Initialization and Getters', () {
      test('initializes empty registry by default', () {
        final registry = FormFieldRegistry();
        expect(registry.fields, isEmpty);
        expect(registry.validators, isEmpty);
        expect(registry.fieldTypes, isEmpty);
        expect(registry.initialValues, isEmpty);
        expect(registry.availableFields, isEmpty);
      });

      test('initializes registry with provided fields', () {
        final registry = FormFieldRegistry([usernameField, ageField]);

        expect(registry.fields, equals([usernameField, ageField]));
        expect(registry.availableFields, equals(['username', 'age']));
        expect(registry.fieldTypes, equals({'username': String, 'age': int}));
        expect(registry.initialValues, equals({'username': 'John', 'age': 20}));
        expect(registry.validators.keys, containsAll(['username', 'age']));
      });

      test('views return unmodifiable collections', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(() => registry.fields.add(ageField), throwsUnsupportedError);
        expect(
          () => registry.validators['test'] = const TestValidator('err'),
          throwsUnsupportedError,
        );
      });
    });

    group('Lookups', () {
      test('containsField returns true for existing field and false for non-existent', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(registry.containsField('username'), isTrue);
        expect(registry.containsField('age'), isFalse);
      });

      test('getFieldType returns correct type or null', () {
        final registry = FormFieldRegistry([usernameField, ageField]);
        expect(registry.getFieldType('username'), equals(String));
        expect(registry.getFieldType('age'), equals(int));
        expect(registry.getFieldType('unknown'), isNull);
      });

      test('getValidator returns validator instance or null', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(registry.getValidator('username'), isNotNull);
        expect(registry.getValidator('unknown'), isNull);
      });

      test('getField returns FormFieldDefinition or null', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(registry.getField('username'), equals(usernameField));
        expect(registry.getField('unknown'), isNull);
      });
    });

    group('Exception checks', () {
      test('checkFieldExists does not throw when field exists', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(
          () => registry.checkFieldExists('username', currentValues: {'username': 'John'}),
          returnsNormally,
        );
      });

      test('checkFieldExists throws FormFieldError.fieldNotFound when field missing', () {
        final registry = FormFieldRegistry([usernameField]);
        final currentValues = {'username': 'John'};

        expect(
          () => registry.checkFieldExists('missingField', currentValues: currentValues),
          throwsA(
            isA<FormFieldError>().having(
              (e) => e.fieldName,
              'fieldName',
              'missingField',
            ),
          ),
        );
      });

      test('checkFieldDoesNotExist passes when field is absent and throws when present', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(() => registry.checkFieldDoesNotExist('age'), returnsNormally);
        expect(
          () => registry.checkFieldDoesNotExist('username'),
          throwsA(
            isA<FormFieldError>().having(
              (e) => e.fieldName,
              'fieldName',
              'username',
            ),
          ),
        );
      });

      test('checkFieldsDoNotExist validates multiple fields atomically', () {
        final registry = FormFieldRegistry([usernameField]);
        final newFields = [
          const FormFieldDefinition<String>(name: 'email', validators: []),
          ageField,
        ];

        expect(() => registry.checkFieldsDoNotExist(newFields), returnsNormally);

        final duplicateFields = [
          const FormFieldDefinition<String>(name: 'email', validators: []),
          usernameField,
        ];
        expect(
          () => registry.checkFieldsDoNotExist(duplicateFields),
          throwsA(
            isA<FormFieldError>().having(
              (e) => e.fieldName,
              'fieldName',
              'username',
            ),
          ),
        );
      });
    });

    group('Dynamic Mutations', () {
      test('addField adds a field and its validator', () {
        final registry = FormFieldRegistry();
        registry.addField(usernameField);

        expect(registry.containsField('username'), isTrue);
        expect(registry.getFieldType('username'), equals(String));
        expect(registry.getValidator('username'), isNotNull);
      });

      test('addField throws if field already exists', () {
        final registry = FormFieldRegistry([usernameField]);
        expect(
          () => registry.addField(usernameField),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('addFields adds multiple fields atomically', () {
        final registry = FormFieldRegistry();
        registry.addFields([usernameField, ageField]);

        expect(registry.availableFields, equals(['username', 'age']));
      });

      test('addFields fails atomically without partial addition if any field exists', () {
        final registry = FormFieldRegistry([usernameField]);
        final newFields = [
          const FormFieldDefinition<String>(name: 'email', validators: []),
          usernameField,
        ];

        expect(
          () => registry.addFields(newFields),
          throwsA(isA<FormFieldError>()),
        );
        expect(registry.containsField('email'), isFalse);
      });

      test('updateFieldValidators updates field definition and validator', () {
        final registry = FormFieldRegistry([usernameField]);
        const newValidators = [TestValidator<String>('New Error')];

        registry.updateFieldValidators<String>(
          name: 'username',
          validators: newValidators,
          currentValues: {'username': 'John'},
        );

        final updatedField = registry.getField('username');
        expect(updatedField?.validators, equals(newValidators));
        expect(updatedField?.initialValue, equals('John'));
      });

      test('updateFieldValidators throws if field does not exist', () {
        final registry = FormFieldRegistry();
        expect(
          () => registry.updateFieldValidators<String>(
            name: 'missing',
            validators: [],
            currentValues: {},
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('removeField removes field and validator', () {
        final registry = FormFieldRegistry([usernameField, ageField]);
        registry.removeField('username', currentValues: {'username': 'John', 'age': 20});

        expect(registry.containsField('username'), isFalse);
        expect(registry.getValidator('username'), isNull);
        expect(registry.availableFields, equals(['age']));
      });

      test('removeField throws if field does not exist', () {
        final registry = FormFieldRegistry();
        expect(
          () => registry.removeField('missing', currentValues: {}),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('removeFields removes multiple fields atomically', () {
        final registry = FormFieldRegistry([usernameField, ageField]);
        registry.removeFields(['username', 'age'], currentValues: {'username': 'John', 'age': 20});

        expect(registry.availableFields, isEmpty);
      });

      test('removeFields throws if any requested field is missing before removing any', () {
        final registry = FormFieldRegistry([usernameField, ageField]);
        expect(
          () => registry.removeFields(['username', 'missing'], currentValues: {}),
          throwsA(isA<FormFieldError>()),
        );
        expect(registry.containsField('username'), isTrue);
      });
    });
  });
}
