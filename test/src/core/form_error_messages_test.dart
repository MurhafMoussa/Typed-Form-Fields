import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

void main() {
  group('Improved Error Messages', () {
    late TypedFormController formCubit;
    late BuildContext context;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      formCubit = TypedFormController(
        fields: [
          FormFieldDefinition<String>(
            name: 'email',
            validators: [TypedCommonValidators.required<String>()],
            initialValue: '',
          ),
          FormFieldDefinition<int>(
            name: 'age',
            validators: [TypedCommonValidators.required<int>()],
            initialValue: 0,
          ),
        ],
      );
    });

    tearDown(() {
      formCubit.close();
    });

    testWidgets('should provide helpful error when wrong type is used',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      // Test: Try to update String field with int value
      try {
        formCubit.updateField<int>(
          fieldName: 'email',
          value: 123,
          context: context,
        );
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('email'));
        expect(error.message, contains('Type mismatch'));
        expect(error.suggestion, contains('Use FieldWrapper<String>'));
      }
    });

    testWidgets('should provide helpful error when field does not exist',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      // Test: Try to update non-existent field
      try {
        formCubit.updateField<String>(
          fieldName: 'nonexistent',
          value: 'test',
          context: context,
        );
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('nonexistent'));
        expect(error.message, contains('does not exist'));
        expect(error.suggestion, contains('Available fields:'));
      }
    });

    testWidgets(
        'should provide helpful error when accessing field with wrong type',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      // First set a value
      formCubit.updateField<String>(
        fieldName: 'email',
        value: 'test@example.com',
        context: context,
      );

      // Test: Try to get String field as int
      try {
        formCubit.getValue<int>('email');
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.fieldName, equals('email'));
        expect(error.message, contains('Type mismatch'));
        expect(error.suggestion, contains('Use getValue<String>'));
      }
    });

    testWidgets('should provide debug information in development mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return Container();
            },
          ),
        ),
      );

      // Test debug information when assertion fails
      try {
        formCubit.updateField<String>(
          fieldName: 'nonexistent',
          value: 'test',
          context: context,
        );
        fail('Expected FormFieldError to be thrown');
      } catch (e) {
        expect(e, isA<FormFieldError>());
        final error = e as FormFieldError;
        expect(error.debugInfo, isNotNull);
        expect(error.debugInfo!, contains('Available fields: [email, age]'));
        expect(error.debugInfo!,
            contains('Field types: {email: String, age: int}'));
        expect(error.debugInfo!, contains('Current values:'));
      }
    });

    test('should create FormFieldError with proper structure', () {
      final error = FormFieldError(
        fieldName: 'test',
        message: 'Test error message',
        suggestion: 'Test suggestion',
        debugInfo: 'Test debug info',
      );

      expect(error.fieldName, equals('test'));
      expect(error.message, equals('Test error message'));
      expect(error.suggestion, equals('Test suggestion'));
      expect(error.debugInfo, equals('Test debug info'));

      final errorString = error.toString();
      expect(errorString, contains('FormFieldError in field "test":'));
      expect(errorString, contains('Test error message'));
      expect(errorString, contains('Suggestion: Test suggestion'));
      expect(errorString, contains('Debug Info: Test debug info'));
    });

    test('should create FormFieldError with performanceWarning factory', () {
      final error = FormFieldError.performanceWarning(
        fieldName: 'testField',
        issue: 'Too many validators',
        recommendation: 'Consider using composite validators',
      );

      expect(error.fieldName, equals('testField'));
      expect(error.message, equals('Performance Warning: Too many validators'));
      expect(error.suggestion, equals('Consider using composite validators'));
      expect(error.debugInfo, isNull);

      final errorString = error.toString();
      expect(errorString, contains('FormFieldError in field "testField":'));
      expect(errorString, contains('Performance Warning: Too many validators'));
      expect(errorString,
          contains('Suggestion: Consider using composite validators'));
    });
  });
}

// FormFieldError is now exported from the main library
