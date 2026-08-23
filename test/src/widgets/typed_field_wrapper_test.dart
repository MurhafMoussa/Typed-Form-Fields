import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('TypedFieldWrapper', () {
    late TypedFormController formCubit;

    setUp(() {
      formCubit = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.email()],
          ),
          FormFieldDefinition<int>(
            name: 'age',
            validators: [TypedCommonValidators.required<int>()],
          ),
        ],
      );
    });

    tearDown(() {
      formCubit.close();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<TypedFormController>(
          create: (context) => formCubit,
          child: Scaffold(body: child),
        ),
      );
    }

    group('Basic Functionality', () {
      testWidgets('should render with initial value', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              initialValue: 'test@example.com',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Should display initial value
        expect(find.text('test@example.com'), findsOneWidget);

        // Form should have the initial value
        expect(formCubit.state.values['email'], equals('test@example.com'));
      });

      testWidgets('should update value when user input changes',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Enter text
        await tester.enterText(
            find.byKey(const Key('email_field')), 'user@test.com');
        await tester.pump();

        // Form should be updated
        expect(formCubit.state.values['email'], equals('user@test.com'));
      });

      testWidgets('should display error messages', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Enter invalid email
        await tester.enterText(
            find.byKey(const Key('email_field')), 'invalid-email');
        await tester.pump();

        // Trigger validation
        final context = tester.element(find.byType(TypedFieldWrapper<String>));
        formCubit.validateForm(
          context,
          onValidationPass: () {},
          onValidationFail: () {},
        );
        await tester.pump();

        // Should display error
        expect(
            find.text('Please enter a valid email address.'), findsOneWidget);
      });
    });

    group('Performance Optimization', () {
      testWidgets('should only rebuild when field-specific data changes',
          (tester) async {
        int buildCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                buildCount++;
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();
        final initialBuildCount = buildCount;

        // Update a different field - should not trigger rebuild
        final context = tester.element(find.byType(TypedFieldWrapper<String>));
        formCubit.updateField<int>(
          fieldName: 'age',
          value: 25,
          context: context,
        );
        await tester.pump();

        // Build count should not increase
        expect(buildCount, equals(initialBuildCount));

        // Update the email field - should trigger rebuild
        formCubit.updateField<String>(
          fieldName: 'email',
          value: 'test@example.com',
          context: context,
        );
        await tester.pump();

        // Build count should increase
        expect(buildCount, greaterThan(initialBuildCount));
      });

      testWidgets('should use buildWhen to optimize rebuilds', (tester) async {
        int buildCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                TypedFieldWrapper<String>(
                  fieldName: 'email',
                  builder: (context, value, error, hasError, isValidating, updateValue) {
                    buildCount++;
                    return TextFormField(
                      key: const Key('email_field'),
                      initialValue: value,
                      onChanged: updateValue,
                    );
                  },
                ),
                TypedFieldWrapper<int>(
                  fieldName: 'age',
                  builder: (context, value, error, hasError, isValidating, updateValue) {
                    return TextFormField(
                      key: const Key('age_field'),
                      initialValue: value?.toString(),
                      onChanged: (val) => updateValue(int.tryParse(val)),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        await tester.pump();
        final initialBuildCount = buildCount;

        // Update age field - email field should not rebuild
        await tester.enterText(find.byKey(const Key('age_field')), '30');
        await tester.pump();

        // Email field build count should not increase
        expect(buildCount, equals(initialBuildCount));
      });
    });

    group('Listener Functionality', () {
      testWidgets('should call onFieldStateChanged when field state changes',
          (tester) async {
        String? lastValue;
        String? lastError;
        bool? lastHasError;
        int listenerCallCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              onFieldStateChanged: (value, error, hasError) {
                lastValue = value;
                lastError = error;
                lastHasError = hasError;
                listenerCallCount++;
              },
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Update field value
        await tester.enterText(
            find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pump();

        // Listener should be called
        expect(listenerCallCount, greaterThan(0));
        expect(lastValue, equals('test@example.com'));
        expect(lastHasError, isFalse);

        // Trigger validation error
        await tester.enterText(
            find.byKey(const Key('email_field')), 'invalid-email');
        await tester.pump();

        final context = tester.element(find.byType(TypedFieldWrapper<String>));
        formCubit.validateForm(
          context,
          onValidationPass: () {},
          onValidationFail: () {},
        );
        await tester.pump();

        // Listener should be called with error
        expect(lastValue, equals('invalid-email'));
        expect(lastError, isNotNull);
        expect(lastHasError, isTrue);
      });

      testWidgets('should not call listener when other fields change',
          (tester) async {
        int emailListenerCallCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                TypedFieldWrapper<String>(
                  fieldName: 'email',
                  onFieldStateChanged: (value, error, hasError) {
                    emailListenerCallCount++;
                  },
                  builder: (context, value, error, hasError, isValidating, updateValue) {
                    return TextFormField(
                      key: const Key('email_field'),
                      initialValue: value,
                      onChanged: updateValue,
                    );
                  },
                ),
                TypedFieldWrapper<int>(
                  fieldName: 'age',
                  builder: (context, value, error, hasError, isValidating, updateValue) {
                    return TextFormField(
                      key: const Key('age_field'),
                      initialValue: value?.toString(),
                      onChanged: (val) => updateValue(int.tryParse(val)),
                    );
                  },
                ),
              ],
            ),
          ),
        );

        await tester.pump();
        final initialCallCount = emailListenerCallCount;

        // Update age field
        await tester.enterText(find.byKey(const Key('age_field')), '25');
        await tester.pump();

        // Email listener should not be called
        expect(emailListenerCallCount, equals(initialCallCount));
      });
    });

    group('Debouncing', () {
      testWidgets('should debounce form updates when debounceTime is provided',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              debounceTime: const Duration(milliseconds: 300),
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Enter text rapidly
        await tester.enterText(find.byKey(const Key('email_field')), 'a');
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(find.byKey(const Key('email_field')), 'ab');
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(
            find.byKey(const Key('email_field')), 'abc@test.com');
        await tester.pump(const Duration(milliseconds: 100));

        // Form should not be updated yet (still debouncing)
        expect(formCubit.state.values['email'], isNot(equals('abc@test.com')));

        // Wait for debounce to complete
        await tester.pump(const Duration(milliseconds: 300));

        // Now form should be updated
        expect(formCubit.state.values['email'], equals('abc@test.com'));
      });

      testWidgets('should call onValueChanged immediately even with debouncing',
          (tester) async {
        String? lastImmediateValue;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              debounceTime: const Duration(milliseconds: 300),
              onValueChanged: (value) {
                lastImmediateValue = value;
              },
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Enter text
        await tester.enterText(
            find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pump();

        // Immediate callback should be called right away
        expect(lastImmediateValue, equals('test@example.com'));

        // But form should not be updated yet
        expect(
            formCubit.state.values['email'], isNot(equals('test@example.com')));
      });
    });

    group('Value Transformation', () {
      testWidgets('should transform values before updating form state',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              transformValue: (value) => value.toLowerCase().trim(),
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Enter text with uppercase and spaces
        await tester.enterText(
            find.byKey(const Key('email_field')), '  TEST@EXAMPLE.COM  ');
        await tester.pump();

        // Form should have transformed value
        expect(formCubit.state.values['email'], equals('test@example.com'));
      });

      testWidgets('should not transform null values', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              transformValue: (value) => value.toLowerCase(),
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Clear the field (set to null)
        await tester.enterText(find.byKey(const Key('email_field')), '');
        await tester.pump();

        // Should not crash and should handle null gracefully
        expect(formCubit.state.values['email'], isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle field removal gracefully', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Update field
        await tester.enterText(
            find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pump();

        // Remove field from form
        final context = tester.element(find.byType(TypedFieldWrapper<String>));
        formCubit.removeField('email', context: context);
        await tester.pump();

        // Widget should still render without crashing
        expect(find.byType(TypedFieldWrapper<String>), findsOneWidget);
      });

      testWidgets('should handle rapid state changes', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Rapidly change values
        for (int i = 0; i < 10; i++) {
          await tester.enterText(
              find.byKey(const Key('email_field')), 'test$i@example.com');
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Should handle all changes without crashing
        expect(find.byType(TypedFieldWrapper<String>), findsOneWidget);
        expect(formCubit.state.values['email'], equals('test9@example.com'));
      });
    });

    group('Cleanup', () {
      testWidgets('should cancel debounce timer on dispose', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              debounceTime: const Duration(milliseconds: 1000),
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Start a debounced update
        await tester.enterText(
            find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pump();

        // Remove the widget before debounce completes
        await tester.pumpWidget(
          createTestWidget(Container()),
        );

        // Wait for what would have been the debounce time
        await tester.pump(const Duration(milliseconds: 1000));

        // Should not crash or cause issues
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('should use currentValue when formValue is null in listener',
          (tester) async {
        String? capturedValue;
        String? capturedError;
        bool? capturedHasError;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              initialValue: 'initial@test.com',
              onFieldStateChanged: (value, error, hasError) {
                capturedValue = value;
                capturedError = error;
                capturedHasError = hasError;
              },
              builder: (context, value, error, hasError, isValidating, updateValue) {
                return TextFormField(
                  key: const Key('email_field'),
                  initialValue: value,
                  onChanged: updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: hasError ? error : null,
                  ),
                );
              },
            ),
          ),
        );

        await tester.pump();

        // Clear the form value to simulate formValue being null
        formCubit.updateField(
            fieldName: 'email',
            value: null,
            context: tester.element(find.byType(MaterialApp)));
        await tester.pump();

        // The listener should have been called with the currentValue (initial value)
        expect(capturedValue, equals('initial@test.com'));
        expect(capturedError, isNull);
        expect(capturedHasError, isFalse);
      });
    });

    group('Validating State & Rebuilds', () {
      testWidgets('should pass isValidating to builder and rebuild when validatingFields changes',
          (tester) async {
        bool? receivedIsValidating;
        int buildCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                buildCount++;
                receivedIsValidating = isValidating;
                return Text(isValidating ? 'Validating...' : 'Idle');
              },
            ),
          ),
        );

        await tester.pump();
        expect(receivedIsValidating, isFalse);
        expect(find.text('Idle'), findsOneWidget);
        final initialBuildCount = buildCount;

        // Emit state where email is validating
        formCubit.emit(formCubit.state.copyWith(validatingFields: {'email'}));
        await tester.pump();
        await tester.pump();

        expect(receivedIsValidating, isTrue);
        expect(find.text('Validating...'), findsOneWidget);
        expect(buildCount, equals(initialBuildCount + 1));

        // Emit state where email is no longer validating
        formCubit.emit(formCubit.state.copyWith(validatingFields: {}));
        await tester.pump();
        await tester.pump();

        expect(receivedIsValidating, isFalse);
        expect(find.text('Idle'), findsOneWidget);
        expect(buildCount, equals(initialBuildCount + 2));
      });

      testWidgets('should not rebuild when another field enters validatingFields',
          (tester) async {
        int buildCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, value, error, hasError, isValidating, updateValue) {
                buildCount++;
                return Text('Email Widget');
              },
            ),
          ),
        );

        await tester.pump();
        final initialBuildCount = buildCount;

        // Emit state where a different field ('age') is validating
        formCubit.emit(formCubit.state.copyWith(validatingFields: {'age'}));
        await tester.pump();

        // Email field build count should not increase
        expect(buildCount, equals(initialBuildCount));
      });
    });
  });
}
