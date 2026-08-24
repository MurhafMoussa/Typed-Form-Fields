import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class AsyncEmailValidator implements AsyncValidator<String> {
  AsyncEmailValidator(this.onValidate);

  final Future<String?> Function(String? value, BuildContext context)
      onValidate;

  @override
  FutureOr<String?> validate(String? value, BuildContext context) {
    return onValidate(value, context);
  }
}

void main() {
  group('Async Validation Submission and Reset Integration Test', () {
    testWidgets(
        'Submitting form flushes debounce timer, displays progress, and waits for validation before completion',
        (tester) async {
      final emailCompleter = Completer<String?>();
      bool submitted = false;

      final emailField = FormFieldDefinition<String>(
        name: 'email',
        validators: [
          TypedCommonValidators.required<String>(errorText: 'Email required'),
        ],
        asyncValidators: [
          AsyncEmailValidator((value, context) => emailCompleter.future),
        ],
        initialValue: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypedFormProvider(
              fields: [emailField],
              child: (context) {
                return Column(
                  children: [
                    TypedFieldWrapper<String>(
                      fieldName: 'email',
                      builder: (ctx, field) {
                        return Column(
                          children: [
                            TextFormField(
                              key: const Key('email_input'),
                              initialValue: field.value,
                              onChanged: field.updateValue,
                            ),
                            if (field.isValidating)
                              const CircularProgressIndicator(
                                key: Key('loading_indicator'),
                              ),
                            if (field.hasError)
                              Text(
                                field.displayError!,
                                key: const Key('email_error'),
                              ),
                          ],
                        );
                      },
                    ),
                    ElevatedButton(
                      key: const Key('submit_button'),
                      onPressed: () {
                        context.validateForm(
                          onValidationPass: () => submitted = true,
                        );
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Enter email value
      await tester.enterText(
          find.byKey(const Key('email_input')), 'alice@example.com');
      await tester.pump();

      // Immediately tap submit before async debounce timer expires
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump(); // Start submission flushing

      // Loading indicator should appear on UI
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      expect(submitted, isFalse);

      // Complete async validation with success
      emailCompleter.complete(null);
      await tester.pumpAndSettle();

      // Submission completed successfully and loading indicator disappeared
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
      expect(submitted, isTrue);
      expect(find.byKey(const Key('email_error')), findsNothing);
    });

    testWidgets(
        'Resetting form cancels active async validation and hides loading state immediately',
        (tester) async {
      final emailCompleter = Completer<String?>();

      final emailField = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [
          AsyncEmailValidator((value, context) => emailCompleter.future),
        ],
        initialValue: 'initial@example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypedFormProvider(
              fields: [emailField],
              child: (context) {
                return Column(
                  children: [
                    TypedFieldWrapper<String>(
                      fieldName: 'email',
                      builder: (ctx, field) {
                        return Column(
                          children: [
                            TextFormField(
                              key: const Key('email_input'),
                              initialValue: field.value,
                              onChanged: field.updateValue,
                            ),
                            if (field.isValidating)
                              const CircularProgressIndicator(
                                key: Key('loading_indicator'),
                              ),
                            if (field.hasError)
                              Text(
                                field.displayError!,
                                key: const Key('email_error'),
                              ),
                          ],
                        );
                      },
                    ),
                    ElevatedButton(
                      key: const Key('reset_button'),
                      onPressed: () {
                        context.formCubit.resetForm();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Type new email
      await tester.enterText(
          find.byKey(const Key('email_input')), 'new@example.com');
      await tester.pump(const Duration(
          milliseconds: 350)); // Wait for debounce to trigger validation

      // Loading indicator is visible
      expect(find.byKey(const Key('loading_indicator')), findsOneWidget);

      // Tap reset
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pump();

      // Loading indicator is gone immediately
      expect(find.byKey(const Key('loading_indicator')), findsNothing);

      // Complete in-flight validation with error after reset
      emailCompleter.complete('Late email error');
      await tester.pumpAndSettle();

      // Late error is ignored, no error visible on UI
      expect(find.byKey(const Key('email_error')), findsNothing);
      expect(find.byKey(const Key('loading_indicator')), findsNothing);
    });
  });
}
