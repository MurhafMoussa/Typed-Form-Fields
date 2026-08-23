import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/validators/typed_common_validators.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('Validator', () {
    late MockValidator<String> validator;
    late MockBuildContext mockContext;

    setUp(() {
      validator = MockValidator<String>();
      mockContext = MockBuildContext();
    });

    test('should validate value and return error message', () {
      validator.mockValidate = (value, context) => 'Test error';

      final result = validator.validate('test', mockContext);

      expect(result, 'Test error');
    });

    test('should validate value and return null for valid input', () {
      validator.mockValidate = (value, context) => null;

      final result = validator.validate('valid', mockContext);

      expect(result, isNull);
    });

    test('should handle null value', () {
      validator.mockValidate =
          (value, context) => value == null ? 'Required field' : null;

      final result = validator.validate(null, mockContext);

      expect(result, 'Required field');
    });

    test('should create validator instance', () {
      // This test covers the constructor line that was missing coverage
      const validator = ConcreteValidator();
      expect(validator, isA<Validator<String>>());

      // Also test the validate method to ensure it works
      final result = validator.validate('test', mockContext);
      expect(result, isNull);
    });

    test('should create different types of validators', () {
      // Create multiple validators to ensure constructor coverage
      const stringValidator = ConcreteValidator();
      const intValidator = AnotherValidator();

      expect(stringValidator, isA<Validator<String>>());
      expect(intValidator, isA<Validator<int>>());

      // Test their functionality
      expect(stringValidator.validate('test', mockContext), isNull);
      expect(intValidator.validate(null, mockContext), 'Required');
      expect(intValidator.validate(42, mockContext), isNull);
    });

    test('should work with TypedCommonValidators implementation', () {
      final validator = TypedCommonValidators.required<String>();

      expect(validator, isA<Validator<String>>());
      expect(validator.validate(null, mockContext), 'This field is required.');
      expect(validator.validate('', mockContext), 'This field is required.');
      expect(validator.validate('test', mockContext), isNull);
    });
  });

  group('AsyncValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should create async validator instance and validate asynchronously',
        () async {
      const validator = ConcreteAsyncValidator();
      expect(validator, isA<AsyncValidator<String>>());

      final result = await validator.validate('taken@example.com', mockContext);
      expect(result, equals('Email is already taken'));

      final validResult =
          await validator.validate('available@example.com', mockContext);
      expect(validResult, isNull);
    });

    test('should support synchronous return in FutureOr', () {
      const validator = SyncReturnAsyncValidator();
      final result = validator.validate('invalid', mockContext);
      expect(result, equals('Invalid value'));
    });
  });
}

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

class ConcreteValidator extends Validator<String> {
  const ConcreteValidator();

  @override
  String? validate(String? value, BuildContext context) {
    return null;
  }
}

class AnotherValidator extends Validator<int> {
  const AnotherValidator();

  @override
  String? validate(int? value, BuildContext context) {
    return value == null ? 'Required' : null;
  }
}

class ConcreteAsyncValidator extends AsyncValidator<String> {
  const ConcreteAsyncValidator();

  @override
  FutureOr<String?> validate(String? value, BuildContext context) async {
    await Future<void>.delayed(Duration.zero);
    if (value == 'taken@example.com') {
      return 'Email is already taken';
    }
    return null;
  }
}

class SyncReturnAsyncValidator extends AsyncValidator<String> {
  const SyncReturnAsyncValidator();

  @override
  FutureOr<String?> validate(String? value, BuildContext context) {
    if (value == 'invalid') {
      return 'Invalid value';
    }
    return null;
  }
}
