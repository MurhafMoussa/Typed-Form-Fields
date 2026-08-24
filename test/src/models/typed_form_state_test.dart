import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/typed_form_state.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/models.dart';

void main() {
  group('TypedFieldState', () {
    test('creates state and returns displayError correctly', () {
      final fieldState = TypedFieldState<String>(
        fieldName: 'email',
        value: 'test@example.com',
        error: 'Invalid email',
        hasError: true,
        isValidating: false,
        updateValue: (_) {},
      );

      expect(fieldState.fieldName, 'email');
      expect(fieldState.value, 'test@example.com');
      expect(fieldState.error, 'Invalid email');
      expect(fieldState.hasError, isTrue);
      expect(fieldState.isValidating, isFalse);
      expect(fieldState.displayError, 'Invalid email');

      final validFieldState = fieldState.copyWith(
        error: null,
        hasError: false,
      );
      expect(validFieldState.displayError, isNull);
    });

    test('copyWith, equality, hashCode, and toString', () {
      final state1 = TypedFieldState<String>(
        fieldName: 'email',
        value: 'test@example.com',
        error: null,
        hasError: false,
        isValidating: true,
        updateValue: (_) {},
      );
      final state2 = TypedFieldState<String>(
        fieldName: 'email',
        value: 'test@example.com',
        error: null,
        hasError: false,
        isValidating: true,
        updateValue: (_) {},
      );

      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.toString(), contains('TypedFieldState<String>'));
      expect(state1.toString(), contains('email'));

      final updated = state1.copyWith(fieldName: 'username');
      expect(updated.fieldName, 'username');
      expect(state1, isNot(equals(updated)));
    });
  });

  group('FormFieldDefinition', () {
    test('copyWith updates properties correctly', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
      );

      final copy1 = def.copyWith(name: 'newEmail');
      expect(copy1.name, 'newEmail');
      expect(copy1.initialValue, 'a@b.com');

      final copy2 = def.copyWith(validators: [], initialValue: 'c@d.com');
      expect(copy2.name, 'email');
      expect(copy2.initialValue, 'c@d.com');
    });

    test('valueType, createValidator, equality, hashCode and toString', () {
      const def1 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
      );
      const def2 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
      );

      expect(def1.valueType, String);
      expect(def1.createValidator(), isNotNull);
      expect(def1, equals(def2));
      expect(def1.hashCode, equals(def2.hashCode));
      expect(def1.toString(), contains('FormFieldDefinition'));
    });
  });

  group('CoreFormState', () {
    late TypedFormState state;

    setUp(() {
      state = const TypedFormState(
        values: {'email': 'test@example.com', 'age': 25, 'name': 'John Doe'},
        errors: {'email': 'Email error', 'age': 'Age error'},
        isValid: false,
        validationStrategy: ValidationStrategy.allFieldsRealTime,
        fieldTypes: {'email': String, 'age': int, 'name': String},
      );
    });

    group('constructor', () {
      test('should create state with provided values', () {
        expect(state.values, {
          'email': 'test@example.com',
          'age': 25,
          'name': 'John Doe',
        });
        expect(state.errors, {'email': 'Email error', 'age': 'Age error'});
        expect(state.isValid, isFalse);
        expect(state.validationStrategy, ValidationStrategy.allFieldsRealTime);
        expect(state.fieldTypes, {'email': String, 'age': int, 'name': String});
        expect(state.validatingFields, isEmpty);
        expect(state.isValidating, isFalse);
      });

      test('should use default validation type when not provided', () {
        const stateWithDefault = TypedFormState(
          values: {'email': 'test@example.com'},
          errors: {},
          isValid: true,
          fieldTypes: {'email': String},
        );

        expect(
          stateWithDefault.validationStrategy,
          ValidationStrategy.realTimeOnly,
        );
      });
    });

    group('initial factory', () {
      test('should create initial state with empty values', () {
        final initialState = TypedFormState.initial();

        expect(initialState.values, isEmpty);
        expect(initialState.errors, isEmpty);
        expect(initialState.isValid, isFalse);
        expect(
            initialState.validationStrategy, ValidationStrategy.realTimeOnly);
        expect(initialState.fieldTypes, isEmpty);
        expect(initialState.validatingFields, isEmpty);
        expect(initialState.isValidating, isFalse);
      });
    });

    group('getValue', () {
      test('should return correct value for existing field', () {
        expect(state.getValue<String>('email'), 'test@example.com');
        expect(state.getValue<int>('age'), 25);
        expect(state.getValue<String>('name'), 'John Doe');
      });

      test('should return null for null value', () {
        final stateWithNull = state.copyWith(
          values: {...state.values, 'email': null},
        );

        expect(stateWithNull.getValue<String>('email'), isNull);
      });

      test('should throw FormFieldError for non-existing field', () {
        expect(
          () => state.getValue<String>('nonExistent'),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should throw FormFieldError for wrong type', () {
        expect(
          () => state.getValue<int>('email'), // email is String, not int
          throwsA(isA<FormFieldError>()),
        );

        expect(
          () => state.getValue<String>('age'), // age is int, not String
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should handle null field type gracefully', () {
        // Create a state with a field that has no type defined
        const stateWithNullType = TypedFormState(
          values: {'email': 'test@example.com'},
          errors: {},
          isValid: false,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          fieldTypes: {}, // No field types defined
        );

        // When field types is empty, getValue should still work but without type checking
        expect(stateWithNullType.getValue<String>('email'), 'test@example.com');
      });
    });

    group('getError', () {
      test('should return error for field with error', () {
        expect(state.getError('email'), 'Email error');
        expect(state.getError('age'), 'Age error');
      });

      test('should return null for field without error', () {
        expect(state.getError('name'), isNull);
      });

      test('should return null for non-existing field', () {
        expect(state.getError('nonExistent'), isNull);
      });
    });

    group('hasError', () {
      test('should return true for field with error', () {
        expect(state.hasError('email'), isTrue);
        expect(state.hasError('age'), isTrue);
      });

      test('should return false for field without error', () {
        expect(state.hasError('name'), isFalse);
      });

      test('should return false for non-existing field', () {
        expect(state.hasError('nonExistent'), isFalse);
      });
    });

    group('copyWith', () {
      test('should create new state with updated values', () {
        final newState = state.copyWith(
          values: {'email': 'new@example.com'},
          isValid: true,
        );

        expect(newState.values['email'], 'new@example.com');
        expect(
          newState.values['age'],
          isNull,
        ); // copyWith replaces the entire values map
        expect(newState.isValid, isTrue);
        expect(newState.errors, state.errors); // Should remain unchanged
      });

      test('should create new state with updated errors', () {
        final newState = state.copyWith(errors: {'email': 'New email error'});

        expect(newState.errors['email'], 'New email error');
        expect(
          newState.errors['age'],
          isNull,
        ); // copyWith replaces the entire errors map
        expect(newState.values, state.values); // Should remain unchanged
      });

      test('should create new state with updated validation type', () {
        final newState = state.copyWith(
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
        );

        expect(newState.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
        expect(newState.values, state.values); // Should remain unchanged
        expect(newState.errors, state.errors); // Should remain unchanged
      });

      test('should create new state with updated field types', () {
        final newState = state.copyWith(
          fieldTypes: {'email': int}, // Change email type to int
        );

        expect(newState.fieldTypes['email'], int);
        expect(
          newState.fieldTypes['age'],
          isNull,
        ); // copyWith replaces the entire fieldTypes map
        expect(newState.values, state.values); // Should remain unchanged
      });

      test('should create new state with updated validating fields', () {
        final newState = state.copyWith(
          validatingFields: {'email'},
        );

        expect(newState.validatingFields, {'email'});
        expect(newState.isValidating, isTrue);
        expect(newState.values, state.values); // Should remain unchanged
      });
    });

    group('equality', () {
      test('should be equal to identical state', () {
        final identicalState = TypedFormState(
          values: state.values,
          errors: state.errors,
          isValid: state.isValid,
          validationStrategy: state.validationStrategy,
          fieldTypes: state.fieldTypes,
          validatingFields: state.validatingFields,
        );

        expect(state, equals(identicalState));
        expect(state.hashCode, equals(identicalState.hashCode));
      });

      test('should compare map and set collections deeply', () {
        final state1 = TypedFormState(
          values: Map<String, Object?>.from({'a': 1, 'b': 'two'}),
          errors: Map<String, String>.from({'a': 'err1'}),
          isValid: true,
          fieldTypes: Map<String, Type>.from({'a': int, 'b': String}),
          validatingFields: Set<String>.from({'a'}),
        );
        final state2 = TypedFormState(
          values: {'a': 1, 'b': 'two'},
          errors: {'a': 'err1'},
          isValid: true,
          fieldTypes: {'a': int, 'b': String},
          validatingFields: {'a'},
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal to different state', () {
        final differentState = state.copyWith(isValid: true);
        final differentValidating = state.copyWith(validatingFields: {'email'});

        expect(state, isNot(equals(differentState)));
        expect(state, isNot(equals(differentValidating)));
      });
    });

    group('toString', () {
      test('should include all properties in string representation', () {
        final stringRepresentation = state.toString();

        expect(stringRepresentation, contains('test@example.com'));
        expect(stringRepresentation, contains('Email error'));
        expect(stringRepresentation, contains('false'));
        expect(stringRepresentation,
            contains('ValidationStrategy.allFieldsRealTime'));
        expect(stringRepresentation, contains('validatingFields: {}'));
      });
    });
  });

  group('validationStrategy', () {
    test('should have correct enum values', () {
      expect(ValidationStrategy.values, [
        ValidationStrategy.onSubmitThenRealTime,
        ValidationStrategy.allFieldsRealTime,
        ValidationStrategy.realTimeOnly,
        ValidationStrategy.disabled,
        ValidationStrategy.onSubmitOnly,
      ]);
    });

    test('should have correct string representation', () {
      expect(ValidationStrategy.onSubmitThenRealTime.toString(),
          'ValidationStrategy.onSubmitThenRealTime');
      expect(ValidationStrategy.allFieldsRealTime.toString(),
          'ValidationStrategy.allFieldsRealTime');
      expect(
        ValidationStrategy.realTimeOnly.toString(),
        'ValidationStrategy.realTimeOnly',
      );
      expect(ValidationStrategy.disabled.toString(),
          'ValidationStrategy.disabled');
      expect(ValidationStrategy.onSubmitOnly.toString(),
          'ValidationStrategy.onSubmitOnly');
    });
  });

  group('FormFieldDefinition', () {
    test('should create field definition with correct properties', () {
      final field = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
      );

      expect(field.name, 'email');
      expect(field.validators, isEmpty);
      expect(field.initialValue, 'test@example.com');
      expect(field.valueType, String);
    });

    test('copyWith should update specified properties', () {
      final field = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
      );

      final updated =
          field.copyWith(name: 'newEmail', initialValue: 'new@example.com');

      expect(updated.name, 'newEmail');
      expect(updated.initialValue, 'new@example.com');
      expect(updated.validators, isEmpty);
    });

    test('equality and hashCode should work deeply', () {
      final field1 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
      );
      final field2 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
      );
      final field3 = field1.copyWith(name: 'username');

      expect(field1, equals(field2));
      expect(field1.hashCode, equals(field2.hashCode));
      expect(field1, isNot(equals(field3)));
    });

    test('toString should include property values', () {
      final field = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
      );

      expect(field.toString(), contains('email'));
      expect(field.toString(), contains('test@example.com'));
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
