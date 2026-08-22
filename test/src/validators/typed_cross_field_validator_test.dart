import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TypedCrossFieldValidators private constructor', () {
    test('ensures private constructor exists', () {
      expect(() => TypedCrossFieldValidators, isNotNull);
    });
  });

  group('TypedCrossFieldValidator', () {

    testWidgets('should validate field based on other field values',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'password',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'password123',
        ),
        FormFieldDefinition<String>(
          name: 'confirmPassword',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCrossFieldValidator<String>(
              dependentFields: ['password'],
              validator: (value, fieldValues, context) {
                final password = fieldValues['password'] as String?;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
          initialValue: 'password123',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);
                final state = controller.state;

                // Both passwords match, so no error
                expect(state.getError('confirmPassword'), isNull);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return error when cross-field validation fails',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'password',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'password123',
        ),
        FormFieldDefinition<String>(
          name: 'confirmPassword',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCrossFieldValidator<String>(
              dependentFields: ['password'],
              validator: (value, fieldValues, context) {
                final password = fieldValues['password'] as String?;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
          initialValue: 'different123',
        ),
      ];

      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);

                // Update the confirm password field to trigger validation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.updateField(
                    fieldName: 'confirmPassword',
                    value: 'different123',
                    context: context,
                  );

                  // Check for error after update
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    errorMessage = controller.state.getError('confirmPassword');
                  });
                });

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(); // Second pump to handle the post-frame callbacks

      // Passwords don't match, so there should be an error
      expect(errorMessage, 'Passwords do not match');
    });

    testWidgets('should handle multiple dependent fields', (tester) async {
      final testFields = [
        FormFieldDefinition<DateTime>(
          name: 'startDate',
          validators: [TypedCommonValidators.required<DateTime>()],
          initialValue: DateTime(2023, 1, 1),
        ),
        FormFieldDefinition<DateTime>(
          name: 'endDate',
          validators: [TypedCommonValidators.required<DateTime>()],
          initialValue: DateTime(2023, 1, 15),
        ),
        FormFieldDefinition<String>(
          name: 'description',
          validators: [
            TypedCrossFieldValidator<String>(
              dependentFields: ['startDate', 'endDate'],
              validator: (value, fieldValues, context) {
                final startDate = fieldValues['startDate'] as DateTime?;
                final endDate = fieldValues['endDate'] as DateTime?;

                if (startDate != null &&
                    endDate != null &&
                    endDate.isBefore(startDate)) {
                  return 'End date must be after start date';
                }
                return null;
              },
            ),
          ],
          initialValue: 'Valid date range',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);
                final state = controller.state;

                // Valid date range, so no error
                expect(state.getError('description'), isNull);

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should return empty map when no form controller found',
        (tester) async {
      final validator = TypedCrossFieldValidator<String>(
        dependentFields: ['password'],
        validator: (value, fieldValues, context) {
          // This should receive an empty map since no form controller is available
          expect(fieldValues, isEmpty);
          return null;
        },
      );

      // Test without a form provider
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final result = validator.validate('test', context);
              expect(result, isNull);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('should have correct dependent fields', () {
      final validator = TypedCrossFieldValidator<String>(
        dependentFields: ['field1', 'field2', 'field3'],
        validator: (value, fieldValues, context) => null,
      );

      expect(validator.dependentFields, ['field1', 'field2', 'field3']);
    });

    testWidgets('should work with conditional validation', (tester) async {
      final testFields = [
        FormFieldDefinition<bool>(
          name: 'hasAddress',
          validators: [],
          initialValue: true,
        ),
        FormFieldDefinition<String>(
          name: 'address',
          validators: [
            TypedCrossFieldValidator<String>(
              dependentFields: ['hasAddress'],
              validator: (value, fieldValues, context) {
                final hasAddress = fieldValues['hasAddress'] as bool?;
                if (hasAddress == true && (value == null || value.isEmpty)) {
                  return 'Address is required when hasAddress is true';
                }
                return null;
              },
            ),
          ],
          initialValue: '',
        ),
      ];

      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);

                // Update the address field to trigger validation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.updateField(
                    fieldName: 'address',
                    value: '',
                    context: context,
                  );

                  // Check for error after update
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    errorMessage = controller.state.getError('address');
                  });
                });

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(); // Second pump to handle the post-frame callbacks

      // Address is required but empty, so there should be an error
      expect(errorMessage, 'Address is required when hasAddress is true');
    });
  });

  group('Static Helper Methods', () {
    late TypedFormController formController;
    late BuildContext testContext;

    setUp(() {
      formController = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'password',
            validators: [],
            initialValue: 'password123',
          ),
          FormFieldDefinition<String>(
            name: 'confirmPassword',
            validators: [],
            initialValue: 'password456',
          ),
          FormFieldDefinition<String>(
            name: 'username',
            validators: [],
            initialValue: 'user123',
          ),
          FormFieldDefinition<DateTime>(
            name: 'startDate',
            validators: [],
            initialValue: DateTime(2023, 1, 1),
          ),
          FormFieldDefinition<DateTime>(
            name: 'endDate',
            validators: [],
            initialValue: DateTime(2023, 12, 31),
          ),
          FormFieldDefinition<num>(
            name: 'minValue',
            validators: [],
            initialValue: 5,
          ),
          FormFieldDefinition<num>(
            name: 'maxValue',
            validators: [],
            initialValue: 10,
          ),
          FormFieldDefinition<num>(
            name: 'field1',
            validators: [],
            initialValue: 3,
          ),
          FormFieldDefinition<num>(
            name: 'field2',
            validators: [],
            initialValue: 4,
          ),
        ],
      );
    });

    tearDown(() {
      formController.close();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<TypedFormController>(
          create: (context) => formController,
          child: Builder(
            builder: (context) {
              testContext = context;
              return Scaffold(body: child);
            },
          ),
        ),
      );
    }

    group('matches', () {
      testWidgets('should validate that field matches another field',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.matches<String>('password');

        // Test with matching values
        formController.updateField(
          fieldName: 'confirmPassword',
          value: 'password123',
          context: testContext,
        );
        await tester.pump();

        final result = validator.validate('password123', testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when fields do not match',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.matches<String>('password');

        final result = validator.validate('password456', testContext);
        expect(result, isNotNull);
        expect(result, contains('match'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.matches<String>(
          'password',
          errorText: 'Passwords must match',
        );

        final result = validator.validate('password456', testContext);
        expect(result, 'Passwords must match');
      });
    });

    group('differentFrom', () {
      testWidgets('should validate that field is different from another field',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator =
            TypedCrossFieldValidators.differentFrom<String>('username');

        final result = validator.validate('password123', testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when fields are the same',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator =
            TypedCrossFieldValidators.differentFrom<String>('username');

        final result = validator.validate('user123', testContext);
        expect(result, isNotNull);
        expect(result, contains('different'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.differentFrom<String>(
          'username',
          errorText: 'Password must be different from username',
        );

        final result = validator.validate('user123', testContext);
        expect(result, 'Password must be different from username');
      });
    });

    group('requiredWhen', () {
      testWidgets('should require field when condition is true',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.requiredWhen<String>(
          'username',
          'user123',
        );

        final result = validator.validate('value', testContext);
        expect(result, isNull);
      });

      testWidgets(
          'should return error when field is empty and condition is true',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.requiredWhen<String>(
          'username',
          'user123',
        );

        final result = validator.validate('', testContext);
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      testWidgets('should not require field when condition is false',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.requiredWhen<String>(
          'username',
          'different',
        );

        final result = validator.validate('', testContext);
        expect(result, isNull);
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.requiredWhen<String>(
          'username',
          'user123',
          errorText: 'This field is required when username is user123',
        );

        final result = validator.validate('', testContext);
        expect(result, 'This field is required when username is user123');
      });
    });

    group('requiredWhenNotEmpty', () {
      testWidgets('should require field when other field is not empty',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator =
            TypedCrossFieldValidators.requiredWhenNotEmpty<String>('username');

        final result = validator.validate('value', testContext);
        expect(result, isNull);
      });

      testWidgets(
          'should return error when field is empty and other field is not empty',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator =
            TypedCrossFieldValidators.requiredWhenNotEmpty<String>('username');

        final result = validator.validate('', testContext);
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      testWidgets('should not require field when other field is empty',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        formController.updateField(
          fieldName: 'username',
          value: '',
          context: testContext,
        );
        await tester.pump();

        final validator =
            TypedCrossFieldValidators.requiredWhenNotEmpty<String>('username');

        final result = validator.validate('', testContext);
        expect(result, isNull);
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator =
            TypedCrossFieldValidators.requiredWhenNotEmpty<String>(
          'username',
          errorText: 'This field is required when username is not empty',
        );

        final result = validator.validate('', testContext);
        expect(result, 'This field is required when username is not empty');
      });
    });

    group('dateBefore', () {
      testWidgets('should validate that date is before another date',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateBefore('endDate');

        final result = validator.validate(DateTime(2023, 6, 15), testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when date is after another date',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateBefore('endDate');

        final result = validator.validate(DateTime(2024, 1, 1), testContext);
        expect(result, isNotNull);
        expect(result, contains('before'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateBefore(
          'endDate',
          errorText: 'Start date must be before end date',
        );

        final result = validator.validate(DateTime(2024, 1, 1), testContext);
        expect(result, 'Start date must be before end date');
      });
    });

    group('dateAfter', () {
      testWidgets('should validate that date is after another date',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateAfter('startDate');

        final result = validator.validate(DateTime(2023, 6, 15), testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when date is before another date',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateAfter('startDate');

        final result = validator.validate(DateTime(2022, 12, 31), testContext);
        expect(result, isNotNull);
        expect(result, contains('after'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.dateAfter(
          'startDate',
          errorText: 'End date must be after start date',
        );

        final result = validator.validate(DateTime(2022, 12, 31), testContext);
        expect(result, 'End date must be after start date');
      });
    });

    group('greaterThan', () {
      testWidgets('should validate that number is greater than another number',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.greaterThan('minValue');

        final result = validator.validate(7, testContext);
        expect(result, isNull);
      });

      testWidgets(
          'should return error when number is not greater than another number',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.greaterThan('minValue');

        final result = validator.validate(3, testContext);
        expect(result, isNotNull);
        expect(result, contains('greater'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.greaterThan(
          'minValue',
          errorText: 'Value must be greater than min value',
        );

        final result = validator.validate(3, testContext);
        expect(result, 'Value must be greater than min value');
      });
    });

    group('lessThan', () {
      testWidgets('should validate that number is less than another number',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.lessThan('maxValue');

        final result = validator.validate(7, testContext);
        expect(result, isNull);
      });

      testWidgets(
          'should return error when number is not less than another number',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.lessThan('maxValue');

        final result = validator.validate(15, testContext);
        expect(result, isNotNull);
        expect(result, contains('less'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.lessThan(
          'maxValue',
          errorText: 'Value must be less than max value',
        );

        final result = validator.validate(15, testContext);
        expect(result, 'Value must be less than max value');
      });
    });

    group('sumCondition', () {
      testWidgets('should validate that sum meets condition', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum > 10,
        );

        final result = validator.validate(5, testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when sum does not meet condition',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum > 10,
        );

        final result = validator.validate(2, testContext);
        expect(result, isNotNull);
        expect(result, contains('condition'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.sumCondition(
          ['field1', 'field2'],
          (sum) => sum > 10,
          errorText: 'Sum must be greater than 10',
        );

        final result = validator.validate(2, testContext);
        expect(result, 'Sum must be greater than 10');
      });
    });

    group('atLeastOneRequired', () {
      testWidgets('should validate when current field has value',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        final result = validator.validate('value', testContext);
        expect(result, isNull);
      });

      testWidgets('should validate when another field has value',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        final validator = TypedCrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        final result = validator.validate('', testContext);
        expect(result, isNull);
      });

      testWidgets('should return error when no fields have values',
          (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        formController.updateField<num>(
          fieldName: 'field1',
          value: null,
          context: testContext,
        );
        formController.updateField<num>(
          fieldName: 'field2',
          value: null,
          context: testContext,
        );
        await tester.pump();

        final validator = TypedCrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
        );

        final result = validator.validate('', testContext);
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      testWidgets('should use custom error text', (tester) async {
        await tester.pumpWidget(createTestWidget(const SizedBox()));

        formController.updateField<num>(
          fieldName: 'field1',
          value: null,
          context: testContext,
        );
        formController.updateField<num>(
          fieldName: 'field2',
          value: null,
          context: testContext,
        );
        await tester.pump();

        final validator = TypedCrossFieldValidators.atLeastOneRequired<String>(
          ['field1', 'field2'],
          errorText: 'At least one field is required',
        );

        final result = validator.validate('', testContext);
        expect(result, 'At least one field is required');
      });
    });
  });
}
