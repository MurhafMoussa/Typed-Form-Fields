import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('Form Integration Tests', () {
    testWidgets('should handle complete form workflow', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'firstName',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(2),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'lastName',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(2),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'email',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'password',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(8),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'confirmPassword',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCrossFieldValidator<String>(
              dependentFields: ['password'],
              validator: (value, fieldValues, context) {
                final password = fieldValues['password'] as String?;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<bool>(
          name: 'acceptTerms',
          validators: [TypedCommonValidators.mustBeTrue()],
          initialValue: false,
        ),
      ];

      bool formSubmitted = false;
      String? submissionError;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Scaffold(
              body: Column(
                children: [
                  // First Name Field
                  TypedFieldWrapper<String>(
                    fieldName: 'firstName',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        errorText: field.displayError,
                      ),
                    ),
                  ),

                  // Last Name Field
                  TypedFieldWrapper<String>(
                    fieldName: 'lastName',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        errorText: field.displayError,
                      ),
                    ),
                  ),

                  // Email Field
                  TypedFieldWrapper<String>(
                    fieldName: 'email',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: field.displayError,
                      ),
                    ),
                  ),

                  // Password Field
                  TypedFieldWrapper<String>(
                    fieldName: 'password',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      obscureText: true,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: field.displayError,
                      ),
                    ),
                  ),

                  // Confirm Password Field
                  TypedFieldWrapper<String>(
                    fieldName: 'confirmPassword',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      obscureText: true,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        errorText: field.displayError,
                      ),
                    ),
                  ),

                  // Terms Checkbox
                  TypedFieldWrapper<bool>(
                    fieldName: 'acceptTerms',
                    builder: (context, field) => CheckboxListTile(
                      title: const Text('I accept the terms and conditions'),
                      value: field.value ?? false,
                      onChanged: (value) => field.updateValue(value),
                      subtitle: field.hasError
                          ? Text(
                              field.error!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : null,
                    ),
                  ),

                  // Submit Button
                  TypedFormBuilder(
                    builder: (context, state) => ElevatedButton(
                      onPressed: state.isValid
                          ? () {
                              context.validateForm(
                                onValidationPass: () {
                                  formSubmitted = true;
                                },
                                onValidationFail: () {
                                  submissionError = 'Form validation failed';
                                },
                              );
                            }
                          : null,
                      child: Text(
                          state.isValid ? 'Submit' : 'Please fill all fields'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially, form should be invalid
      expect(find.text('Please fill all fields'), findsOneWidget);

      // Fill in the form fields
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).at(2), 'john.doe@example.com');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      await tester.pump();

      // Check the terms checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Now the form should be valid
      expect(find.text('Submit'), findsOneWidget);

      // Submit the form
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(formSubmitted, isTrue);
      expect(submissionError, isNull);
    });

    testWidgets('should handle form validation errors', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'password',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(8),
          ],
          initialValue: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Scaffold(
              body: Column(
                children: [
                  TypedFieldWrapper<String>(
                    fieldName: 'email',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: field.displayError,
                      ),
                    ),
                  ),
                  TypedFieldWrapper<String>(
                    fieldName: 'password',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: field.displayError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.pump();

      // Enter short password
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();

      // Check that validation errors are displayed
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Must be at least 8 characters long.'), findsOneWidget);
    });

    testWidgets('should handle dynamic field addition and removal',
        (tester) async {
      final initialFields = [
        FormFieldDefinition<String>(
          name: 'name',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: initialFields,
            child: (context) => DynamicFormTestWidget(),
          ),
        ),
      );

      // Add email field
      await tester.tap(find.text('Add Email Field'));
      await tester.pump();

      // Check that email field is added
      expect(find.text('Email'), findsOneWidget);

      // Remove email field
      await tester.tap(find.text('Remove Email Field'));
      await tester.pump();

      // Check that email field is removed
      expect(find.text('Email'), findsNothing);
    });

    testWidgets('should handle form reset', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'name',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'Initial Value',
        ),
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.email()],
          initialValue: 'initial@example.com',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Scaffold(
              body: Column(
                children: [
                  TypedFieldWrapper<String>(
                    fieldName: 'name',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: field.displayError,
                      ),
                    ),
                  ),
                  TypedFieldWrapper<String>(
                    fieldName: 'email',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: field.displayError,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final controller = context.formCubit;
                      controller.resetForm();
                    },
                    child: const Text('Reset Form'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Modify the fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Modified Name');
      await tester.pump();

      await tester.enterText(
          find.byType(TextFormField).at(1), 'modified@example.com');
      await tester.pump();

      // Reset the form
      await tester.tap(find.text('Reset Form'));
      await tester.pump();

      // Check that fields are reset to initial values by verifying the form state
      final controller =
          TypedFormProvider.of(tester.element(find.byType(Scaffold)));
      expect(controller.getValue<String>('name'), 'Initial Value');
      expect(controller.getValue<String>('email'), 'initial@example.com');
    });

    testWidgets('should handle validation type changes', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            validationStrategy: ValidationStrategy.onSubmitThenRealTime,
            child: (context) => Scaffold(
              body: Column(
                children: [
                  TypedFieldWrapper<String>(
                    fieldName: 'email',
                    builder: (context, field) => TextFormField(
                      initialValue: field.value ?? '',
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: field.displayError,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final controller = context.formCubit;
                      controller.setValidationStrategy(
                          ValidationStrategy.realTimeOnly);
                    },
                    child: const Text('Enable Real-time Validation'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear the field - should not show error in onSubmit mode
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.text('This field is required.'), findsNothing);

      // Switch to real-time validation
      await tester.tap(find.text('Enable Real-time Validation'));
      await tester.pump();

      // Trigger validation by touching the field again and then clearing it
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      // Now should show validation error
      expect(find.text('This field is required.'), findsOneWidget);
    });
  });
}

/// Test widget that can dynamically add/remove fields
class DynamicFormTestWidget extends StatefulWidget {
  const DynamicFormTestWidget({super.key});

  @override
  DynamicFormTestWidgetState createState() => DynamicFormTestWidgetState();
}

class DynamicFormTestWidgetState extends State<DynamicFormTestWidget> {
  bool _showEmailField = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TypedFieldWrapper<String>(
            fieldName: 'name',
            builder: (context, field) => TextFormField(
              initialValue: field.value ?? '',
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: field.displayError,
              ),
            ),
          ),
          if (_showEmailField)
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, field) => TextFormField(
                initialValue: field.value ?? '',
                onChanged: field.updateValue,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: field.displayError,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showEmailField = true;
              });
              final controller = context.formCubit;
              controller.addField(
                field: FormFieldDefinition<String>(
                  name: 'email',
                  validators: [TypedCommonValidators.email()],
                  initialValue: '',
                ),
                context: context,
              );
            },
            child: const Text('Add Email Field'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showEmailField = false;
              });
              final controller = context.formCubit;
              controller.removeField('email', context: context);
            },
            child: const Text('Remove Email Field'),
          ),
        ],
      ),
    );
  }
}
