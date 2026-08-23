import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MockBuildContext extends BuildContext {
  @override
  bool get mounted => true;

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

      // Now call updateFieldValidators without providing asyncValidators on field that already has asyncValidators
      controller.updateFieldValidators<String>(
        name: 'email',
        validators: [TestSyncValidator<String>((v, c) => 'Sync fail')],
        context: mockContext,
      );

      expect(controller.state.getError('email'), 'Sync fail');

      controller.close();
    });

    test('updateField under realTimeOnly validation strategy with async validators', () async {
      final asyncValidator = TestAsyncValidator<String>((value, context) async {
        return value == 'bad' ? 'Bad value' : null;
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
        validationStrategy: ValidationStrategy.realTimeOnly,
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      controller.updateField<String>(
        fieldName: 'email',
        value: 'bad',
        context: mockContext,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(asyncValidator.callCount, 1);
      expect(controller.state.getError('email'), 'Bad value');

      controller.close();
    });

    test('updateFieldWithDebounce triggers async validation when sync check passes or cancels when sync fails', () async {
      final syncValidator = TestSyncValidator<String>((v, c) => v == 'invalid' ? 'Invalid sync' : null);
      final asyncValidator = TestAsyncValidator<String>((v, c) async => 'Async error');

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'field1',
            validators: [syncValidator],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      // Case A: allFieldsRealTime with sync pass
      controller.updateFieldWithDebounce<String>(
        fieldName: 'field1',
        value: 'valid',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(asyncValidator.callCount, 1);

      // Case B: allFieldsRealTime with sync fail
      controller.updateFieldWithDebounce<String>(
        fieldName: 'field1',
        value: 'invalid',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(controller.state.getError('field1'), 'Invalid sync');

      // Case C: realTimeOnly strategy with sync pass
      controller.setValidationStrategy(ValidationStrategy.realTimeOnly);
      controller.updateFieldWithDebounce<String>(
        fieldName: 'field1',
        value: 'valid2',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(asyncValidator.callCount, 2);

      // Case D: realTimeOnly strategy with sync fail
      controller.updateFieldWithDebounce<String>(
        fieldName: 'field1',
        value: 'invalid',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(controller.state.getError('field1'), 'Invalid sync');

      controller.close();
    });

    test('updateFields under विभिन्न validation strategies and sync pass/fail', () async {
      final syncValidator = TestSyncValidator<String>((v, c) => v == 'bad_sync' ? 'Sync error' : null);
      final asyncValidator = TestAsyncValidator<String>((v, c) async => v == 'bad_async' ? 'Async error' : null);

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'f1',
            validators: [syncValidator],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
          FormFieldDefinition<String>(
            name: 'f2',
            validators: [],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      // Strategy onSubmitOnly
      controller.setValidationStrategy(ValidationStrategy.onSubmitOnly);
      controller.updateFields<String>(
        fieldValues: {'f1': 'bad_async', 'f2': 'val'},
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(asyncValidator.callCount, 0);

      // Strategy allFieldsRealTime with sync pass
      controller.setValidationStrategy(ValidationStrategy.allFieldsRealTime);
      controller.updateFields<String>(
        fieldValues: {'f1': 'bad_async', 'f2': 'val'},
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(asyncValidator.callCount, 1);
      expect(controller.state.getError('f1'), 'Async error');

      // Strategy allFieldsRealTime with sync fail
      controller.updateFields<String>(
        fieldValues: {'f1': 'bad_sync', 'f2': 'val'},
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(controller.state.getError('f1'), 'Sync error');

      // Strategy realTimeOnly with sync pass
      controller.setValidationStrategy(ValidationStrategy.realTimeOnly);
      controller.updateFields<String>(
        fieldValues: {'f1': 'bad_async', 'f2': 'val'},
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(asyncValidator.callCount, 2);

      // Strategy realTimeOnly with sync fail
      controller.updateFields<String>(
        fieldValues: {'f1': 'bad_sync', 'f2': 'val'},
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(controller.state.getError('f1'), 'Sync error');

      controller.close();
    });

    test('validateFieldImmediately for field without sync validators', () async {
      final asyncValidator = TestAsyncValidator<String>((v, c) async => 'Async err');

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'noSyncWithAsync',
            validators: [],
            asyncValidators: [asyncValidator],
            initialValue: '',
          ),
          FormFieldDefinition<String>(
            name: 'noSyncNoAsync',
            validators: [],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 500),
      );

      controller.validateFieldImmediately(
        fieldName: 'noSyncWithAsync',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(asyncValidator.callCount, 1);

      controller.validateFieldImmediately(
        fieldName: 'noSyncNoAsync',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.state.getError('noSyncNoAsync'), isNull);

      controller.close();
    });

    test('Token invalidation mid-flight and in catch block removes active field and exits', () async {
      final completer1 = Completer<String?>();
      final asyncVal1 = TestAsyncValidator<String>((v, c) => completer1.future);

      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'f1',
            validators: [],
            asyncValidators: [asyncVal1],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      // Start async check
      controller.updateField<String>(
        fieldName: 'f1',
        value: 'first',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(controller.state.validatingFields, contains('f1'));

      // Invalidate token mid-flight by updating field value again
      controller.updateField<String>(
        fieldName: 'f1',
        value: 'second',
        context: mockContext,
      );

      // Complete first check mid-flight (now stale token)
      completer1.complete('stale error');
      await Future<void>.delayed(Duration.zero);

      // Second check runs and completes
      await Future<void>.delayed(const Duration(milliseconds: 100));

      controller.close();
    });

    test('Mid-flight exception with stale token exits cleanly', () async {
      final completer = Completer<String?>();
      final asyncVal = TestAsyncValidator<String>((v, c) async {
        if (v == 'val1') {
          await completer.future;
          throw Exception('Throw after wait');
        }
        return null;
      });

      bool errorCalled = false;
      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'f1',
            validators: [],
            asyncValidators: [asyncVal],
            initialValue: '',
          ),
        ],
        asyncDebounceDelay: const Duration(milliseconds: 50),
        onAsyncValidationError: (_, __, ___) => errorCalled = true,
      );

      controller.updateField<String>(
        fieldName: 'f1',
        value: 'val1',
        context: mockContext,
      );
      await Future<void>.delayed(const Duration(milliseconds: 70));

      // Invalidate token before exception is thrown by updating field to val2 (which does not throw)
      controller.updateField<String>(
        fieldName: 'f1',
        value: 'val2',
        context: mockContext,
      );

      // Throw exception on first task (stale token)
      completer.complete('done');
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // Callback should not be called for stale exception
      expect(errorCalled, isFalse);

      controller.close();
    });

    test('updateFieldWithDebounce under realTimeOnly strategy for field without asyncValidators', () async {
      final controller = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'noAsync',
            validators: [],
            initialValue: '',
          ),
        ],
        validationStrategy: ValidationStrategy.realTimeOnly,
        asyncDebounceDelay: const Duration(milliseconds: 50),
      );

      controller.updateFieldWithDebounce<String>(
        fieldName: 'noAsync',
        value: 'hello',
        context: mockContext,
      );

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(controller.state.getError('noAsync'), isNull);

      controller.close();
    });

    group('Submission and Reset Lifecycle', () {
      test('Form submission flushes active debounce timers immediately and awaits async validation', () async {
        bool passCalled = false;
        bool failCalled = false;

        final asyncValidator = TestAsyncValidator<String>((value, context) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return value == 'valid@test.com' ? null : 'Invalid email';
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
          asyncDebounceDelay: const Duration(milliseconds: 500),
        );

        // Update field value (starts 500ms debounce timer)
        controller.updateField<String>(
          fieldName: 'email',
          value: 'valid@test.com',
          context: mockContext,
        );

        expect(asyncValidator.callCount, 0);

        // Submit form almost immediately at t=30ms (well before 500ms debounce)
        await Future<void>.delayed(const Duration(milliseconds: 30));
        expect(asyncValidator.callCount, 0);

        final submitFuture = controller.validateForm(
          mockContext,
          onValidationPass: () => passCalled = true,
          onValidationFail: () => failCalled = true,
        );

        await submitFuture;

        expect(asyncValidator.callCount, 1);
        expect(passCalled, isTrue);
        expect(failCalled, isFalse);
        expect(controller.state.validatingFields, isEmpty);
        expect(controller.state.isValid, isTrue);

        controller.close();
      });

      test('Form submission awaits in-flight async validation and calls onValidationFail when invalid', () async {
        bool passCalled = false;
        bool failCalled = false;

        final asyncValidator = TestAsyncValidator<String>((value, context) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return value == 'taken' ? 'Username already taken' : null;
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
          asyncDebounceDelay: const Duration(milliseconds: 20),
        );

        controller.updateField<String>(
          fieldName: 'username',
          value: 'taken',
          context: mockContext,
        );

        // Wait for debounce (20ms) to fire so async check is in flight
        await Future<void>.delayed(const Duration(milliseconds: 35));
        expect(controller.state.validatingFields, contains('username'));

        // Call submission while async check is in flight
        await controller.validateForm(
          mockContext,
          onValidationPass: () => passCalled = true,
          onValidationFail: () => failCalled = true,
        );

        expect(passCalled, isFalse);
        expect(failCalled, isTrue);
        expect(controller.state.getError('username'), 'Username already taken');
        expect(controller.state.validatingFields, isEmpty);

        controller.close();
      });

      test('Form reset cancels active debounced and in-flight async tasks and clears validatingFields immediately', () async {
        final completer = Completer<String?>();
        final asyncValidator = TestAsyncValidator<String>((value, context) {
          return completer.future;
        });

        final controller = TypedFormController(
          fields: [
            FormFieldDefinition<String>(
              name: 'username',
              validators: [],
              asyncValidators: [asyncValidator],
              initialValue: 'initial_val',
            ),
          ],
          asyncDebounceDelay: const Duration(milliseconds: 30),
        );

        controller.updateField<String>(
          fieldName: 'username',
          value: 'new_val',
          context: mockContext,
        );

        // Wait for debounce timer to fire
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(controller.state.validatingFields, contains('username'));

        // Reset form while async validation is in flight
        controller.resetForm();

        expect(controller.state.validatingFields, isEmpty);
        expect(controller.state.isValidating, isFalse);
        expect(controller.state.getValue<String>('username'), 'initial_val');
        expect(controller.state.errors, isEmpty);

        // Complete the in-flight future with an error after reset
        completer.complete('Late error');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // The late error should be ignored and not reflected in form state
        expect(controller.state.getError('username'), isNull);
        expect(controller.state.validatingFields, isEmpty);

        controller.close();
      });

      test('Form reset cancels pending debounce timers before execution', () async {
        final asyncValidator = TestAsyncValidator<String>((value, context) async {
          return 'Should never run';
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
          asyncDebounceDelay: const Duration(milliseconds: 300),
        );

        controller.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: mockContext,
        );

        // Reset form immediately before 300ms debounce expires
        controller.resetForm();

        await Future<void>.delayed(const Duration(milliseconds: 400));

        expect(asyncValidator.callCount, 0);
        expect(controller.state.validatingFields, isEmpty);

        controller.close();
      });

      test('Form submission with multiple async fields flushes and awaits all fields concurrently', () async {
        bool passCalled = false;

        final userValidator = TestAsyncValidator<String>((value, context) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return null;
        });

        final emailValidator = TestAsyncValidator<String>((value, context) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return null;
        });

        final controller = TypedFormController(
          fields: [
            FormFieldDefinition<String>(
              name: 'username',
              validators: [],
              asyncValidators: [userValidator],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'email',
              validators: [],
              asyncValidators: [emailValidator],
              initialValue: '',
            ),
          ],
          asyncDebounceDelay: const Duration(milliseconds: 400),
        );

        controller.updateField<String>(
          fieldName: 'username',
          value: 'john',
          context: mockContext,
        );
        controller.updateField<String>(
          fieldName: 'email',
          value: 'john@example.com',
          context: mockContext,
        );

        // Submit form while both are debouncing
        await controller.validateForm(
          mockContext,
          onValidationPass: () => passCalled = true,
        );

        expect(userValidator.callCount, 1);
        expect(emailValidator.callCount, 1);
        expect(passCalled, isTrue);
        expect(controller.state.validatingFields, isEmpty);

        controller.close();
      });

      test('Form submission under ValidationStrategy.onSubmitOnly schedules and awaits async validation for fields passing sync check', () async {
        bool passCalled = false;

        final asyncValidator = TestAsyncValidator<String>((value, context) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return value == 'valid' ? null : 'Invalid value';
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
          validationStrategy: ValidationStrategy.onSubmitOnly,
        );

        controller.updateField<String>(
          fieldName: 'username',
          value: 'valid',
          context: mockContext,
        );

        // In onSubmitOnly mode, updateField does NOT schedule async validation
        expect(asyncValidator.callCount, 0);

        // Call validateForm -> schedules async validation and awaits it
        await controller.validateForm(
          mockContext,
          onValidationPass: () => passCalled = true,
        );

        expect(asyncValidator.callCount, 1);
        expect(passCalled, isTrue);

        controller.close();
      });
    });
  });
}
