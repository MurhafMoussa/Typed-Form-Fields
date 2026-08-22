import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/typed_common_validators.dart';

void main() {
  group('ValidationStrategy', () {
    late TypedFormController formController;

    tearDown(() {
      formController.close();
    });

    group('onSubmitOnly', () {
      testWidgets('should not validate fields on change',
          (WidgetTester tester) async {
        final fields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
        ];

        formController = TypedFormController(
          fields: fields,
          validationStrategy: ValidationStrategy.onSubmitOnly,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Update field with invalid value
                formController.updateField(
                  fieldName: 'email',
                  value: '',
                  context: context,
                );

                // Should not show error until submit
                expect(formController.state.errors, isEmpty);
                expect(formController.state.isValid, isFalse);

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets(
          'should NOT switch to real-time validation after failed submit',
          (WidgetTester tester) async {
        final fields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
        ];

        formController = TypedFormController(
          fields: fields,
          validationStrategy: ValidationStrategy.onSubmitOnly,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Submit form with invalid data
                formController.validateForm(
                  context,
                  onValidationPass: () => fail('Should not pass validation'),
                  onValidationFail: () {},
                );

                // Should still be onSubmitOnly, not switched to real-time
                expect(formController.state.validationStrategy,
                    ValidationStrategy.onSubmitOnly);

                // Update field - should not validate
                formController.updateField(
                  fieldName: 'email',
                  value: 'test@example.com',
                  context: context,
                );
                expect(formController.state.errors,
                    isNotEmpty); // Still has old errors

                return Container();
              },
            ),
          ),
        );
      });
    });

    group('onSubmitThenRealTime', () {
      testWidgets('should switch to real-time validation after failed submit',
          (WidgetTester tester) async {
        final fields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
        ];

        formController = TypedFormController(
          fields: fields,
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Submit form with invalid data
                formController.validateForm(
                  context,
                  onValidationPass: () => fail('Should not pass validation'),
                  onValidationFail: () {},
                );

                // Should switch to real-time validation
                expect(formController.state.validationStrategy,
                    ValidationStrategy.realTimeOnly);

                // Now updating field should validate in real-time
                formController.updateField(
                  fieldName: 'email',
                  value: 'test@example.com',
                  context: context,
                );
                expect(formController.state.errors,
                    isEmpty); // Error should be cleared

                return Container();
              },
            ),
          ),
        );
      });
    });

    group('realTimeOnly', () {
      testWidgets('should validate fields on change',
          (WidgetTester tester) async {
        final fields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
        ];

        formController = TypedFormController(
          fields: fields,
          validationStrategy: ValidationStrategy.realTimeOnly,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Update field with invalid value
                formController.updateField(
                  fieldName: 'email',
                  value: '',
                  context: context,
                );

                // Should show error immediately
                expect(formController.state.errors, isNotEmpty);
                expect(formController.state.errors['email'], isNotNull);
                expect(formController.state.isValid, isFalse);

                return Container();
              },
            ),
          ),
        );
      });
    });

    group('disabled', () {
      testWidgets('should not validate fields at all',
          (WidgetTester tester) async {
        final fields = [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
        ];

        formController = TypedFormController(
          fields: fields,
          validationStrategy: ValidationStrategy.disabled,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Update field with invalid value
                formController.updateField(
                  fieldName: 'email',
                  value: '',
                  context: context,
                );

                // Should not show any errors
                expect(formController.state.errors, isEmpty);
                expect(formController.state.isValid,
                    isTrue); // Always valid when disabled

                return Container();
              },
            ),
          ),
        );
      });
    });
  });
}
