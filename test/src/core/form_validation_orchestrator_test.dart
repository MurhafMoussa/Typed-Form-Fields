import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_errors.dart';
import 'package:typed_form_fields/src/core/form_field_registry.dart';
import 'package:typed_form_fields/src/core/form_touched_tracker.dart';
import 'package:typed_form_fields/src/core/form_validation_orchestrator.dart';
import 'package:typed_form_fields/src/core/form_validator.dart';
import 'package:typed_form_fields/src/core/typed_form_state.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
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

class TestAsyncValidator<T> implements AsyncValidator<T> {
  TestAsyncValidator(this.onValidate);

  final Future<String?> Function(T? value, BuildContext context) onValidate;

  @override
  Future<String?> validate(T? value, BuildContext context) {
    return onValidate(value, context);
  }
}

void main() {
  group('FormValidationOrchestrator', () {
    late FormFieldRegistry registry;
    late FormTouchedTracker touchedTracker;
    late FormValidator validator;
    late FormValidationOrchestrator orchestrator;
    late MockBuildContext mockContext;
    Object? capturedAsyncError;
    StackTrace? capturedAsyncStackTrace;
    String? capturedAsyncFieldName;

    setUp(() {
      capturedAsyncError = null;
      capturedAsyncStackTrace = null;
      capturedAsyncFieldName = null;

      final fields = [
        FormFieldDefinition<String>(
          name: 'username',
          group: 'account',
          initialValue: '',
          validators: [
            TestValidator<String>(
              (v, c) => (v == null || v.isEmpty) ? 'Username required' : null,
            ),
          ],
        ),
        FormFieldDefinition<String>(
          name: 'email',
          group: 'account',
          initialValue: '',
          validators: [
            TestValidator<String>(
              (v, c) => (v == null || v.contains('@') == false)
                  ? 'Invalid email'
                  : null,
            ),
          ],
        ),
        FormFieldDefinition<int>(
          name: 'age',
          group: 'profile',
          initialValue: 0,
          validators: [
            TestValidator<int>(
              (v, c) => (v == null || v < 18) ? 'Must be 18+' : null,
            ),
          ],
        ),
        const FormFieldDefinition<String>(
          name: 'optionalNote',
          group: 'profile',
          initialValue: '',
          validators: [],
        ),
      ];

      registry = FormFieldRegistry(fields);
      touchedTracker = FormTouchedTracker(fields.map((f) => f.name));
      validator = FormValidator(debounceDelay: const Duration(milliseconds: 10));
      mockContext = MockBuildContext();

      orchestrator = FormValidationOrchestrator(
        registry: registry,
        touchedTracker: touchedTracker,
        validator: validator,
        asyncDebounceDelay: const Duration(milliseconds: 10),
        onAsyncValidationError: (error, stackTrace, fieldName) {
          capturedAsyncError = error;
          capturedAsyncStackTrace = stackTrace;
          capturedAsyncFieldName = fieldName;
        },
      );
    });

    tearDown(() {
      validator.dispose();
    });

    TypedFormState createInitialState({
      ValidationStrategy strategy = ValidationStrategy.allFieldsRealTime,
    }) {
      return TypedFormState(
        values: registry.initialValues,
        errors: const {},
        isValid: strategy.initialValidationState,
        validationStrategy: strategy,
        fieldTypes: registry.fieldTypes,
      );
    }

    group('updateField', () {
      test('throws FormFieldError.fieldNotFound if field is not registered', () {
        final state = createInitialState();
        expect(
          () => orchestrator.updateField<String>(
            fieldName: 'nonExistent',
            value: 'val',
            context: mockContext,
            state: state,
            getState: () => state,
            emitState: (_) {},
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('throws FormFieldError.typeMismatch on type mismatch', () {
        final state = createInitialState();
        expect(
          () => orchestrator.updateField<String>(
            fieldName: 'age',
            value: 'not an int' as dynamic,
            context: mockContext,
            state: state,
            getState: () => state,
            emitState: (_) {},
          ),
          throwsA(isA<FormFieldError>()),
        );
      });

      test('onSubmitOnly cancels async validation and updates values', () {
        final state = createInitialState(strategy: ValidationStrategy.onSubmitOnly);
        final newState = orchestrator.updateField<String>(
          fieldName: 'username',
          value: 'john',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.values['username'], 'john');
        expect(touchedTracker.isTouched('username'), isTrue);
      });

      test('onSubmitThenRealTime cancels async validation and updates values', () {
        final state = createInitialState(
          strategy: ValidationStrategy.onSubmitThenRealTime,
        );
        final newState = orchestrator.updateField<String>(
          fieldName: 'username',
          value: 'john',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.values['username'], 'john');
        expect(touchedTracker.isTouched('username'), isTrue);
      });

      test('allFieldsRealTime validates all fields and updates errors', () {
        final state = createInitialState(strategy: ValidationStrategy.allFieldsRealTime);
        final newState = orchestrator.updateField<String>(
          fieldName: 'username',
          value: 'john',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.values['username'], 'john');
        expect(newState.errors.containsKey('username'), isFalse);
        expect(newState.errors.containsKey('email'), isTrue);
        expect(newState.isValid, isFalse);
      });

      test('realTimeOnly validates single field synchronously', () {
        final state = createInitialState(strategy: ValidationStrategy.realTimeOnly);
        final newState = orchestrator.updateField<String>(
          fieldName: 'email',
          value: 'invalidemail',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.errors['email'], 'Invalid email');

        final newState2 = orchestrator.updateField<String>(
          fieldName: 'email',
          value: 'john@example.com',
          context: mockContext,
          state: newState,
          getState: () => newState,
          emitState: (_) {},
        );

        expect(newState2.errors.containsKey('email'), isFalse);
      });

      test('disabled clears errors and sets isValid = true', () {
        final state = createInitialState(strategy: ValidationStrategy.disabled);
        final newState = orchestrator.updateField<String>(
          fieldName: 'username',
          value: '',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.errors, isEmpty);
        expect(newState.isValid, isTrue);
      });

      test('schedules async validation when field passes sync validation in allFieldsRealTime', () async {
        final asyncField = FormFieldDefinition<String>(
          name: 'asyncUsername',
          initialValue: '',
          validators: [
            TestValidator<String>((v, c) => null),
          ],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async {
              await Future<void>.delayed(const Duration(milliseconds: 20));
              return v == 'taken' ? 'Username is taken' : null;
            }),
          ],
        );

        final testReg = FormFieldRegistry([asyncField]);
        final testTracker = FormTouchedTracker(['asyncUsername']);
        final testVal = FormValidator(debounceDelay: const Duration(milliseconds: 10));
        final testOrch = FormValidationOrchestrator(
          registry: testReg,
          touchedTracker: testTracker,
          validator: testVal,
          asyncDebounceDelay: const Duration(milliseconds: 10),
        );

        var currentState = TypedFormState(
          values: testReg.initialValues,
          errors: const {},
          isValid: true,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          fieldTypes: testReg.fieldTypes,
        );

        final emissions = <TypedFormState>[];

        currentState = testOrch.updateField<String>(
          fieldName: 'asyncUsername',
          value: 'taken',
          context: mockContext,
          state: currentState,
          getState: () => currentState,
          emitState: (s) {
            currentState = s;
            emissions.add(s);
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));

        expect(emissions.length, greaterThanOrEqualTo(2));
        expect(currentState.errors['asyncUsername'], 'Username is taken');

        testVal.dispose();
      });

      test('schedules async validation when field passes sync validation in realTimeOnly', () async {
        final asyncField = FormFieldDefinition<String>(
          name: 'asyncField',
          initialValue: '',
          validators: [TestValidator<String>((v, c) => null)],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async => 'Async Error'),
          ],
        );

        final testReg = FormFieldRegistry([asyncField]);
        final testTracker = FormTouchedTracker(['asyncField']);
        final testVal = FormValidator(debounceDelay: Duration.zero);
        final testOrch = FormValidationOrchestrator(
          registry: testReg,
          touchedTracker: testTracker,
          validator: testVal,
          asyncDebounceDelay: Duration.zero,
        );

        var currentState = TypedFormState(
          values: testReg.initialValues,
          errors: const {},
          isValid: true,
          validationStrategy: ValidationStrategy.realTimeOnly,
          fieldTypes: testReg.fieldTypes,
        );

        final emissions = <TypedFormState>[];

        currentState = testOrch.updateField<String>(
          fieldName: 'asyncField',
          value: 'test',
          context: mockContext,
          state: currentState,
          getState: () => currentState,
          emitState: (s) {
            currentState = s;
            emissions.add(s);
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(currentState.errors['asyncField'], 'Async Error');
        testVal.dispose();
      });
    });

    group('updateFieldWithDebounce', () {
      test('onSubmitOnly and onSubmitThenRealTime emit state with new values', () {
        final state = createInitialState(strategy: ValidationStrategy.onSubmitOnly);
        final emissions = <TypedFormState>[];

        orchestrator.updateFieldWithDebounce<String>(
          fieldName: 'username',
          value: 'john',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: emissions.add,
        );

        expect(emissions.length, 1);
        expect(emissions.first.values['username'], 'john');
      });

      test('allFieldsRealTime debounces validation and emits state on completion', () async {
        var state = createInitialState(strategy: ValidationStrategy.allFieldsRealTime);
        final emissions = <TypedFormState>[];

        orchestrator.updateFieldWithDebounce<String>(
          fieldName: 'username',
          value: '',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (s) {
            state = s;
            emissions.add(s);
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(emissions.isNotEmpty, isTrue);
        expect(state.errors['username'], 'Username required');
      });

      test('allFieldsRealTime schedules async validation if sync validation passes', () async {
        final asyncField = FormFieldDefinition<String>(
          name: 'asyncUsername',
          initialValue: '',
          validators: [TestValidator<String>((v, c) => null)],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async => 'Async Error'),
          ],
        );

        final testReg = FormFieldRegistry([asyncField]);
        final testTracker = FormTouchedTracker(['asyncUsername']);
        final testVal = FormValidator(debounceDelay: const Duration(milliseconds: 10));
        final testOrch = FormValidationOrchestrator(
          registry: testReg,
          touchedTracker: testTracker,
          validator: testVal,
          asyncDebounceDelay: const Duration(milliseconds: 10),
        );

        var currentState = TypedFormState(
          values: testReg.initialValues,
          errors: const {},
          isValid: true,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          fieldTypes: testReg.fieldTypes,
        );

        testOrch.updateFieldWithDebounce<String>(
          fieldName: 'asyncUsername',
          value: 'good',
          context: mockContext,
          state: currentState,
          getState: () => currentState,
          emitState: (s) {
            currentState = s;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));

        expect(currentState.errors['asyncUsername'], 'Async Error');
        testVal.dispose();
      });

      test('realTimeOnly debounces single field validation', () async {
        var state = createInitialState(strategy: ValidationStrategy.realTimeOnly);
        final emissions = <TypedFormState>[];

        orchestrator.updateFieldWithDebounce<String>(
          fieldName: 'email',
          value: 'bademail',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (s) {
            state = s;
            emissions.add(s);
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(emissions.isNotEmpty, isTrue);
        expect(state.errors['email'], 'Invalid email');
      });

      test('realTimeOnly schedules async validation when sync validation passes', () async {
        final asyncField = FormFieldDefinition<String>(
          name: 'asyncField',
          initialValue: '',
          validators: [TestValidator<String>((v, c) => null)],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async => 'Async Error'),
          ],
        );

        final testReg = FormFieldRegistry([asyncField]);
        final testTracker = FormTouchedTracker(['asyncField']);
        final testVal = FormValidator(debounceDelay: const Duration(milliseconds: 10));
        final testOrch = FormValidationOrchestrator(
          registry: testReg,
          touchedTracker: testTracker,
          validator: testVal,
          asyncDebounceDelay: const Duration(milliseconds: 10),
        );

        var currentState = TypedFormState(
          values: testReg.initialValues,
          errors: const {},
          isValid: true,
          validationStrategy: ValidationStrategy.realTimeOnly,
          fieldTypes: testReg.fieldTypes,
        );

        testOrch.updateFieldWithDebounce<String>(
          fieldName: 'asyncField',
          value: 'good',
          context: mockContext,
          state: currentState,
          getState: () => currentState,
          emitState: (s) {
            currentState = s;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 80));

        expect(currentState.errors['asyncField'], 'Async Error');
        testVal.dispose();
      });

      test('disabled cancels async validation and emits valid state', () {
        final state = createInitialState(strategy: ValidationStrategy.disabled);
        final emissions = <TypedFormState>[];

        orchestrator.updateFieldWithDebounce<String>(
          fieldName: 'username',
          value: '',
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: emissions.add,
        );

        expect(emissions.length, 1);
        expect(emissions.first.isValid, isTrue);
      });
    });

    group('updateFields', () {
      test('updates multiple fields at once across all strategies', () {
        final state = createInitialState(strategy: ValidationStrategy.allFieldsRealTime);
        final newState = orchestrator.updateFields(
          fieldValues: {'username': 'john', 'age': 25},
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.values['username'], 'john');
        expect(newState.values['age'], 25);
        expect(newState.errors.containsKey('username'), isFalse);
        expect(newState.errors.containsKey('age'), isFalse);
      });

      test('onSubmitOnly cancels async validation for updated fields', () {
        final state = createInitialState(strategy: ValidationStrategy.onSubmitOnly);
        final newState = orchestrator.updateFields(
          fieldValues: {'username': 'john'},
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.values['username'], 'john');
      });

      test('realTimeOnly validates updated fields individually', () {
        final state = createInitialState(strategy: ValidationStrategy.realTimeOnly);
        final newState = orchestrator.updateFields(
          fieldValues: {'username': '', 'email': 'john@example.com'},
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.errors['username'], 'Username required');
        expect(newState.errors.containsKey('email'), isFalse);
      });

      test('disabled clears all errors for multiple fields', () {
        final state = createInitialState(strategy: ValidationStrategy.disabled);
        final newState = orchestrator.updateFields(
          fieldValues: {'username': '', 'age': 5},
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.errors, isEmpty);
        expect(newState.isValid, isTrue);
      });
    });

    group('updateFieldValidators', () {
      test('updates validators and re-evaluates field state', () {
        final state = createInitialState();
        final newState = orchestrator.updateFieldValidators<String>(
          name: 'optionalNote',
          validators: [
            TestValidator<String>((v, c) => (v == null || v.isEmpty) ? 'Note required' : null),
          ],
          context: mockContext,
          state: state,
          getState: () => state,
          emitState: (_) {},
        );

        expect(newState.errors['optionalNote'], 'Note required');
      });

      test('schedules async validation when new async validators provided', () async {
        final state = createInitialState();
        var currentState = state;

        orchestrator.updateFieldValidators<String>(
          name: 'optionalNote',
          validators: [],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async => 'Async Note Error'),
          ],
          context: mockContext,
          state: currentState,
          getState: () => currentState,
          emitState: (s) {
            currentState = s;
          },
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(currentState.errors['optionalNote'], 'Async Note Error');
      });
    });

    group('Group and Subset Validation Routines', () {
      group('validateGroup', () {
        test('returns state unchanged and calls onValidationPass if group is empty or unknown', () {
          final state = createInitialState();
          bool passed = false;

          final newState = orchestrator.validateGroup(
            'unknownGroup',
            context: mockContext,
            state: state,
            onValidationPass: () => passed = true,
          );

          expect(newState, state);
          expect(passed, isTrue);
        });

        test('marks group fields touched and updates errors when group validation fails', () {
          final state = createInitialState(strategy: ValidationStrategy.onSubmitOnly);
          bool failed = false;

          final newState = orchestrator.validateGroup(
            'account',
            context: mockContext,
            state: state,
            onValidationFail: () => failed = true,
          );

          expect(touchedTracker.isTouched('username'), isTrue);
          expect(touchedTracker.isTouched('email'), isTrue);
          expect(newState.errors['username'], 'Username required');
          expect(newState.errors['email'], 'Invalid email');
          expect(failed, isTrue);
        });

        test('switches strategy from onSubmitThenRealTime to realTimeOnly when group validation fails', () {
          final state = createInitialState(strategy: ValidationStrategy.onSubmitThenRealTime);

          final newState = orchestrator.validateGroup(
            'account',
            context: mockContext,
            state: state,
          );

          expect(newState.validationStrategy, ValidationStrategy.realTimeOnly);
        });

        test('calls onValidationPass when all fields in group pass validation', () {
          var state = createInitialState();
          state = state.copyWith(
            values: {
              ...state.values,
              'username': 'john',
              'email': 'john@example.com',
            },
          );

          bool passed = false;
          final newState = orchestrator.validateGroup(
            'account',
            context: mockContext,
            state: state,
            onValidationPass: () => passed = true,
          );

          expect(passed, isTrue);
          expect(newState.errors, isEmpty);
        });
      });

      group('validateFields', () {
        test('returns state unchanged and calls onValidationPass if field list is empty', () {
          final state = createInitialState();
          bool passed = false;

          final newState = orchestrator.validateFields(
            [],
            context: mockContext,
            state: state,
            onValidationPass: () => passed = true,
          );

          expect(newState, state);
          expect(passed, isTrue);
        });

        test('throws FormFieldError.fieldNotFound if any specified field does not exist', () {
          final state = createInitialState();

          expect(
            () => orchestrator.validateFields(
              ['username', 'missingField'],
              context: mockContext,
              state: state,
            ),
            throwsA(isA<FormFieldError>()),
          );
        });

        test('marks specified fields touched and evaluates errors', () {
          final state = createInitialState(strategy: ValidationStrategy.onSubmitOnly);
          bool failed = false;

          final newState = orchestrator.validateFields(
            ['username', 'username'], // duplicated list
            context: mockContext,
            state: state,
            onValidationFail: () => failed = true,
          );

          expect(touchedTracker.isTouched('username'), isTrue);
          expect(newState.errors['username'], 'Username required');
          expect(failed, isTrue);
        });

        test('switches strategy from onSubmitThenRealTime to realTimeOnly on failure', () {
          final state = createInitialState(strategy: ValidationStrategy.onSubmitThenRealTime);

          final newState = orchestrator.validateFields(
            ['age'],
            context: mockContext,
            state: state,
          );

          expect(newState.validationStrategy, ValidationStrategy.realTimeOnly);
        });

        test('calls onValidationPass when all specified fields pass validation', () {
          var state = createInitialState();
          state = state.copyWith(values: {...state.values, 'age': 20});

          bool passed = false;
          final newState = orchestrator.validateFields(
            ['age'],
            context: mockContext,
            state: state,
            onValidationPass: () => passed = true,
          );

          expect(passed, isTrue);
          expect(newState.errors.containsKey('age'), isFalse);
        });
      });

      group('isGroupValid', () {
        test('returns true for unknown or empty group', () {
          final state = createInitialState();
          expect(orchestrator.isGroupValid('emptyGroup', context: mockContext, state: state), isTrue);
        });

        test('returns false if any field in group fails validation', () {
          final state = createInitialState();
          expect(orchestrator.isGroupValid('account', context: mockContext, state: state), isFalse);
        });

        test('returns true if all fields in group pass validation', () {
          final state = createInitialState().copyWith(
            values: {
              'username': 'john',
              'email': 'john@example.com',
              'age': 25,
              'optionalNote': '',
            },
          );

          expect(orchestrator.isGroupValid('account', context: mockContext, state: state), isTrue);
        });
      });

      group('areFieldsValid', () {
        test('returns true for empty fieldNames list', () {
          final state = createInitialState();
          expect(orchestrator.areFieldsValid([], context: mockContext, state: state), isTrue);
        });

        test('returns false if any field is missing from registry', () {
          final state = createInitialState();
          expect(
            orchestrator.areFieldsValid(['username', 'missing'], context: mockContext, state: state),
            isFalse,
          );
        });

        test('returns false if any field fails validation', () {
          final state = createInitialState();
          expect(orchestrator.areFieldsValid(['username'], context: mockContext, state: state), isFalse);
        });

        test('returns true if all specified fields pass validation', () {
          final state = createInitialState().copyWith(
            values: {'username': 'john'},
          );
          expect(orchestrator.areFieldsValid(['username'], context: mockContext, state: state), isTrue);
        });
      });

      group('touchGroup', () {
        test('returns unchanged state if group is empty/unknown', () {
          final state = createInitialState();
          final newState = orchestrator.touchGroup('unknownGroup', context: mockContext, state: state);
          expect(newState, state);
        });

        test('marks group fields touched and updates errors and validity', () {
          final state = createInitialState();
          final newState = orchestrator.touchGroup('account', context: mockContext, state: state);

          expect(touchedTracker.isTouched('username'), isTrue);
          expect(touchedTracker.isTouched('email'), isTrue);
          expect(newState.errors['username'], 'Username required');
          expect(newState.errors['email'], 'Invalid email');
        });
      });
    });

    group('scheduleFieldAsyncValidation & Error Handling', () {
      test('captures async validation exception and calls onAsyncValidationError callback', () async {
        final throwingField = FormFieldDefinition<String>(
          name: 'throwingField',
          initialValue: '',
          validators: [],
          asyncValidators: [
            TestAsyncValidator<String>((v, c) async {
              throw FormatException('Simulated async crash');
            }),
          ],
        );

        final testReg = FormFieldRegistry([throwingField]);
        final testTracker = FormTouchedTracker(['throwingField']);
        final testVal = FormValidator(debounceDelay: Duration.zero);
        final testOrch = FormValidationOrchestrator(
          registry: testReg,
          touchedTracker: testTracker,
          validator: testVal,
          asyncDebounceDelay: Duration.zero,
          onAsyncValidationError: (error, stackTrace, fieldName) {
            capturedAsyncError = error;
            capturedAsyncStackTrace = stackTrace;
            capturedAsyncFieldName = fieldName;
          },
        );

        var currentState = TypedFormState(
          values: testReg.initialValues,
          errors: const {},
          isValid: true,
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          fieldTypes: testReg.fieldTypes,
        );

        testOrch.scheduleFieldAsyncValidation<String>(
          fieldName: 'throwingField',
          value: 'val',
          asyncValidators: throwingField.asyncValidators!.cast<AsyncValidator<String>>(),
          context: mockContext,
          getState: () => currentState,
          emitState: (s) => currentState = s,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(capturedAsyncError, isA<FormatException>());
        expect(capturedAsyncStackTrace, isNotNull);
        expect(capturedAsyncFieldName, 'throwingField');
        testVal.dispose();
      });
    });
  });
}
