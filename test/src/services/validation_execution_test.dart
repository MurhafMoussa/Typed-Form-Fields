import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/services/field_registry.dart';
import 'package:typed_form_fields/src/services/state_calculation.dart';
import 'package:typed_form_fields/src/services/validation_coordination.dart';
import 'package:typed_form_fields/src/services/validation_execution.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('ValidationExecution', () {
    late ValidationExecution validationExecutor;
    late FieldRegistry fieldRegistry;
    late StateCalculation stateComputer;
    late ValidationCoordination orchestrator;
    late BuildContext mockContext;

    setUp(() {
      fieldRegistry = DefaultFieldRegistry(
          fields: TestFieldFactory.createEmailAndAgeFields());
      stateComputer = StateCalculation();
      orchestrator =
          DefaultValidationCoordination(fieldRegistry: fieldRegistry);
      validationExecutor = DefaultValidationExecution(
        validationCoordination: orchestrator,
        fieldRegistry: fieldRegistry,
        stateCalculation: stateComputer,
      );
    });

    group('validateFieldImmediately', () {
      testWidgets('should validate field immediately',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final newState = validationExecutor.validateFieldImmediately(
          fieldName: 'email',
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets(
          'should throw FormFieldError for non-existent field in validateFieldImmediately',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com'};
        final currentErrors = <String, String>{};

        expect(
          () => validationExecutor.validateFieldImmediately(
            fieldName: 'nonexistent',
            currentValues: currentValues,
            currentErrors: currentErrors,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('updateFieldValidators', () {
      testWidgets('should update field validators and re-validate',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};
        final newValidators = [MockValidator<String>()];

        final newState = validationExecutor.updateFieldValidators<String>(
          fieldName: 'email',
          validators: newValidators,
          currentValues: currentValues,
          currentErrors: currentErrors,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
      });

      testWidgets(
          'should throw FormFieldError for non-existent field in updateFieldValidators',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com'};
        final currentErrors = <String, String>{};
        final newValidators = [MockValidator<String>()];

        expect(
          () => validationExecutor.updateFieldValidators<String>(
            fieldName: 'nonexistent',
            validators: newValidators,
            currentValues: currentValues,
            currentErrors: currentErrors,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('validateForm', () {
      testWidgets('should validate entire form', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final newState = validationExecutor.validateForm(
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
        expect(newState.validationStrategy, ValidationStrategy.realTimeOnly);
      });
    });

    group('touchAllFields', () {
      testWidgets('should touch all fields and validate them',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) {
                  mockContext = ctx;
                  return Container();
                },
              ),
            ),
          ),
        );

        final currentValues = {'email': 'test@example.com', 'age': 25};
        final currentErrors = <String, String>{};

        final newState = validationExecutor.touchAllFields(
          currentValues: currentValues,
          currentErrors: currentErrors,
          validationStrategy: ValidationStrategy.realTimeOnly,
          context: mockContext,
        );

        expect(newState.values, currentValues);
        expect(newState.fieldTypes, fieldRegistry.fieldTypes);
        expect(newState.validationStrategy, ValidationStrategy.realTimeOnly);
      });
    });
  });

  group('Edge Cases', () {
    testWidgets('should handle field with no validator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                return Container();
              },
            ),
          ),
        ),
      );

      final currentValues = {'email': 'test@example.com', 'age': 25};
      final currentErrors = <String, String>{};

      // Create a field registry with a field that has no validator
      final fieldWithNoValidator = DefaultFieldRegistry(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [], // No validators
          ),
        ],
      );

      // Create a new validation executor for this test
      final testValidationExecutor = DefaultValidationExecution(
        validationCoordination:
            DefaultValidationCoordination(fieldRegistry: fieldWithNoValidator),
        fieldRegistry: fieldWithNoValidator,
        stateCalculation: StateCalculation(),
      );

      final result = testValidationExecutor.validateFieldImmediately(
        fieldName: 'email',
        currentValues: currentValues,
        currentErrors: currentErrors,
        context: tester.element(find.byType(MaterialApp)),
      );

      expect(result.values['email'], 'test@example.com');
      expect(result.errors, isEmpty);
      expect(result.isValid, isFalse); // Should be false when no validator
    });
  });
}

class MockBuildContext {
  // Simple mock that doesn't extend BuildContext to avoid implementation issues
}

class TestFieldFactory {
  static List<FormFieldDefinition> createEmailAndAgeFields() {
    return [
      FormFieldDefinition<String>(
        name: 'email',
        validators: [MockValidator<String>()],
        initialValue: 'test@example.com',
      ),
      FormFieldDefinition<int>(
        name: 'age',
        validators: [MockValidator<int>()],
        initialValue: 25,
      ),
    ];
  }
}

class MockValidator<T> extends Validator<T> {
  @override
  String? validate(T? value, BuildContext context) {
    if (value == null || value.toString().isEmpty) {
      return 'Mock error';
    }
    return null;
  }
}
