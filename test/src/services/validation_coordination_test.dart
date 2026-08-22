import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('ValidationCoordination', () {
    late ValidationCoordination validationOrchestrator;
    late FieldRegistry fieldRegistry;
    late BuildContext context;

    setUp(() {
      fieldRegistry = DefaultFieldRegistry(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [MockValidator<String>()],
            initialValue: 'test@example.com',
          ),
          FormFieldDefinition<String>(
            name: 'password',
            validators: [MockValidator<String>()],
            initialValue: 'password123',
          ),
        ],
      );
      validationOrchestrator =
          DefaultValidationCoordination(fieldRegistry: fieldRegistry);
    });

    testWidgets('should initialize with default state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return Container();
              },
            ),
          ),
        ),
      );

      final initialState = validationOrchestrator.getInitialValidationState(
        validationStrategy: ValidationStrategy.allFieldsRealTime,
      );

      expect(initialState.isValid, isFalse);
      expect(initialState.errors, isEmpty);
      expect(initialState.validationStrategy,
          ValidationStrategy.allFieldsRealTime);
    });

    group('Validation Strategy Management', () {
      testWidgets('should handle onSubmitOnly strategy correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.onSubmitOnly,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should handle onSubmitThenRealTime strategy correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.onSubmitThenRealTime,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should handle realTimeOnly strategy correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.realTimeOnly,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should handle allFieldsRealTime strategy correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.allFieldsRealTime,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should handle disabled strategy correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.disabled,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isFalse);
        expect(result.shouldSwitchStrategy, isFalse);
      });
    });

    group('Form Submission Orchestration', () {
      testWidgets('should orchestrate form submission with validation pass',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateFormSubmission(
          strategy: ValidationStrategy.onSubmitOnly,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should orchestrate form submission with validation fail',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateFormSubmission(
          strategy: ValidationStrategy.onSubmitThenRealTime,
          currentValues: {'email': '', 'password': ''}, // Invalid values
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isTrue);
        expect(result.newStrategy, ValidationStrategy.realTimeOnly);
      });

      testWidgets('should handle disabled strategy in form submission',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateFormSubmission(
          strategy: ValidationStrategy.disabled,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        expect(result.shouldValidate, isFalse);
        expect(result.shouldSwitchStrategy, isFalse);
      });
    });

    group('Error Management Orchestration', () {
      testWidgets('should orchestrate single error update',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateErrorUpdate(
          fieldName: 'email',
          errorMessage: 'Invalid email format',
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.newErrors['email'], 'Invalid email format');
        expect(result.shouldRevalidate, isTrue);
      });

      testWidgets('should orchestrate multiple error updates',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateMultipleErrorUpdates(
          errors: {
            'email': 'Invalid email',
            'password': 'Password too short',
          },
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.newErrors['email'], 'Invalid email');
        expect(result.newErrors['password'], 'Password too short');
        expect(result.shouldRevalidate, isTrue);
      });

      testWidgets('should handle null values in multiple error updates',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateMultipleErrorUpdates(
          errors: {
            'email': 'Email error',
            'password': null, // This should remove the password error
          },
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {
            'password': 'Previous password error'
          }, // This should be removed
          context: context,
        );

        expect(result.newErrors['email'], 'Email error');
        expect(result.newErrors['password'], isNull);
        expect(result.shouldRevalidate, isTrue);
      });

      testWidgets('should handle non-existent field in multiple error updates',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(
          () => validationOrchestrator.coordinateMultipleErrorUpdates(
            errors: {'nonExistentField': 'Some error'},
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      testWidgets('should orchestrate error clearing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateErrorUpdate(
          fieldName: 'email',
          errorMessage: null, // Clear error
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {'email': 'Previous error'},
          context: context,
        );

        expect(result.newErrors['email'], isNull);
        expect(result.shouldRevalidate, isTrue);
      });

      testWidgets('should handle non-existent field in error update',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(
          () => validationOrchestrator.coordinateErrorUpdate(
            fieldName: 'nonExistentField',
            errorMessage: 'Some error',
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Field Validation Orchestration', () {
      testWidgets('should orchestrate immediate field validation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateFieldValidation(
          fieldName: 'email',
          value: 'test@example.com',
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.fieldName, 'email');
        expect(result.value, 'test@example.com');
      });

      testWidgets('should handle non-existent field gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        expect(
          () => validationOrchestrator.coordinateFieldValidation(
            fieldName: 'nonExistentField',
            value: 'some value',
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Validator Updates Orchestration', () {
      testWidgets('should orchestrate validator updates',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newValidators = [MockValidator<String>()];

        final result = validationOrchestrator.coordinateValidatorUpdate(
          fieldName: 'email',
          validators: newValidators,
          currentValues: {
            'email': 'test@example.com',
            'password': 'password123'
          },
          currentErrors: {},
          context: context,
        );

        expect(result.shouldRevalidate, isTrue);
        expect(result.fieldName, 'email');
        expect(result.validators, newValidators);
      });

      testWidgets('should handle validator update for non-existent field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final newValidators = [MockValidator<String>()];

        expect(
          () => validationOrchestrator.coordinateValidatorUpdate(
            fieldName: 'nonExistentField',
            validators: newValidators,
            currentValues: {
              'email': 'test@example.com',
              'password': 'password123'
            },
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty field service gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.allFieldsRealTime,
          currentValues: {},
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });

      testWidgets('should handle null values gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  context = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final result = validationOrchestrator.coordinateValidation(
          strategy: ValidationStrategy.allFieldsRealTime,
          currentValues: {'email': null, 'password': null},
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.shouldSwitchStrategy, isFalse);
      });
    });

    group('Additional Coverage Tests', () {
      test('should handle type compatibility with nullable types', () {
        final validationOrchestrator =
            DefaultValidationCoordination(fieldRegistry: fieldRegistry);

        // Test the _isTypeCompatible method with nullable types
        // This should cover the line that removes '?' from nullable types
        final result = validationOrchestrator.coordinateFieldValidation(
          fieldName: 'email',
          value: 'test@example.com',
          currentValues: {'email': 'old@example.com'},
          currentErrors: {},
          context: context,
        );

        expect(result.shouldValidate, isTrue);
        expect(result.fieldName, 'email');
        expect(result.value, 'test@example.com');
      });

      test('should handle type mismatch error in orchestrateFieldValidation',
          () {
        final validationOrchestrator =
            DefaultValidationCoordination(fieldRegistry: fieldRegistry);

        // Test type mismatch error - this should cover the type mismatch throw
        expect(
          () => validationOrchestrator.coordinateFieldValidation(
            fieldName: 'email',
            value: 123, // Wrong type - should be String
            currentValues: {'email': 'old@example.com'},
            currentErrors: {},
            context: context,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should handle getInitialValidationState', () {
        final validationOrchestrator =
            DefaultValidationCoordination(fieldRegistry: fieldRegistry);

        final result = validationOrchestrator.getInitialValidationState(
          validationStrategy: ValidationStrategy.realTimeOnly,
        );

        expect(result.values, fieldRegistry.getInitialValues());
        expect(result.errors, isEmpty);
        expect(result.isValid, isFalse);
        expect(result.validationStrategy, ValidationStrategy.realTimeOnly);
        expect(result.fieldTypes, fieldRegistry.fieldTypes);
      });
    });
  });
}

// Mock validator for testing
class MockValidator<T> extends Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return 'Field is required';
    }
    return null;
  }
}
