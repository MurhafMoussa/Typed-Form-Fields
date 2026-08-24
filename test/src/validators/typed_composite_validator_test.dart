import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/validators/composite_validator.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

void main() {
  group('CompositeValidator', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('should return first error when multiple validators fail', () {
      final validator1 = MockValidator<String>();
      final validator2 = MockValidator<String>();

      validator1.mockValidate = (value, context) => 'First error';
      validator2.mockValidate = (value, context) => 'Second error';

      final composite = CompositeValidator<String>([validator1, validator2]);
      final result = composite.validate('test', mockContext);

      expect(result, 'First error');
    });

    test('should return null when all validators pass', () {
      final validator1 = MockValidator<String>();
      final validator2 = MockValidator<String>();

      validator1.mockValidate = (value, context) => null;
      validator2.mockValidate = (value, context) => null;

      final composite = CompositeValidator<String>([validator1, validator2]);
      final result = composite.validate('test', mockContext);

      expect(result, isNull);
    });

    test('should return null for empty validator list', () {
      final composite = CompositeValidator<String>([]);
      final result = composite.validate('test', mockContext);

      expect(result, isNull);
    });

    test('should stop at first error and not call subsequent validators', () {
      final validator1 = MockValidator<String>();
      final validator2 = MockValidator<String>();

      validator1.mockValidate = (value, context) => 'First error';
      validator2.mockValidate = (value, context) => 'Second error';

      final composite = CompositeValidator<String>([validator1, validator2]);
      composite.validate('test', mockContext);

      expect(validator1.callCount, 1);
      expect(validator2.callCount, 0); // Should not be called
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockValidator<T> implements Validator<T> {
  String? Function(T? value, BuildContext context)? mockValidate;
  int callCount = 0;

  @override
  String? validate(T? value, BuildContext context) {
    callCount++;
    return mockValidate?.call(value, context);
  }
}
