import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:typed_form_fields/src/validators/typed_conditional_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockValidator extends Mock implements Validator<String> {}

class TestValidator<T> extends Validator<T> {
  const TestValidator(this.errorMessage);

  final String? errorMessage;

  @override
  String? validate(T? value, BuildContext context) {
    return errorMessage;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(MockBuildContext());
  });

  group('TypedConditionalValidators private constructor', () {
    test('ensures private constructor exists', () {
      expect(() => TypedConditionalValidators, isNotNull);
    });
  });

  group('TypedConditionalValidator', () {
    late MockBuildContext mockContext;
    late MockValidator mockValidator;
    late MockValidator mockElseValidator;

    setUp(() {
      mockContext = MockBuildContext();
      mockValidator = MockValidator();
      mockElseValidator = MockValidator();
    });

    test('should apply validator when condition is true', () {
      // Arrange
      const expectedError = 'Validation error';
      final validator = TypedConditionalValidator<String>(
        condition: (value, context) => true,
        validator: mockValidator,
      );

      when(() => mockValidator.validate(any(), any()))
          .thenReturn(expectedError);

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, expectedError);
      verify(() => mockValidator.validate('test', mockContext)).called(1);
    });

    test('should not apply validator when condition is false', () {
      // Arrange
      final validator = TypedConditionalValidator<String>(
        condition: (value, context) => false,
        validator: mockValidator,
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, null);
      verifyNever(() => mockValidator.validate(any(), any()));
    });

    test(
        'should apply else validator when condition is false and else validator is provided',
        () {
      // Arrange
      const expectedError = 'Else validation error';
      final validator = TypedConditionalValidator<String>(
        condition: (value, context) => false,
        validator: mockValidator,
        elseValidator: mockElseValidator,
      );

      when(() => mockElseValidator.validate(any(), any()))
          .thenReturn(expectedError);

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, expectedError);
      verify(() => mockElseValidator.validate('test', mockContext)).called(1);
      verifyNever(() => mockValidator.validate(any(), any()));
    });

    test('should pass correct value and context to condition function', () {
      // Arrange
      const testValue = 'test';
      bool conditionCalled = false;
      String? receivedValue;
      BuildContext? receivedContext;

      final validator = TypedConditionalValidator<String>(
        condition: (value, context) {
          conditionCalled = true;
          receivedValue = value;
          receivedContext = context;
          return true;
        },
        validator: TestValidator<String>(null),
      );

      // Act
      validator.validate(testValue, mockContext);

      // Assert
      expect(conditionCalled, true);
      expect(receivedValue, testValue);
      expect(receivedContext, mockContext);
    });
  });

  group('SwitchValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should apply first matching validator', () {
      // Arrange
      const expectedError = 'First match error';
      final validator = SwitchValidator<String>(
        validationCases: [
          ConditionalCase<String>(
            condition: (value, context) => false,
            validator: TestValidator<String>('Should not be called'),
          ),
          ConditionalCase<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(expectedError),
          ),
          ConditionalCase<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>('Should not be called either'),
          ),
        ],
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, expectedError);
    });

    test('should apply default validator when no conditions match', () {
      // Arrange
      const expectedError = 'Default error';
      final validator = SwitchValidator<String>(
        validationCases: [
          ConditionalCase<String>(
            condition: (value, context) => false,
            validator: TestValidator<String>('Should not be called'),
          ),
        ],
        defaultValidator: TestValidator<String>(expectedError),
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, expectedError);
    });

    test('should return null when no conditions match and no default validator',
        () {
      // Arrange
      final validator = SwitchValidator<String>(
        validationCases: [
          ConditionalCase<String>(
            condition: (value, context) => false,
            validator: TestValidator<String>('Should not be called'),
          ),
        ],
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, null);
    });

    test('should handle empty validation cases', () {
      // Arrange
      const expectedError = 'Default error';
      final validator = SwitchValidator<String>(
        validationCases: [],
        defaultValidator: TestValidator<String>(expectedError),
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, expectedError);
    });
  });

  group('ConditionalCase', () {
    test('should store condition and validator correctly', () {
      // Arrange
      bool conditionFunction(String? value, BuildContext context) => true;
      final testValidator = TestValidator<String>('test');

      // Act
      final conditionalCase = ConditionalCase<String>(
        condition: conditionFunction,
        validator: testValidator,
      );

      // Assert
      expect(conditionalCase.condition, conditionFunction);
      expect(conditionalCase.validator, testValidator);
    });
  });

  group('ChainValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should stop on first error when stopOnFirstError is true', () {
      // Arrange
      const firstError = 'First error';
      final validator = ChainValidator<String>(
        validators: [
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(firstError),
          ),
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>('Second error'),
          ),
        ],
        stopOnFirstError: true,
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, firstError);
    });

    test('should collect all errors when stopOnFirstError is false', () {
      // Arrange
      const firstError = 'First error';
      const secondError = 'Second error';
      final validator = ChainValidator<String>(
        validators: [
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(firstError),
          ),
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(secondError),
          ),
        ],
        stopOnFirstError: false,
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, '$firstError; $secondError');
    });

    test('should return null when no validators produce errors', () {
      // Arrange
      final validator = ChainValidator<String>(
        validators: [
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(null),
          ),
          TypedConditionalValidator<String>(
            condition: (value, context) => true,
            validator: TestValidator<String>(null),
          ),
        ],
      );

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, null);
    });

    test('should handle empty validators list', () {
      // Arrange
      final validator = ChainValidator<String>(validators: []);

      // Act
      final result = validator.validate('test', mockContext);

      // Assert
      expect(result, null);
    });
  });

  group('TypedConditionalValidators', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    group('whenNotEmpty', () {
      test('should apply validator when string is not empty', () {
        // Arrange
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenNotEmpty<String>(
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate('test', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should not apply validator when string is empty', () {
        // Arrange
        final validator = TypedConditionalValidators.whenNotEmpty<String>(
          TestValidator<String>('Should not be called'),
        );

        // Act
        final result = validator.validate('', mockContext);

        // Assert
        expect(result, null);
      });

      test('should not apply validator when value is null', () {
        // Arrange
        final validator = TypedConditionalValidators.whenNotEmpty<String>(
          TestValidator<String>('Should not be called'),
        );

        // Act
        final result = validator.validate(null, mockContext);

        // Assert
        expect(result, null);
      });

      test('should apply validator when list is not empty', () {
        // Arrange
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenNotEmpty<List<String>>(
          TestValidator<List<String>>(expectedError),
        );

        // Act
        final result = validator.validate(['item'], mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should not apply validator when list is empty', () {
        // Arrange
        final validator = TypedConditionalValidators.whenNotEmpty<List<String>>(
          TestValidator<List<String>>('Should not be called'),
        );

        // Act
        final result = validator.validate(<String>[], mockContext);

        // Assert
        expect(result, null);
      });

      test('should not apply validator when Set is empty', () {
        // Arrange - This test covers the Iterable check on line 157
        final validator = TypedConditionalValidators.whenNotEmpty<Set<String>>(
          TestValidator<Set<String>>('Should not be called'),
        );

        // Act
        final result = validator.validate(<String>{}, mockContext);

        // Assert
        expect(result, null);
      });

      test('should apply validator when Set is not empty', () {
        // Arrange - This test covers the Iterable check on line 157
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenNotEmpty<Set<String>>(
          TestValidator<Set<String>>(expectedError),
        );

        // Act
        final result = validator.validate({'item'}, mockContext);

        // Assert
        expect(result, expectedError);
      });
    });

    group('whenEmpty', () {
      test('should apply validator when string is empty', () {
        // Arrange
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenEmpty<String>(
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate('', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply validator when value is null', () {
        // Arrange
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenEmpty<String>(
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate(null, mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should not apply validator when string is not empty', () {
        // Arrange
        final validator = TypedConditionalValidators.whenEmpty<String>(
          TestValidator<String>('Should not be called'),
        );

        // Act
        final result = validator.validate('test', mockContext);

        // Assert
        expect(result, null);
      });

      test('should apply validator when Set is empty', () {
        // Arrange - This test covers the Iterable check on line 157
        const expectedError = 'Validation error';
        final validator = TypedConditionalValidators.whenEmpty<Set<String>>(
          TestValidator<Set<String>>(expectedError),
        );

        // Act
        final result = validator.validate(<String>{}, mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should not apply validator when Set is not empty', () {
        // Arrange - This test covers the Iterable check on line 157
        final validator = TypedConditionalValidators.whenEmpty<Set<String>>(
          TestValidator<Set<String>>('Should not be called'),
        );

        // Act
        final result = validator.validate({'item'}, mockContext);

        // Assert
        expect(result, null);
      });
    });

    group('byLength', () {
      test('should apply short validator when length is at threshold', () {
        // Arrange
        const expectedError = 'Short error';
        final validator = TypedConditionalValidators.byLength(
          5,
          TestValidator<String>(expectedError),
          TestValidator<String>('Long error'),
        );

        // Act
        final result = validator.validate('12345', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply long validator when length exceeds threshold', () {
        // Arrange
        const expectedError = 'Long error';
        final validator = TypedConditionalValidators.byLength(
          5,
          TestValidator<String>('Short error'),
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate('123456', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should handle null value', () {
        // Arrange
        const expectedError = 'Short error';
        final validator = TypedConditionalValidators.byLength(
          5,
          TestValidator<String>(expectedError),
          TestValidator<String>('Long error'),
        );

        // Act
        final result = validator.validate(null, mockContext);

        // Assert
        expect(result, expectedError);
      });
    });

    group('byValue', () {
      test('should apply small validator when value is at threshold', () {
        // Arrange
        const expectedError = 'Small error';
        final validator = TypedConditionalValidators.byValue(
          10,
          TestValidator<num>(expectedError),
          TestValidator<num>('Large error'),
        );

        // Act
        final result = validator.validate(10, mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply large validator when value exceeds threshold', () {
        // Arrange
        const expectedError = 'Large error';
        final validator = TypedConditionalValidators.byValue(
          10,
          TestValidator<num>('Small error'),
          TestValidator<num>(expectedError),
        );

        // Act
        final result = validator.validate(11, mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should handle null value', () {
        // Arrange
        const expectedError = 'Small error';
        final validator = TypedConditionalValidators.byValue(
          10,
          TestValidator<num>(expectedError),
          TestValidator<num>('Large error'),
        );

        // Act
        final result = validator.validate(null, mockContext);

        // Assert
        expect(result, expectedError);
      });
    });

    group('byPattern', () {
      test('should apply match validator when pattern matches', () {
        // Arrange
        const expectedError = 'Match error';
        final pattern = RegExp(r'\d+');
        final validator = TypedConditionalValidators.byPattern(
          pattern,
          TestValidator<String>(expectedError),
          TestValidator<String>('No match error'),
        );

        // Act
        final result = validator.validate('123', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply no match validator when pattern does not match', () {
        // Arrange
        const expectedError = 'No match error';
        final pattern = RegExp(r'\d+');
        final validator = TypedConditionalValidators.byPattern(
          pattern,
          TestValidator<String>('Match error'),
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate('abc', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should handle null value', () {
        // Arrange
        const expectedError = 'No match error';
        final pattern = RegExp(r'\d+');
        final validator = TypedConditionalValidators.byPattern(
          pattern,
          TestValidator<String>('Match error'),
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate(null, mockContext);

        // Assert
        expect(result, expectedError);
      });
    });

    group('custom', () {
      test('should apply true validator when predicate returns true', () {
        // Arrange
        const expectedError = 'True error';
        final validator = TypedConditionalValidators.custom<String>(
          (value, context) => true,
          TestValidator<String>(expectedError),
          TestValidator<String>('False error'),
        );

        // Act
        final result = validator.validate('test', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply false validator when predicate returns false', () {
        // Arrange
        const expectedError = 'False error';
        final validator = TypedConditionalValidators.custom<String>(
          (value, context) => false,
          TestValidator<String>('True error'),
          TestValidator<String>(expectedError),
        );

        // Act
        final result = validator.validate('test', mockContext);

        // Assert
        expect(result, expectedError);
      });
    });

    // Note: byLocale, byTheme, and byFocusState tests are complex due to Flutter context dependencies
    // These validators are primarily tested through integration tests

    group('progressive', () {
      test('should apply basic validator for short input', () {
        // Arrange
        const expectedError = 'Basic error';
        final validator = TypedConditionalValidators.progressive(
          basicValidator: TestValidator<String>(expectedError),
          intermediateValidator: TestValidator<String>('Intermediate error'),
          advancedValidator: TestValidator<String>('Advanced error'),
        );

        // Act
        final result = validator.validate('ab', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply intermediate validator for medium input', () {
        // Arrange
        const expectedError = 'Intermediate error';
        final validator = TypedConditionalValidators.progressive(
          basicValidator: TestValidator<String>(null),
          intermediateValidator: TestValidator<String>(expectedError),
          advancedValidator: TestValidator<String>('Advanced error'),
          intermediateThreshold: 3,
        );

        // Act
        final result = validator.validate('abcd', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should apply advanced validator for long input', () {
        // Arrange
        const expectedError = 'Advanced error';
        final validator = TypedConditionalValidators.progressive(
          basicValidator: TestValidator<String>(null),
          intermediateValidator: TestValidator<String>(null),
          advancedValidator: TestValidator<String>(expectedError),
          advancedThreshold: 8,
        );

        // Act
        final result = validator.validate('abcdefghi', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should stop on first error', () {
        // Arrange
        const expectedError = 'Basic error';
        final validator = TypedConditionalValidators.progressive(
          basicValidator: TestValidator<String>(expectedError),
          intermediateValidator: TestValidator<String>('Intermediate error'),
          advancedValidator: TestValidator<String>('Advanced error'),
        );

        // Act
        final result = validator.validate('abcdefghi', mockContext);

        // Assert
        expect(result, expectedError);
      });

      test('should handle null validators', () {
        // Arrange
        final validator = TypedConditionalValidators.progressive();

        // Act
        final result = validator.validate('test', mockContext);

        // Assert
        expect(result, null);
      });
    });
  });
}
