import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('TypedFormProvider', () {
    testWidgets('should provide form state to child widgets', (tester) async {
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
            child: (context) => const TestChildWidget(),
          ),
        ),
      );

      expect(find.byType(TestChildWidget), findsOneWidget);
    });

    testWidgets('should create TypedFormController with correct fields',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
        FormFieldDefinition<bool>(
          name: 'subscribe',
          validators: [],
          initialValue: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);
                expect(controller, isA<TypedFormController>());
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should handle form state changes callback', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      TypedFormState? lastState;
      void onFormStateChanged(TypedFormState state) {
        lastState = state;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            onFormStateChanged: onFormStateChanged,
            child: (context) => const TestChildWidget(),
          ),
        ),
      );

      // Wait for the initial state to be emitted
      await tester.pump();

      // Initial state should be captured
      expect(lastState, isNotNull);
      expect(lastState!.isValid, isFalse);
    });

    testWidgets('should use default validation type when not specified',
        (tester) async {
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
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);
                expect(controller.state.validationStrategy,
                    ValidationStrategy.realTimeOnly);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should use custom validation type when specified',
        (tester) async {
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
            child: (context) => Builder(
              builder: (context) {
                final controller = TypedFormProvider.of(context);
                expect(controller.state.validationStrategy,
                    ValidationStrategy.onSubmitThenRealTime);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should throw error when accessed without provider',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => TypedFormProvider.of(context),
                throwsFlutterError,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('should dispose controller when widget is disposed',
        (tester) async {
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
            child: (context) => const TestChildWidget(),
          ),
        ),
      );

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Widget should be disposed without errors
      expect(tester.takeException(), isNull);
    });
  });

  group('TypedFormBuilder', () {
    testWidgets('should rebuild when form state changes', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => TypedFormBuilder(
              builder: (context, state) {
                buildCount++;
                return Text(
                    'Build count: $buildCount, Valid: ${state.isValid}');
              },
            ),
          ),
        ),
      );

      expect(find.text('Build count: 1, Valid: false'), findsOneWidget);

      // Update a field to trigger rebuild
      final controller =
          TypedFormProvider.of(tester.element(find.byType(TypedFormBuilder)));
      controller.updateField(
        fieldName: 'email',
        value: 'test@example.com',
        context: tester.element(find.byType(TypedFormBuilder)),
      );

      await tester.pump();

      expect(find.text('Build count: 2, Valid: true'), findsOneWidget);
    });

    testWidgets('should provide correct form state to builder', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => TypedFormBuilder(
              builder: (context, state) {
                // The form should not be valid initially because the field hasn't been touched
                expect(state.isValid, isFalse);
                expect(state.getValue<String>('email'), 'test@example.com');
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });

  group('TypedFormListener', () {
    testWidgets('should call listener when form state changes', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      int listenerCallCount = 0;
      TypedFormState? lastState;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => TypedFormListener(
              listener: (context, state) {
                listenerCallCount++;
                lastState = state;
              },
              child: const TestChildWidget(),
            ),
          ),
        ),
      );

      // Wait for initial state
      await tester.pump();

      // Initial listener call
      expect(listenerCallCount, 1);
      expect(lastState, isNotNull);

      // Update a field to trigger listener
      final controller =
          TypedFormProvider.of(tester.element(find.byType(TypedFormListener)));
      controller.updateField(
        fieldName: 'email',
        value: 'test@example.com',
        context: tester.element(find.byType(TypedFormListener)),
      );

      await tester.pump();

      expect(listenerCallCount, 2);
      expect(lastState!.isValid, isTrue);
    });

    testWidgets('should not rebuild child when form state changes',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      int childBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => TypedFormListener(
              listener: (context, state) {
                // Listener should be called
              },
              child: Builder(
                builder: (context) {
                  childBuildCount++;
                  return Text('Child build count: $childBuildCount');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Child build count: 1'), findsOneWidget);

      // Update a field - child should not rebuild
      final controller =
          TypedFormProvider.of(tester.element(find.byType(TypedFormListener)));
      controller.updateField(
        fieldName: 'email',
        value: 'test@example.com',
        context: tester.element(find.byType(TypedFormListener)),
      );

      await tester.pump();

      expect(find.text('Child build count: 1'), findsOneWidget);
    });
  });

  group('TypedFormProviderExtension', () {
    testWidgets('should provide form cubit access', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final cubit = context.formCubit;
                expect(cubit, isA<TypedFormController>());
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide form state access', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final state = context.formState;
                expect(state, isA<TypedFormState>());
                expect(state.getValue<String>('email'), 'test@example.com');
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide getFormValue method', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                final email = context.getFormValue<String>('email');
                expect(email, 'test@example.com');
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide updateFormField method', (tester) async {
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
            child: (context) => Builder(
              builder: (context) {
                context.updateFormField<String>('email', 'new@example.com');
                final email = context.getFormValue<String>('email');
                expect(email, 'new@example.com');
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide validateForm method', (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      bool validationPassed = false;
      bool validationFailed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                // Call validateForm asynchronously to allow state to settle
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.validateForm(
                    onValidationPass: () {
                      validationPassed = true;
                    },
                    onValidationFail: () {
                      validationFailed = true;
                    },
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Wait for the post-frame callback to execute
      await tester.pump();

      // The form should pass validation because the email field has a valid value
      expect(validationPassed, isTrue);
      expect(validationFailed, isFalse);
    });

    testWidgets('should provide validateGroup and touchGroup methods',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          group: 'step1',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
      ];

      bool validationFailed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  expect(context.isGroupValid('step1'), isFalse);
                  context.touchGroup('step1');
                  context.validateGroup(
                    'step1',
                    onValidationFail: () => validationFailed = true,
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(validationFailed, isTrue);
    });

    testWidgets('should provide validateFields and areFieldsValid methods',
        (tester) async {
      final testFields = [
        FormFieldDefinition<String>(
          name: 'email',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'test@example.com',
        ),
      ];

      bool validationPassed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TypedFormProvider(
            fields: testFields,
            child: (context) => Builder(
              builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  expect(context.areFieldsValid(['email']), isTrue);
                  context.validateFields(
                    ['email'],
                    onValidationPass: () => validationPassed = true,
                  );
                });
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(validationPassed, isTrue);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}

class TestChildWidget extends StatelessWidget {
  const TestChildWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
