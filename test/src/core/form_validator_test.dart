import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/validators/typed_cross_field_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestValidator<T> implements Validator<T> {
  TestValidator(this.onValidate);

  final String? Function(T? value, BuildContext context) onValidate;

  @override
  String? validate(T? value, BuildContext context) {
    return onValidate(value, context);
  }
}

void main() {
  group('FormValidator', () {
    late FormValidator formValidator;
    late MockBuildContext mockContext;

    setUp(() {
      formValidator = FormValidator(
        debounceDelay: const Duration(milliseconds: 50),
      );
      mockContext = MockBuildContext();
    });

    tearDown(() {
      formValidator.dispose();
    });

    group('isValueCompatibleWithExpectedType', () {
      test('should validate basic non-nullable types', () {
        expect(
            formValidator.isValueCompatibleWithExpectedType('hello', String),
            isTrue);
        expect(
            formValidator.isValueCompatibleWithExpectedType(123, String),
            isFalse);

        expect(formValidator.isValueCompatibleWithExpectedType(42, int), isTrue);
        expect(
            formValidator.isValueCompatibleWithExpectedType('42', int), isFalse);

        expect(
            formValidator.isValueCompatibleWithExpectedType(3.14, double), isTrue);
        expect(
            formValidator.isValueCompatibleWithExpectedType(3, double), isFalse);

        expect(formValidator.isValueCompatibleWithExpectedType(10, num), isTrue);
        expect(
            formValidator.isValueCompatibleWithExpectedType(3.14, num), isTrue);

        expect(
            formValidator.isValueCompatibleWithExpectedType(true, bool), isTrue);
        expect(
            formValidator.isValueCompatibleWithExpectedType('true', bool), isFalse);
      });

      test('should validate nullable type strings', () {
        // String comparison for typeString
        expect(
          formValidator.isValueCompatibleWithExpectedType('test', String),
          isTrue,
        );
      });

      test('should validate complex generic types like List<String>', () {
        final list = <String>['a', 'b'];
        expect(
          formValidator.isValueCompatibleWithExpectedType(list, list.runtimeType),
          isTrue,
        );
      });

      test('should handle null values correctly', () {
        expect(
          formValidator.isValueCompatibleWithExpectedType(null, String),
          isFalse,
        );
      });
    });

    group('validateValueType', () {
      test('should pass for compatible value types', () {
        expect(
          () => formValidator.validateValueType(
            fieldName: 'age',
            value: 25,
            expectedType: int,
            operation: 'testOperation',
          ),
          returnsNormally,
        );
      });

      test('should pass when value is null', () {
        expect(
          () => formValidator.validateValueType(
            fieldName: 'age',
            value: null,
            expectedType: int,
            operation: 'testOperation',
          ),
          returnsNormally,
        );
      });

      test('should pass when expectedType is null', () {
        expect(
          () => formValidator.validateValueType(
            fieldName: 'age',
            value: 25,
            expectedType: null,
            operation: 'testOperation',
          ),
          returnsNormally,
        );
      });

      test('should throw FormFieldError on type mismatch', () {
        expect(
          () => formValidator.validateValueType(
            fieldName: 'age',
            value: 'not an int',
            expectedType: int,
            operation: 'testOperation',
          ),
          throwsA(
            isA<FormFieldError>().having(
              (e) => e.message,
              'message',
              contains("Type mismatch for field \"age\": expected int but got String."),
            ),
          ),
        );
      });
    });

    group('validateField and validateFieldByName', () {
      test('validateField should return null when validator is null', () {
        final error = formValidator.validateField<String>(
          validator: null,
          value: 'test',
          context: mockContext,
        );
        expect(error, isNull);
      });

      test('validateField should return validator result', () {
        final validator = TestValidator<String>((value, context) {
          return value == 'invalid' ? 'Is invalid' : null;
        });

        expect(
          formValidator.validateField<String>(
            validator: validator,
            value: 'valid',
            context: mockContext,
          ),
          isNull,
        );

        expect(
          formValidator.validateField<String>(
            validator: validator,
            value: 'invalid',
            context: mockContext,
          ),
          'Is invalid',
        );
      });

      test('validateFieldByName should validate when validator exists', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((value, context) =>
              value == 'bad' ? 'Bad email' : null),
        };
        final values = <String, Object?>{'email': 'bad'};

        final error = formValidator.validateFieldByName(
          fieldName: 'email',
          values: values,
          validators: validators,
          context: mockContext,
        );
        expect(error, 'Bad email');
      });

      test('validateFieldByName should return null when field has no validator', () {
        final error = formValidator.validateFieldByName(
          fieldName: 'email',
          values: {'email': 'test'},
          validators: {},
          context: mockContext,
        );
        expect(error, isNull);
      });
    });

    group('validateFields', () {
      test('should collect errors from all failing validators', () {
        final validators = <String, Validator>{
          'name': TestValidator<dynamic>((v, c) => v == '' ? 'Name required' : null),
          'age': TestValidator<dynamic>((v, c) => (v as int) < 18 ? 'Underage' : null),
        };
        final values = <String, Object?>{
          'name': '',
          'age': 15,
        };

        final errors = formValidator.validateFields(
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(errors, {
          'name': 'Name required',
          'age': 'Underage',
        });
      });

      test('should return empty map when all fields pass', () {
        final validators = <String, Validator>{
          'name': TestValidator<dynamic>((v, c) => null),
        };
        final errors = formValidator.validateFields(
          values: {'name': 'John'},
          validators: validators,
          context: mockContext,
        );

        expect(errors, isEmpty);
      });
    });

    group('computeOverallValidity', () {
      test('should return false if any validator field is untouched', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((v, c) => null),
        };
        final touched = <String, bool>{'email': false};

        final isValid = formValidator.computeOverallValidity(
          values: {'email': 'test@example.com'},
          validators: validators,
          touchedFields: touched,
          context: mockContext,
        );

        expect(isValid, isFalse);
      });

      test('should return false if touched field has validation error', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((v, c) => 'Invalid'),
        };
        final touched = <String, bool>{'email': true};

        final isValid = formValidator.computeOverallValidity(
          values: {'email': 'bad'},
          validators: validators,
          touchedFields: touched,
          context: mockContext,
        );

        expect(isValid, isFalse);
      });

      test('should return true when all validated fields are touched and valid', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((v, c) => null),
        };
        final touched = <String, bool>{'email': true};

        final isValid = formValidator.computeOverallValidity(
          values: {'email': 'good'},
          validators: validators,
          touchedFields: touched,
          context: mockContext,
        );

        expect(isValid, isTrue);
      });
    });

    group('computeOverallValidityWithErrors', () {
      test('should return false if explicit errors map is not empty', () {
        final isValid = formValidator.computeOverallValidityWithErrors(
          values: {'email': 'test@example.com'},
          errors: {'email': 'Server error'},
          touchedFields: {'email': true},
          validators: {},
          context: mockContext,
        );

        expect(isValid, isFalse);
      });

      test('should return false if any field is untouched', () {
        final isValid = formValidator.computeOverallValidityWithErrors(
          values: {'email': 'test@example.com'},
          errors: {},
          touchedFields: {'email': false},
          validators: {},
          context: mockContext,
        );

        expect(isValid, isFalse);
      });

      test('should return false if validator fails on field value', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((v, c) => 'Failed'),
        };

        final isValid = formValidator.computeOverallValidityWithErrors(
          values: {'email': 'test@example.com'},
          errors: {},
          touchedFields: {'email': true},
          validators: validators,
          context: mockContext,
        );

        expect(isValid, isFalse);
      });

      test('should return true when no errors, touched, and validators pass', () {
        final validators = <String, Validator>{
          'email': TestValidator<dynamic>((v, c) => null),
        };

        final isValid = formValidator.computeOverallValidityWithErrors(
          values: {'email': 'test@example.com'},
          errors: {},
          touchedFields: {'email': true},
          validators: validators,
          context: mockContext,
        );

        expect(isValid, isTrue);
      });
    });

    group('validateDependentFields', () {
      test('should validate fields that depend on changedFieldName', () {
        final crossValidator = TypedCrossFieldValidator<String>(
          dependentFields: ['password'],
          validator: (value, fieldValues, context) {
            if (value != fieldValues['password']) {
              return 'Passwords do not match';
            }
            return null;
          },
        );

        final validators = <String, Validator>{
          'password': TestValidator<dynamic>((v, c) => null),
          'confirmPassword': crossValidator,
        };

        final values = <String, Object?>{
          'password': 'pass',
          'confirmPassword': 'diff',
        };

        final errors = formValidator.validateDependentFields(
          changedFieldName: 'password',
          values: values,
          validators: validators,
          context: mockContext,
        );

        expect(errors, {'confirmPassword': 'Passwords do not match'});
      });

      test('should ignore non-dependent or non-cross-field validators', () {
        final crossValidator = TypedCrossFieldValidator<String>(
          dependentFields: ['otherField'],
          validator: (value, fieldValues, context) => 'Error',
        );

        final validators = <String, Validator>{
          'simpleField': TestValidator<dynamic>((v, c) => 'Simple Error'),
          'confirmPassword': crossValidator,
        };

        final errors = formValidator.validateDependentFields(
          changedFieldName: 'password',
          values: {'password': 'val'},
          validators: validators,
          context: mockContext,
        );

        expect(errors, isEmpty);
      });
    });

    group('Debounced Validation & Timer Lifecycle', () {
      test('validateFieldWithDebounce should trigger completion callback after delay', () async {
        final validators = <String, Validator>{
          'username': TestValidator<dynamic>((v, c) => v == 'taken' ? 'Username taken' : null),
        };

        String? resultError;
        bool completed = false;

        formValidator.validateFieldWithDebounce(
          fieldName: 'username',
          value: 'taken',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error) {
            resultError = error;
            completed = true;
          },
        );

        expect(completed, isFalse);

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(completed, isTrue);
        expect(resultError, 'Username taken');
      });

      test('validateFieldWithDebounce should cancel previous timer when called rapidly', () async {
        final validators = <String, Validator>{
          'search': TestValidator<dynamic>((v, c) => 'Error for $v'),
        };

        int callCount = 0;
        String? finalError;

        formValidator.validateFieldWithDebounce(
          fieldName: 'search',
          value: 'first',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error) {
            callCount++;
            finalError = error;
          },
        );

        // Immediately update with second value before timer fires
        formValidator.validateFieldWithDebounce(
          fieldName: 'search',
          value: 'second',
          validators: validators,
          context: mockContext,
          onValidationComplete: (error) {
            callCount++;
            finalError = error;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callCount, 1);
        expect(finalError, 'Error for second');
      });

      test('validateFieldWithDebounce should return null if validator is null', () async {
        String? resultError;
        bool completed = false;

        formValidator.validateFieldWithDebounce(
          fieldName: 'noValidator',
          value: 'val',
          validators: {},
          context: mockContext,
          onValidationComplete: (error) {
            resultError = error;
            completed = true;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(completed, isTrue);
        expect(resultError, isNull);
      });

      test('validateAllFieldsWithDebounce should trigger callback with all field errors', () async {
        final validators = <String, Validator>{
          'f1': TestValidator<dynamic>((v, c) => 'Err 1'),
          'f2': TestValidator<dynamic>((v, c) => 'Err 2'),
        };

        Map<String, String>? resultErrors;

        formValidator.validateAllFieldsWithDebounce(
          values: {'f1': 'v1', 'f2': 'v2'},
          validators: validators,
          context: mockContext,
          onValidationComplete: (errors) {
            resultErrors = errors;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(resultErrors, {
          'f1': 'Err 1',
          'f2': 'Err 2',
        });
      });

      test('cancelFieldValidation should stop pending debounced validation', () async {
        bool completed = false;

        formValidator.validateFieldWithDebounce(
          fieldName: 'field1',
          value: 'val',
          validators: {
            'field1': TestValidator<dynamic>((v, c) => 'Err'),
          },
          context: mockContext,
          onValidationComplete: (error) {
            completed = true;
          },
        );

        formValidator.cancelFieldValidation('field1');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(completed, isFalse);
      });

      test('dispose should cancel all active timers cleanly', () async {
        bool completed1 = false;
        bool completed2 = false;

        formValidator.validateFieldWithDebounce(
          fieldName: 'field1',
          value: 'val',
          validators: {'field1': TestValidator<dynamic>((v, c) => 'Err')},
          context: mockContext,
          onValidationComplete: (_) => completed1 = true,
        );

        formValidator.validateAllFieldsWithDebounce(
          values: {'field1': 'val'},
          validators: {'field1': TestValidator<dynamic>((v, c) => 'Err')},
          context: mockContext,
          onValidationComplete: (_) => completed2 = true,
        );

        formValidator.dispose();

        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(completed1, isFalse);
        expect(completed2, isFalse);
      });
    });
  });
}
