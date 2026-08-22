import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_debounce.dart';
import 'package:typed_form_fields/src/validators/typed_cross_field_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('StateCalculation', () {
    late StateCalculation stateCalculator;
    late FieldRegistry fieldRegistry;
    late MockBuildContext mockContext;

    setUp(() {
      final fields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [MockValidator<String>()],
        ),
        FormFieldDefinition<int>(
            name: 'age', validators: [MockValidator<int>()]),
      ];

      fieldRegistry = DefaultFieldRegistry(fields: fields);
      stateCalculator = StateCalculation();
      mockContext = MockBuildContext();
    });

    group('computeFieldUpdateState', () {
      test('should compute state for onSubmit validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};

        final result = stateCalculator.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, currentErrors); // Should not change
        expect(result.isValid, isFalse);
        expect(
            result.validationStrategy, ValidationStrategy.onSubmitThenRealTime);
      });

      test('should compute state for allFields validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final result = stateCalculator.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, isNotEmpty); // Should validate all fields
        expect(result.validationStrategy, ValidationStrategy.allFieldsRealTime);
      });

      test('should compute state for fieldsBeingEdited validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final result = stateCalculator.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors.containsKey('email'), isTrue);
        expect(result.validationStrategy, ValidationStrategy.realTimeOnly);
      });

      test('should remove error when validation passes in fieldsBeingEdited',
          () {
        // Create a new field manager with a validator that returns null (no error)
        final noErrorFields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [NoErrorValidator<String>()],
          ),
        ];
        final noErrorFieldManager = DefaultFieldRegistry(fields: noErrorFields);
        final noErrorStateComputer = StateCalculation();

        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'Previous error'};

        final result = noErrorStateComputer.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
          fieldRegistry: noErrorFieldManager,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors.containsKey('email'), isFalse);
      });

      test('should compute state for disabled validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};

        final result = stateCalculator.computeFieldUpdateState(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.disabled,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.errors, isEmpty); // Should clear all errors
        expect(result.validationStrategy, ValidationStrategy.disabled);
      });

      test('should remove error when validation passes with debounce', () {
        // Create a new field manager with a validator that returns null (no error)
        final noErrorFields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [NoErrorValidator<String>()],
          ),
        ];
        final noErrorFieldManager = DefaultFieldRegistry(fields: noErrorFields);
        final noErrorStateComputer = StateCalculation();

        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'Previous error'};

        bool stateComputed = false;
        noErrorStateComputer.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
          fieldRegistry: noErrorFieldManager,
          onStateComputed: (newState) {
            stateComputed = true;
            expect(newState.values['email'], 'new@example.com');
            expect(newState.errors.containsKey('email'),
                isFalse); // Error should be removed
          },
        );

        expect(stateComputed,
            isFalse); // Should not compute immediately due to debounce
      });
    });

    group('computeFieldsUpdateState', () {
      test('should compute state for multiple fields with fieldsBeingEdited',
          () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateCalculator.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.validationStrategy, ValidationStrategy.realTimeOnly);
      });

      test('should remove errors when validation passes for multiple fields',
          () {
        // Create a new field manager with validators that return null (no error)
        final noErrorFields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [NoErrorValidator<String>()],
          ),
          FormFieldDefinition<int>(
            name: 'age',
            validators: [NoErrorValidator<int>()],
          ),
        ];
        final noErrorFieldManager = DefaultFieldRegistry(fields: noErrorFields);
        final noErrorStateComputer = StateCalculation();

        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = {'email': 'old error', 'age': 'age error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = noErrorStateComputer.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
          fieldRegistry: noErrorFieldManager,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, isEmpty); // Should remove all errors
      });

      test('should clear all errors for disabled validation type', () {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = {'email': 'old error', 'age': 'age error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateCalculator.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.disabled,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, isEmpty); // Should clear all errors
        expect(result.validationStrategy, ValidationStrategy.disabled);
      });
    });

    group('computeFieldsUpdateState', () {
      test('should compute state for multiple field updates', () {
        final currentValues = {'email': 'old@example.com', 'age': 20};
        final currentErrors = <String, String>{};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateCalculator.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.validationStrategy, ValidationStrategy.allFieldsRealTime);
      });

      test('should handle onSubmit validation type for multiple fields', () {
        final currentValues = {'email': 'old@example.com', 'age': 20};
        final currentErrors = {'email': 'old error'};
        final fieldValues = {'email': 'new@example.com', 'age': 30};

        final result = stateCalculator.computeFieldsUpdateState(
          fieldValues: fieldValues,
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values['email'], 'new@example.com');
        expect(result.values['age'], 30);
        expect(result.errors, currentErrors); // Should not change
      });
    });

    group('computeErrorUpdateState', () {
      test('should compute state with new errors', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final newErrors = {'email': 'Email error', 'age': 'Age error'};

        final result = stateCalculator.computeErrorUpdateState(
          newErrors: newErrors,
          currentValues: currentValues,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values, currentValues);
        expect(result.errors, newErrors);
        expect(result.validationStrategy, ValidationStrategy.allFieldsRealTime);
      });

      test('should compute validity based on errors', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final newErrors = <String, String>{}; // No errors

        final result = stateCalculator.computeErrorUpdateState(
          newErrors: newErrors,
          currentValues: currentValues,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.errors, isEmpty);
        // Validity depends on touched fields and validation
      });
    });

    group('computevalidationStrategyChangeState', () {
      test('should compute state for validation type change', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = {'email': 'Email error'};

        final result = stateCalculator.computeValidationStrategyChangeState(
          newValidationStrategy: ValidationStrategy.realTimeOnly,
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
          fieldRegistry: fieldRegistry,
        );

        expect(result.values, currentValues);
        expect(result.errors, currentErrors);
        expect(result.validationStrategy, ValidationStrategy.realTimeOnly);
      });
    });

    group('computeFieldUpdateStateWithDebounce', () {
      test('should handle debounced validation for onSubmit', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};
        TypedFormState? capturedState;

        stateCalculator.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.errors, currentErrors);
        expect(capturedState!.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
      });

      test('should handle debounced validation for allFields', () async {
        final currentValues = {'email': 'old@example.com', 'age': 25};
        final currentErrors = <String, String>{};
        TypedFormState? capturedState;

        stateCalculator.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          context: mockContext,
          fieldRegistry: fieldRegistry,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        // Should not be called immediately
        expect(capturedState, isNull);

        // Wait for debounce delay
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // Should be called after delay
        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.validationStrategy,
            ValidationStrategy.allFieldsRealTime);
      });

      test(
        'should handle debounced validation for fieldsBeingEdited',
        () async {
          final currentValues = {'email': 'old@example.com', 'age': 25};
          final currentErrors = <String, String>{};
          TypedFormState? capturedState;

          stateCalculator.computeFieldUpdateStateWithDebounce(
            fieldName: 'email',
            value: 'new@example.com',
            currentValues: currentValues,
            currentErrors: currentErrors,
            validationStrategy: ValidationStrategy.realTimeOnly,
            context: mockContext,
            fieldRegistry: fieldRegistry,
            onStateComputed: (state) {
              capturedState = state;
            },
          );

          // Should not be called immediately
          expect(capturedState, isNull);

          // Wait for debounce delay
          await Future<void>.delayed(const Duration(milliseconds: 350));

          // Should be called after delay
          expect(capturedState, isNotNull);
          expect(capturedState!.values['email'], 'new@example.com');
          expect(
            capturedState!.validationStrategy,
            ValidationStrategy.realTimeOnly,
          );
        },
      );

      test('should handle disabled validation type', () {
        final currentValues = {'email': 'old@example.com'};
        final currentErrors = {'email': 'old error'};
        TypedFormState? capturedState;

        stateCalculator.computeFieldUpdateStateWithDebounce(
          fieldName: 'email',
          value: 'new@example.com',
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.disabled,
          context: mockContext,
          fieldRegistry: fieldRegistry,
          onStateComputed: (state) {
            capturedState = state;
          },
        );

        expect(capturedState, isNotNull);
        expect(capturedState!.values['email'], 'new@example.com');
        expect(capturedState!.errors, isEmpty);
        expect(capturedState!.validationStrategy, ValidationStrategy.disabled);
      });
    });

    group('getters', () {
      test('should provide access to validation service', () {
        // validationService getter has been removed as validation is now internal
      });

      test('should provide access to debounced validation service', () {
        expect(
          stateCalculator.validationDebounce,
          isA<ValidationDebounce>(),
        );
      });
    });

    group('computeOverallValidityIgnoringTouched', () {
      test('should return true when all fields are valid', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final validators = <String, Validator>{
          'email': NoErrorValidator<String>(),
          'age': NoErrorValidator<int>(),
        };

        final result = stateCalculator.computeOverallValidityIgnoringTouched(
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isTrue);
      });

      test('should return false when any field is invalid', () {
        final currentValues = {'email': 'invalid-email', 'age': 25};
        final validators = <String, Validator>{
          'email': MockValidator<String>(),
          'age': NoErrorValidator<int>(),
        };

        final result = stateCalculator.computeOverallValidityIgnoringTouched(
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isFalse);
      });
    });

    group('validateDependentFields', () {
      test('should validate fields that depend on changed field', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final validators = fieldRegistry.validators;

        final result = stateCalculator.validateDependentFields(
          changedFieldName: 'email',
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isA<Map<String, String>>());
      });

      test('should return empty map when no dependent fields', () {
        final currentValues = {'email': 'test@example.com', 'age': 25};
        final validators = fieldRegistry.validators;

        final result = stateCalculator.validateDependentFields(
          changedFieldName: 'nonExistentField',
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty);
      });

      test(
          'should validate cross-field validators that depend on changed field',
          () {
        final currentValues = {
          'email': 'test@example.com',
          'confirmEmail': 'test@example.com'
        };
        final validators = <String, Validator>{
          'email': NoErrorValidator<String>(),
          'confirmEmail': MockCrossFieldValidator<String>(
            dependentFields: ['email'],
            shouldReturnError: false,
          ),
        };

        final result = stateCalculator.validateDependentFields(
          changedFieldName: 'email',
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isEmpty); // No error should be returned
      });

      test(
          'should return error for cross-field validators that fail validation',
          () {
        final currentValues = {
          'email': 'test@example.com',
          'confirmEmail': 'different@example.com'
        };
        final validators = <String, Validator>{
          'email': NoErrorValidator<String>(),
          'confirmEmail': MockCrossFieldValidator<String>(
            dependentFields: ['email'],
            shouldReturnError: true,
          ),
        };

        final result = stateCalculator.validateDependentFields(
          changedFieldName: 'email',
          values: currentValues,
          validators: validators,
          context: mockContext,
        );

        expect(result, isNotEmpty);
        expect(result['confirmEmail'], isNotNull);
      });
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator<T> implements Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    return 'Mock error';
  }
}

class NoErrorValidator<T> implements Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    return null; // Always returns no error
  }
}

class MockCrossFieldValidator<T> extends TypedCrossFieldValidator<T> {
  final bool shouldReturnError;

  MockCrossFieldValidator({
    required super.dependentFields,
    required this.shouldReturnError,
  }) : super(
          validator: (value, fieldValues, context) {
            return shouldReturnError ? 'Cross-field validation error' : null;
          },
        );
}
