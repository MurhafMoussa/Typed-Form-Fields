import 'package:flutter/material.dart';
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
        expect(formCubit.asyncDebounceDelay, const Duration(milliseconds: 300));
        expect(formCubit.onAsyncValidationError, isNull);
      });

      test('should initialize with provided fields and callbacks', () {
        void errorHandler(Object e, StackTrace st, String f) {}
        final fields = TestFieldFactory.createEmailAndAgeFields();

        formCubit = TypedFormController(
          fields: fields,
          asyncDebounceDelay: const Duration(milliseconds: 500),
          onAsyncValidationError: errorHandler,
        );

        expect(formCubit.state.values, {
          'email': 'test@example.com',
          'age': 25,
        });
        expect(formCubit.state.fieldTypes, {'email': String, 'age': int});
        expect(formCubit.asyncDebounceDelay, const Duration(milliseconds: 500));
        expect(formCubit.onAsyncValidationError, equals(errorHandler));
      });

      test('should initialize with custom validation strategy', () {
        formCubit = TypedFormController(
            validationStrategy: ValidationStrategy.onSubmitThenRealTime);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
      });

      test('should expose touchedFields, initialValues, isDirty, and isTouched',
          () {
        final fields = TestFieldFactory.createEmailAndAgeFields();
        formCubit = TypedFormController(fields: fields);

        expect(formCubit.touchedFields, equals({'email': false, 'age': false}));
        expect(formCubit.initialValues,
            equals({'email': 'test@example.com', 'age': 25}));
        expect(formCubit.isDirty, isFalse);
        expect(formCubit.isTouched('email'), isFalse);

        formCubit.updateField(
          fieldName: 'email',
          value: 'changed@example.com',
          context: mockContext,
        );

        expect(formCubit.isDirty, isTrue);
        expect(formCubit.isTouched('email'), isTrue);
        expect(formCubit.touchedFields['email'], isTrue);
      });
    });

    group('Type Safety and Value Access', () {
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

        expect(formCubit.getValue<String>('email'), equals('test@example.com'));
        expect(formCubit.getValue<int>('age'), equals(25));
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

      test('should throw FormFieldError for non-existent field in getValue',
          () {
        expect(
          () => formCubit.getValue<String>('nonExistent'),
          throwsA(isA<FormFieldError>()),
        );
      });
    });

    group('Validation Strategy Management', () {
      setUp(() {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
      });

      test('should update validation strategy', () {
        formCubit
            .setValidationStrategy(ValidationStrategy.onSubmitThenRealTime);
        expect(formCubit.state.validationStrategy,
            ValidationStrategy.onSubmitThenRealTime);
      });
    });

    group('Facade Operations Delegation', () {
      late MockValidator<String> emailValidator;

      setUp(() {
        emailValidator = MockValidator<String>();
        formCubit = TestFormFactory.createFormWithValidators(
          emailValidator: emailValidator,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
        );
      });

      test('delegates updateField and updates state', () {
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'hello@example.com',
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'hello@example.com');
      });

      test('delegates updateFieldWithDebounce', () async {
        formCubit.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'debounced@example.com',
          context: mockContext,
        );

        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(formCubit.getValue<String>('email'), 'debounced@example.com');
      });

      test('delegates updateFields', () {
        formCubit.updateFields(
          fieldValues: {'email': 'multi@example.com'},
          context: mockContext,
        );

        expect(formCubit.getValue<String>('email'), 'multi@example.com');
      });

      test('delegates updateFieldValidators', () {
        final validators = [MockValidator<String>()];
        formCubit.updateFieldValidators<String>(
          name: 'email',
          validators: validators,
          context: mockContext,
        );

        expect(formCubit.state.values.containsKey('email'), isTrue);
      });

      test('delegates validateForm', () {
        emailValidator.mockValidate = (val, ctx) => null;
        bool passCalled = false;

        formCubit.validateForm(
          mockContext,
          onValidationPass: () => passCalled = true,
        );

        expect(passCalled, isTrue);
      });

      test('delegates validateFieldImmediately', () {
        emailValidator.mockValidate = (val, ctx) => 'Immediate error';

        formCubit.validateFieldImmediately(
          fieldName: 'email',
          context: mockContext,
        );

        expect(formCubit.state.errors['email'], 'Immediate error');
      });

      test('delegates resetForm', () {
        formCubit = TestFormFactory.createFormWithInitialValues();
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'changed@example.com',
          context: mockContext,
        );

        formCubit.resetForm();
        expect(formCubit.getValue<String>('email'), 'initial@example.com');
      });

      test('delegates touchAllFields', () {
        emailValidator.mockValidate = (val, ctx) => 'Touched error';

        formCubit.touchAllFields(mockContext);
        expect(formCubit.state.errors['email'], 'Touched error');
      });

      test('delegates updateError and updateErrors', () {
        formCubit.updateError(
          fieldName: 'email',
          errorMessage: 'Single error',
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], 'Single error');

        formCubit.updateErrors(
          errors: {'email': 'Multi error'},
          context: mockContext,
        );
        expect(formCubit.state.errors['email'], 'Multi error');
      });

      test(
          'delegates dynamic field management (addField, addFields, removeField, removeFields)',
          () {
        final newField = FormFieldDefinition<String>(
          name: 'phone',
          initialValue: '123456',
          validators: [],
        );

        formCubit.addField(field: newField, context: mockContext);
        expect(formCubit.getValue<String>('phone'), '123456');

        formCubit.removeField('phone', context: mockContext);
        expect(formCubit.state.values.containsKey('phone'), isFalse);

        final fields = [
          const FormFieldDefinition<String>(
              name: 'f1', initialValue: 'v1', validators: []),
          const FormFieldDefinition<String>(
              name: 'f2', initialValue: 'v2', validators: []),
        ];

        formCubit.addFields(fields: fields, context: mockContext);
        expect(formCubit.getValue<String>('f1'), 'v1');

        formCubit.removeFields(['f1', 'f2'], context: mockContext);
        expect(formCubit.state.values.containsKey('f1'), isFalse);
      });

      test(
          'delegates group and subset queries (isGroupValid, areFieldsValid, touchGroup, validateGroup, validateFields)',
          () {
        final requiredVal = MockValidator<String>();
        requiredVal.mockValidate =
            (val, ctx) => (val == null || val.isEmpty) ? 'Req' : null;

        formCubit = TypedFormController(
          fields: [
            FormFieldDefinition<String>(
              name: 'fname',
              group: 'nameGrp',
              validators: [requiredVal],
              initialValue: '',
            ),
          ],
        );

        expect(
            formCubit.isGroupValid('nameGrp', context: mockContext), isFalse);
        expect(
            formCubit.areFieldsValid(['fname'], context: mockContext), isFalse);

        formCubit.touchGroup('nameGrp', context: mockContext);
        expect(formCubit.state.errors['fname'], 'Req');

        bool failCalled = false;
        formCubit.validateGroup(
          'nameGrp',
          context: mockContext,
          onValidationFail: () => failCalled = true,
        );
        expect(failCalled, isTrue);

        failCalled = false;
        formCubit.validateFields(
          ['fname'],
          context: mockContext,
          onValidationFail: () => failCalled = true,
        );
        expect(failCalled, isTrue);
      });
    });

    group('Cubit Lifecycle', () {
      test('disposes resources properly on close', () async {
        formCubit = TestFormFactory.createFormWithEmailAndAge();
        await formCubit.close();
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
