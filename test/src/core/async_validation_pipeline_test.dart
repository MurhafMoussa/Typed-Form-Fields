import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestSyncValidator<T> implements Validator<T> {
  TestSyncValidator(this.onValidate);

  final String? Function(T? value, BuildContext context) onValidate;

  @override
  String? validate(T? value, BuildContext context) {
    return onValidate(value, context);
  }
}

class TestAsyncValidator<T> implements AsyncValidator<T> {
  TestAsyncValidator(this.onValidate);

  final FutureOr<String?> Function(T? value, BuildContext context) onValidate;
  int callCount = 0;
  T? lastValueValidated;

  @override
  FutureOr<String?> validate(T? value, BuildContext context) {
    callCount++;
    lastValueValidated = value;
    return onValidate(value, context);
  }
}

void main() {
  group('Async Validation Pipeline', () {
    late MockBuildContext mockContext;

    setUp(() {
      mockContext = MockBuildContext();
    });

    test('TypedFormController supports asyncDebounceDelay and onAsyncValidationError', () {
      Object? caughtError;
      StackTrace? caughtStack;
      String? caughtField;

      final controller = TypedFormController(
        asyncDebounceDelay: const Duration(milliseconds: 150),
        onAsyncValidationError: (error, stack, fieldName) {
          caughtError = error;
          caughtStack = stack;
          caughtField = fieldName;
        },
      );

      expect(controller.asyncDebounceDelay, const Duration(milliseconds: 150));
      expect(controller.onAsyncValidationError, isNotNull);

      // Trigger callback manually
      const stack = StackTrace.empty;
      controller.onAsyncValidationError?.call('test error', stack, 'email');
      expect(caughtError, 'test error');
      expect(caughtStack, stack);
      expect(caughtField, 'email');

      controller.close();
    });

    test('Synchronous validation runs first; if sync validation fails, async validation is skipped', () async {
      final syncValidator = TestSyncValidator<String>((value, context) {
        if (value == null || value.isEmpty) return 'Value is required';
        return null;
      });

      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        return value == 'taken' ? 'Already taken' : null;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'username',
            validators: [syncValidator],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      // Update field with invalid sync value
      controller.updateField<String>(
        fieldName: 'username',
        value: '',
        context: mockContext,
      );

      expect(controller.state.getError('username'), 'Value is required');
      expect(controller.state.validatingFields, isEmpty);

      // Wait longer than debounce delay
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(asyncValidator.callCount, 0); // Skipped!
      expect(controller.state.getError('username'), 'Value is required');
      expect(controller.state.validatingFields, isEmpty);

      controller.close();
    });

    test('Debouncing delays async validator execution by asyncDebounceDelay', () async {
      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        return value == 'taken' ? 'Already taken' : null;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'username',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 100),
      );

      controller.updateField<String>(
        fieldName: 'username',
        value: 'john',
        context: mockContext,
      );

      // Immediately after update, async validator should not have run yet
      expect(asyncValidator.callCount, 0);
      expect(controller.state.validatingFields, isEmpty);

      // Wait 50ms (before 100ms debounce)
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(asyncValidator.callCount, 0);

      // Wait remaining 100ms
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(asyncValidator.callCount, 1);
      expect(asyncValidator.lastValueValidated, 'john');
      expect(controller.state.getError('username'), isNull);
      expect(controller.state.validatingFields, isEmpty);

      controller.close();
    });

    test('Fast value updates cancel previous pending async tasks without emitting stale errors', () async {
      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'Error for $value';
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'search',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 100),
      );

      // Rapid typing
      controller.updateField<String>(
        fieldName: 'search',
        value: 'a',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      controller.updateField<String>(
        fieldName: 'search',
        value: 'ab',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));

      controller.updateField<String>(
        fieldName: 'search',
        value: 'abc',
        context: mockContext,
      );

      // Wait for debounce + async execution
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Only 'abc' should have been validated
      expect(asyncValidator.callCount, 1);
      expect(asyncValidator.lastValueValidated, 'abc');
      expect(controller.state.getError('search'), 'Error for abc');

      controller.close();
    });

    test('In-flight async task is canceled when new value is typed before completion', () async {
      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        // Slow async check
        await Future<void>.delayed(const Duration(milliseconds: 150));
        return 'Error for $value';
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      // Type first value
      controller.updateField<String>(
        fieldName: 'email',
        value: 'first@example.com',
        context: mockContext,
      );

      // Wait for debounce timer (50ms) to fire and start in-flight async check
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(controller.state.validatingFields, contains('email'));

      // While in-flight, type second value
      controller.updateField<String>(
        fieldName: 'email',
        value: 'second@example.com',
        context: mockContext,
      );

      // Wait for first task to finish (150ms total) and second task debounce/run
      await Future<void>.delayed(const Duration(milliseconds: 250));

      // Second check should have finished and set error for 'second@example.com'
      expect(controller.state.getError('email'), 'Error for second@example.com');
      expect(controller.state.validatingFields, isEmpty);

      controller.close();
    });

    test('Field names enter validatingFields during active async validation and leave when completed', () async {
      final asyncCompleter = Completer<String?>();
      final asyncValidator = TestAsyncValidator<String>((value, context) {
        return asyncCompleter.future;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      expect(controller.state.validatingFields, isEmpty);
      expect(controller.state.isValidating, isFalse);

      controller.updateField<String>(
        fieldName: 'email',
        value: 'test@example.com',
        context: mockContext,
      );

      // Wait for debounce
      await Future<void>.delayed(const Duration(milliseconds: 70));

      // Now active async validation is running
      expect(controller.state.validatingFields, contains('email'));
      expect(controller.state.isValidating, isTrue);

      // Complete the async validation
      asyncCompleter.complete(null);
      await Future<void>.delayed(Duration.zero);

      // Validation completed
      expect(controller.state.validatingFields, isEmpty);
      expect(controller.state.isValidating, isFalse);

      controller.close();
    });

    test('Exceptions in async validators set localized fallback error, clear validatingFields, and trigger onAsyncValidationError', () async {
      Object? caughtError;
      StackTrace? caughtStack;
      String? caughtField;

      final exception = Exception('Database connection failed');

      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        throw exception;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'username',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
        onAsyncValidationError: (error, stack, fieldName) {
          caughtError = error;
          caughtStack = stack;
          caughtField = fieldName;
        },
      );

      controller.updateField<String>(
        fieldName: 'username',
        value: 'john',
        context: mockContext,
      );

      // Wait for debounce + exception
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(caughtError, equals(exception));
      expect(caughtStack, isNotNull);
      expect(caughtField, 'username');

      // Fallback localized error is set
      expect(controller.state.getError('username'), isNotNull);
      expect(controller.state.validatingFields, isEmpty);
      expect(controller.state.isValidating, isFalse);

      controller.close();
    });

    test('Multiple async validators on a single field run sequentially', () async {
      final logs = <String>[];

      final val1 = TestAsyncValidator<String>((value, context) async {
        logs.add('val1 start');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        logs.add('val1 end');
        return null;
      });

      final val2 = TestAsyncValidator<String>((value, context) async {
        logs.add('val2 start');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        logs.add('val2 end');
        return 'val2 error';
      });

      final val3 = TestAsyncValidator<String>((value, context) async {
        logs.add('val3 start');
        return null;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'code',
            validators: [],
            asyncValidators: [val1, val2, val3],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      controller.updateField<String>(
        fieldName: 'code',
        value: '1234',
        context: mockContext,
      );

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(logs, [
        'val1 start',
        'val1 end',
        'val2 start',
        'val2 end',
      ]); // val3 was not run because val2 failed!

      expect(controller.state.getError('code'), 'val2 error');
      expect(controller.state.validatingFields, isEmpty);

      controller.close();
    });

    test('validateFieldImmediately runs async validation immediately with Duration.zero debounce', () async {
      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        return value == 'invalid' ? 'Immediate error' : null;
      });

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: 'initial',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 500),
      );

      controller.validateFieldImmediately(
        fieldName: 'email',
        context: mockContext,
      );

      // Wait a microtask / tick
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(asyncValidator.callCount, 1);

      controller.close();
    });

    test('updateFieldValidators updates async validators dynamically', () async {
      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [],
            initialValue: 'test@example.com',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        return 'Dynamic error';
      });

      controller.updateFieldValidators<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncValidator],
        context: mockContext,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(asyncValidator.callCount, 1);
      expect(controller.state.getError('email'), 'Dynamic error');

      controller.close();
    });
  });
}
