import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('TypedFormController', () {
    late TypedFormController formCubit;
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    tearDown(() {
      formCubit.close();
    });

    group('Initialization', () {
      test('should initialize with empty form by default', () {
        formCubit = TypedFormController();

        expect(formCubit.state.values, isEmpty);
        expect(formCubit.state.errors, isEmpty);
        expect(formCubit.state.isValid, isFalse);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.allFieldsRealTime);
        expect(formCubit.state.fieldTypes, isEmpty);
      });

      test('should initialize with provided fields', () {
        final fields = TestFieldFactory.createEmailAndAgeFields();
        formCubit = TypedFormController(fields: fields);

        expect(formCubit.state.values, {
          'email': 'test@example.com',
          'age': 25,
        });
        expect(formCubit.state.fieldTypes, {'email': String, 'age': int});
        expect(formCubit.state.isValid, isFalse);
      });

      test('should initialize with custom validation type', () {
        formCubit = TypedFormController(
            validationStrategy: ValidationStrategy.onSubmitThenRealTime);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
      });

      test('should initialize with all validation types', () {
        for (final validationStrategy in ValidationStrategy.values) {
          formCubit =
              TypedFormController(validationStrategy: validationStrategy);
          expect(formCubit.state.validationStrategy, validationStrategy);
          formCubit.close();
        }
      });
    });

    group('Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should delegate field updates to service', () {
        // Test that controller properly delegates to field update service
        formCubit.updateField(
          fieldName: 'email',
          value: 'new@example.com',
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'new@example.com');
        expect(formCubit.state.values['email'], 'new@example.com');
      });
    });

    group('Type Safety', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should return correct type for getValue', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );
        formCubit.updateField(
          fieldName: 'age',
          value: 25,
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), isA<String>());
        expect(formCubit.getValue<int>('age'), isA<int>());
      });

      test('should throw FormFieldError for wrong type in getValue', () {
        formCubit.updateField(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        expect(
          () => formCubit.getValue<int>('email'),
          throwsA(isA<FormFieldError>()),
        );
      });

      test(
        'should throw FormFieldError for incompatible value type in getValue',
        () {
          // This test covers line 39 in CoreFormState where TypeError is thrown
          // when the value is not of the expected type
          final fields = [
            const FormFieldDefinition<String>(name: 'email', validators: []),
          ];
          formCubit = TypedFormController(fields: fields);

          // Store a String value
          formCubit.updateField(
            fieldName: 'email',
            value: 'test@example.com',
            context: mockContext,
          );

          // Try to get it as int - this should throw FormFieldError at line 39
          expect(
            () => formCubit.getValue<int>('email'),
            throwsA(isA<FormFieldError>()),
          );
        },
      );

      test('should throw FormFieldError for non-existent field in getValue',
          () {
        expect(
          () => formCubit.getValue<String>('nonExistent'),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Debounced Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should delegate debounced field updates to service', () async {
        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        await Future<void>.delayed(const Duration(milliseconds: 350));

        expect(formCubit.getValue<String>('email'), 'test@example.com');
      });

      test('should handle debounced field updates with realTimeOnly strategy', () async {
        final emailValidator = MockValidator<String>();
        emailValidator.mockValidate = (val, ctx) => val == 'invalid' ? 'Invalid email' : null;

        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
          validationStrategy: ValidationStrategy.realTimeOnly,
        );

        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'invalid',
          context: mockContext,
        );

        await Future<void>.delayed(const Duration(milliseconds: 350));

        expect(formCubit.state.errors['email'], 'Invalid email');
      });

      test('should handle debounced field updates with onSubmitOnly strategy', () {
        formCubit.setValidationStrategy(ValidationStrategy.onSubmitOnly);

        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'test@example.com');
      });

      test('should handle debounced field updates with disabled strategy', () {
        formCubit.setValidationStrategy(ValidationStrategy.disabled);

        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'test@example.com');
        expect(formCubit.state.isValid, isTrue);
      });

      test('should throw error on updateFieldWithDebounce for missing field', () {
        expect(
          () => formCubit.updateFieldWithDebounce<String>(
            fieldName: 'nonExistent',
            value: 'val',
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Multiple Field Updates', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should delegate multiple field updates to service', () {
        // Test that controller properly delegates to field update service
        formCubit.updateFields<String>(
          fieldValues: {'email': 'test@example.com'},
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'test@example.com');
      });
    });

    group('Validation Type Management', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should set validation type', () {
        formCubit
            .setValidationStrategy(ValidationStrategy.onSubmitThenRealTime);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
      });
    });

    group('Form Validation', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
        );
      });

      test('should validate form and call onValidationPass when valid', () {
        emailValidator.mockValidate = (value, context) => null;

        // First update field to mark as touched
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        bool validationPassed = false;
        formCubit.validateForm(
          mockContext,
          onValidationPass: () => validationPassed = true,
        );

        expect(validationPassed, isTrue);
      });

      test('should validate form and call onValidationFail when invalid', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        bool validationFailed = false;
        formCubit.validateForm(
          mockContext,
          onValidationPass: () {},
          onValidationFail: () => validationFailed = true,
        );

        expect(validationFailed, isTrue);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.realTimeOnly);
      });
    });

    group('Immediate Field Validation', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
        );
      });

      test('should delegate immediate validation to service', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        formCubit.validateFieldImmediately(
          fieldName: 'email',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'Email error');
      });
    });

    group('Form Reset', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithInitialValues();
      });

      test('should reset form to initial state', () {
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'changed@example.com',
          context: mockContext,
        );

        formCubit.resetForm();

        expect(formCubit.state.values['email'], 'initial@example.com');
        expect(formCubit.state.errors, isEmpty);
        expect(formCubit.state.isValid, isFalse);
      });
    });

    group('Touch All Fields', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
        );
      });

      test('should touch all fields and validate', () {
        emailValidator.mockValidate = (value, context) => 'Email error';

        formCubit.touchAllFields(mockContext);

        expect(formCubit.state.errors['email'], 'Email error');
      });
    });

    group('Cubit Lifecycle', () {
      test('should dispose resources properly', () async {
        formCubit = TestFormFactory.createFormWithEmailAndAge();

        // This should not throw any errors
        await formCubit.close();

        expect(true, isTrue); // Test passes if no exception is thrown
      });
    });

    group('Additional Coverage Tests', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should handle updateFieldValidators delegation', () {
        final validators = [MockValidator<String>()];

        formCubit.updateFieldValidators<String>(
          name: 'email',
          validators: validators,
          context: mockContext,
        );

        // Test that the method executes without error
        expect(formCubit.state.values.containsKey('email'), isTrue);
      });

      test('should handle form validation with disabled strategy', () {
        // Create a form with disabled validation
        formCubit = TypedFormController(
          fields: TestFieldFactory.createEmailAndAgeFields(),
          validationStrategy: ValidationStrategy.disabled,
        );

        formCubit.validateForm(
          mockContext,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        // Test that the method executes without error
        expect(formCubit.state.validationStrategy, ValidationStrategy.disabled);
      });

      test(
          'should handle form validation with disabled strategy - submission service path',
          () {
        // Create a form with disabled validation to trigger the submission service path
        formCubit = TypedFormController(
          fields: TestFieldFactory.createEmailAndAgeFields(),
          validationStrategy: ValidationStrategy.disabled,
        );

        formCubit.validateForm(
          mockContext,
          onValidationPass: () {},
          onValidationFail: () {},
        );

        // Test that the method executes without error and calls the submission service
        expect(formCubit.state.validationStrategy, ValidationStrategy.disabled);
        // The submission service path should be covered now
      });

      test('should handle updateErrors delegation', () {
        formCubit.updateErrors(
          errors: {'email': 'Custom error'},
          context: mockContext,
        );

        // Test that the method executes without error
        expect(formCubit.state.errors['email'], 'Custom error');
      });

      test('should handle updateError delegation', () {
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'Custom error',
          context: mockContext,
        );

        // Test that the method executes without error
        expect(formCubit.state.errors['email'], 'Custom error');
      });

      test('should handle clearError delegation', () {
        // First set an error
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'Custom error',
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], 'Custom error');

        // Then clear it
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: null,
          context: mockContext,
        );

        // Test that the error is cleared
        expect(formCubit.state.errors.containsKey('email'), isFalse);
      });

      test('should throw error when adding existing field with addField', () {
        final existingField = FormFieldDefinition<String>(
          name: 'email',
          validators: [],
        );

        expect(
          () => formCubit.addField(
            field: existingField,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should throw error when adding existing field with addFields', () {
        final newFields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [],
          ),
        ];

        expect(
          () => formCubit.addFields(
            fields: newFields,
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should throw error when removing non-existent field', () {
        expect(
          () => formCubit.removeField(
            'nonExistent',
            context: mockContext,
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('should handle addField delegation', () {
        final newField = FormFieldDefinition<String>(
          name: 'newField',
          validators: [MockValidator<String>()],
          initialValue: 'initial',
        );

        formCubit.addField(
          field: newField,
          context: mockContext,
        );

        // Test that the field was added
        expect(formCubit.state.values['newField'], 'initial');
        expect(formCubit.state.fieldTypes['newField'], String);
      });

      test('should handle removeField delegation', () {
        formCubit.removeField(
          'email',
          context: mockContext,
        );

        // Test that the field was removed
        expect(formCubit.state.values.containsKey('email'), isFalse);
        expect(formCubit.state.fieldTypes.containsKey('email'), isFalse);
      });

      test('should handle removeFields delegation', () {
        formCubit.removeFields(
          ['email', 'age'],
          context: mockContext,
        );

        // Test that the fields were removed
        expect(formCubit.state.values.containsKey('email'), isFalse);
        expect(formCubit.state.values.containsKey('age'), isFalse);
      });

      test('should handle addFields delegation', () {
        final newFields = [
          FormFieldDefinition<String>(
            name: 'newField1',
            validators: [MockValidator<String>()],
            initialValue: 'initial1',
          ),
          FormFieldDefinition<String>(
            name: 'newField2',
            validators: [MockValidator<String>()],
            initialValue: 'initial2',
          ),
        ];

        formCubit.addFields(
          fields: newFields,
          context: mockContext,
        );

        // Test that the fields were added
        expect(formCubit.state.values['newField1'], 'initial1');
        expect(formCubit.state.values['newField2'], 'initial2');
        expect(formCubit.state.fieldTypes['newField1'], String);
        expect(formCubit.state.fieldTypes['newField2'], String);
      });

      testWidgets('should submit form with validation disabled',
          (tester) async {
        formCubit = TypedFormController(
          fields: TestFieldFactory.createEmailAndAgeFields(),
          validationStrategy: ValidationStrategy.disabled,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<TypedFormController>(
                create: (context) => formCubit,
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        formCubit.validateForm(
                          context,
                          onValidationPass: () {},
                          onValidationFail: () {},
                        );
                      },
                      child: const Text('Submit'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap the submit button
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Should not throw any errors and should proceed with submission
        expect(find.text('Submit'), findsOneWidget);
      });
    });
    group('Additional Controller Tests for Edge Cases', () {
      testWidgets('realTimeOnly strategy updateField clears error when field becomes valid', (tester) async {
        final emailValidator = MockValidator<String>();
        emailValidator.mockValidate = (val, ctx) => 'error';

        formCubit = TypedFormController(
          fields: [
            FormFieldDefinition<String>(name: 'email', validators: [emailValidator]),
          ],
          validationStrategy: ValidationStrategy.realTimeOnly,
        );

        // First update field to produce error
        formCubit.updateField(fieldName: 'email', value: 'bad', context: mockContext);
        await tester.pump(const Duration(milliseconds: 350));
        expect(formCubit.state.errors['email'], equals('error'));

        // Now set validator to pass
        emailValidator.mockValidate = (val, ctx) => null;
        formCubit.updateField(fieldName: 'email', value: 'good', context: mockContext);
        await tester.pump(const Duration(milliseconds: 350));
        expect(formCubit.state.errors['email'], isNull);
      });

      test('updateFields under realTimeOnly strategy handles errors correctly', () {
        final emailValidator = MockValidator<String>();
        emailValidator.mockValidate = (val, ctx) => 'email error';

        formCubit = TypedFormController(
          fields: [
            FormFieldDefinition<String>(name: 'email', validators: [emailValidator]),
            const FormFieldDefinition<int>(name: 'age', validators: []),
          ],
          validationStrategy: ValidationStrategy.realTimeOnly,
        );

        formCubit.updateFields(
          fieldValues: {'email': 'invalid', 'age': 20},
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], equals('email error'));

        emailValidator.mockValidate = (val, ctx) => null;
        formCubit.updateFields(
          fieldValues: {'email': 'valid'},
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], isNull);
      });

      test('updateFields under disabled strategy clears errors and stays valid', () {
        formCubit = TypedFormController(
          fields: [
            const FormFieldDefinition<String>(name: 'email', validators: []),
          ],
          validationStrategy: ValidationStrategy.disabled,
        );

        formCubit.updateFields(
          fieldValues: {'email': 'anything'},
          context: mockContext,
        );
        expect(formCubit.state.errors, isEmpty);
        expect(formCubit.state.isValid, isTrue);
      });

      test('validateFieldImmediately clears error when field becomes valid', () {
        final emailValidator = MockValidator<String>();
        emailValidator.mockValidate = (val, ctx) => 'initial error';

        formCubit = TypedFormController(
          fields: [
            FormFieldDefinition<String>(name: 'email', validators: [emailValidator]),
          ],
        );

        formCubit.validateFieldImmediately(fieldName: 'email', context: mockContext);
        expect(formCubit.state.errors['email'], equals('initial error'));

        emailValidator.mockValidate = (val, ctx) => null;
        formCubit.validateFieldImmediately(fieldName: 'email', context: mockContext);
        expect(formCubit.state.errors['email'], isNull);
      });

      test('updateErrors clears error when null value is provided for key', () {
        formCubit = TypedFormController(
          fields: [
            const FormFieldDefinition<String>(name: 'email', validators: []),
          ],
        );

        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'custom error',
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], equals('custom error'));

        formCubit.updateErrors(
          errors: {'email': null},
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], isNull);
      });
    });

    group('Group and Subset Validation', () {
      late MockValidator<String> requiredValidator;

      setUp(() {
        requiredValidator = MockValidator<String>();
        requiredValidator.mockValidate = (val, ctx) =>
            (val == null || val.isEmpty) ? 'Field is required' : null;

        formCubit = TypedFormController(
          fields: [
            FormFieldDefinition<String>(
              name: 'firstName',
              group: 'personal',
              validators: [requiredValidator],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'lastName',
              group: 'personal',
              validators: [requiredValidator],
              initialValue: 'Doe',
            ),
            FormFieldDefinition<String>(
              name: 'address',
              group: 'addressGroup',
              validators: [requiredValidator],
              initialValue: '',
            ),
          ],
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
        );
      });

      group('validateGroup', () {
        test('should trigger onValidationFail and switch strategy on error', () {
          bool passCalled = false;
          bool failCalled = false;

          formCubit.validateGroup(
            'personal',
            context: mockContext,
            onValidationPass: () => passCalled = true,
            onValidationFail: () => failCalled = true,
          );

          expect(passCalled, isFalse);
          expect(failCalled, isTrue);
          expect(formCubit.state.errors['firstName'], equals('Field is required'));
          expect(formCubit.state.validationStrategy,
              equals(ValidationStrategy.realTimeOnly));
        });

        test('should trigger onValidationPass when all group fields are valid', () {
          formCubit.updateField(
            fieldName: 'firstName',
            value: 'John',
            context: mockContext,
          );

          bool passCalled = false;
          bool failCalled = false;

          formCubit.validateGroup(
            'personal',
            context: mockContext,
            onValidationPass: () => passCalled = true,
            onValidationFail: () => failCalled = true,
          );

          expect(passCalled, isTrue);
          expect(failCalled, isFalse);
          expect(formCubit.state.errors['firstName'], isNull);
          expect(formCubit.state.errors['lastName'], isNull);
          expect(formCubit.state.validationStrategy,
              equals(ValidationStrategy.onSubmitThenRealTime));
        });

        test('should preserve existing errors on unvalidated fields', () {
          formCubit.updateError(
            fieldName: 'address',
            errorMessage: 'Existing error',
            context: mockContext,
          );

          formCubit.validateGroup(
            'personal',
            context: mockContext,
          );

          expect(formCubit.state.errors['address'], equals('Existing error'));
        });

        test('should pass validation for unknown or empty group', () {
          bool passCalled = false;
          bool failCalled = false;

          formCubit.validateGroup(
            'unknownGroup',
            context: mockContext,
            onValidationPass: () => passCalled = true,
            onValidationFail: () => failCalled = true,
          );

          expect(passCalled, isTrue);
          expect(failCalled, isFalse);
        });
      });

      group('validateFields', () {
        test('should validate specified fields and trigger callbacks', () {
          bool passCalled = false;
          bool failCalled = false;

          formCubit.validateFields(
            ['firstName', 'lastName'],
            context: mockContext,
            onValidationPass: () => passCalled = true,
            onValidationFail: () => failCalled = true,
          );

          expect(passCalled, isFalse);
          expect(failCalled, isTrue);
          expect(formCubit.state.errors['firstName'], equals('Field is required'));
          expect(formCubit.state.validationStrategy,
              equals(ValidationStrategy.realTimeOnly));
        });

        test('should throw FormFieldError.fieldNotFound if field missing', () {
          expect(
            () => formCubit.validateFields(
              ['nonExistentField'],
              context: mockContext,
            ),
            throwsA(isA<FormFieldError>()),
          );
        });

        test('should handle empty field list cleanly', () {
          bool passCalled = false;

          formCubit.validateFields(
            [],
            context: mockContext,
            onValidationPass: () => passCalled = true,
          );

          expect(passCalled, isTrue);
        });

        test('should deduplicate input list', () {
          bool failCalled = false;

          formCubit.validateFields(
            ['firstName', 'firstName'],
            context: mockContext,
            onValidationFail: () => failCalled = true,
          );

          expect(failCalled, isTrue);
          expect(formCubit.state.errors['firstName'], equals('Field is required'));
        });
      });

      group('isGroupValid', () {
        test('should return false if any field in group is invalid', () {
          final result = formCubit.isGroupValid('personal', context: mockContext);
          expect(result, isFalse);
        });

        test('should return true if all fields in group are valid', () {
          formCubit.updateField(
            fieldName: 'firstName',
            value: 'John',
            context: mockContext,
          );

          final result = formCubit.isGroupValid('personal', context: mockContext);
          expect(result, isTrue);
        });

        test('should return true for empty or unknown group', () {
          final result = formCubit.isGroupValid('unknownGroup', context: mockContext);
          expect(result, isTrue);
        });

        test('should be passive and not modify state or touched tracker', () {
          final initialErrors = formCubit.state.errors;

          final result = formCubit.isGroupValid('personal', context: mockContext);

          expect(result, isFalse);
          expect(formCubit.state.errors, equals(initialErrors));
        });
      });

      group('areFieldsValid', () {
        test('should return false if any field is invalid', () {
          final result =
              formCubit.areFieldsValid(['firstName', 'lastName'], context: mockContext);
          expect(result, isFalse);
        });

        test('should return true if all fields are valid', () {
          formCubit.updateField(
            fieldName: 'firstName',
            value: 'John',
            context: mockContext,
          );

          final result =
              formCubit.areFieldsValid(['firstName', 'lastName'], context: mockContext);
          expect(result, isTrue);
        });

        test('should return false if field does not exist', () {
          final result = formCubit
              .areFieldsValid(['firstName', 'nonExistent'], context: mockContext);
          expect(result, isFalse);
        });

        test('should return true for empty list', () {
          final result = formCubit.areFieldsValid([], context: mockContext);
          expect(result, isTrue);
        });

        test('should be passive and not modify state', () {
          final initialErrors = formCubit.state.errors;

          formCubit.areFieldsValid(['firstName'], context: mockContext);

          expect(formCubit.state.errors, equals(initialErrors));
        });
      });

      group('touchGroup', () {
        test('should mark group fields as touched and update errors', () {
          formCubit.touchGroup('personal', context: mockContext);

          expect(formCubit.state.errors['firstName'], equals('Field is required'));
          // Does not switch strategy
          expect(formCubit.state.validationStrategy,
              equals(ValidationStrategy.onSubmitThenRealTime));
        });

        test('should handle unknown group cleanly', () {
          formCubit.touchGroup('unknownGroup', context: mockContext);
          expect(formCubit.state.errors, isEmpty);
        });
      });
    });
  });
}

// Mock classes for testing
class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator<T> implements Validator<T> {
  String? Function(T? value, BuildContext context)? mockValidate;

  @override
  String? validate(T? value, BuildContext context) {
    return mockValidate?.call(value, context);
  }
}

// Test utilities for creating common form configurations
class TestFormFactory {
  static TypedFormController createFormWithEmailAndAge({
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
  }) {
    return TypedFormController(
      fields: [
        const FormFieldDefinition<String>(name: 'email', validators: []),
        const FormFieldDefinition<int>(name: 'age', validators: []),
      ],
      validationStrategy: validationStrategy,
    );
  }

  static TypedFormController createFormWithEmailOnly({
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
  }) {
    return TypedFormController(
      fields: [
        const FormFieldDefinition<String>(name: 'email', validators: [])
      ],
      validationStrategy: validationStrategy,
    );
  }

  static TypedFormController createFormWithValidators({
    MockValidator<String>? emailValidator,
    MockValidator<int>? ageValidator,
    ValidationStrategy validationStrategy =
        ValidationStrategy.allFieldsRealTime,
  }) {
    final fields = <FormFieldDefinition>[];

    if (emailValidator != null) {
      fields.add(
        FormFieldDefinition<String>(
            name: 'email', validators: [emailValidator]),
      );
    }

    if (ageValidator != null) {
      fields.add(
          FormFieldDefinition<int>(name: 'age', validators: [ageValidator]));
    }

    return TypedFormController(
        fields: fields, validationStrategy: validationStrategy);
  }

  static TypedFormController createFormWithInitialValues() {
    return TypedFormController(
      fields: [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [MockValidator<String>()],
          initialValue: 'initial@example.com',
        ),
        FormFieldDefinition<int>(
          name: 'age',
          validators: [MockValidator<int>()],
          initialValue: 25,
        ),
      ],
    );
  }
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
