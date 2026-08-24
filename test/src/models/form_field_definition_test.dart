import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

class _TestValidator<T> implements Validator<T> {
  const _TestValidator();

  @override
  String? validate(T? value, dynamic context) => null;
}

class _TestAsyncValidator<T> implements AsyncValidator<T> {
  const _TestAsyncValidator();

  @override
  String? validate(T? value, dynamic context) => null;
}

void main() {
  group('FormFieldDefinition', () {
    test('defaults group and asyncValidators to null', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
      );

      expect(def.group, isNull);
      expect(def.asyncValidators, isNull);
    });

    test('accepts optional group and asyncValidators parameters in constructor',
        () {
      const asyncVal = _TestAsyncValidator<String>();
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncVal],
        initialValue: 'test@example.com',
        group: 'step1',
      );

      expect(def.name, equals('email'));
      expect(def.group, equals('step1'));
      expect(def.initialValue, equals('test@example.com'));
      expect(def.asyncValidators, equals([asyncVal]));
    });

    test('copyWith updates and preserves asyncValidators correctly', () {
      const asyncVal1 = _TestAsyncValidator<String>();
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncVal1],
        initialValue: 'a@b.com',
        group: 'step1',
      );

      final copy1 = def.copyWith(name: 'newEmail');
      expect(copy1.name, 'newEmail');
      expect(copy1.initialValue, 'a@b.com');
      expect(copy1.group, 'step1');
      expect(copy1.asyncValidators, equals([asyncVal1]));

      final copy2 = def.copyWith(asyncValidators: []);
      expect(copy2.asyncValidators, equals([]));

      final copy3 = def.copyWith(validators: [], initialValue: 'c@d.com');
      expect(copy3.initialValue, 'c@d.com');
      expect(copy3.asyncValidators, equals([asyncVal1]));
    });

    test('valueType and createValidator work correctly', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [_TestValidator<String>()],
      );

      expect(def.valueType, String);
      expect(def.createValidator(), isNotNull);
    });

    test('equality and hashCode reflect asyncValidators parameter', () {
      const asyncVal = _TestAsyncValidator<String>();
      const def1 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncVal],
        initialValue: 'a@b.com',
        group: 'step1',
      );
      const def2 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncVal],
        initialValue: 'a@b.com',
        group: 'step1',
      );
      const def3 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [],
        initialValue: 'a@b.com',
        group: 'step1',
      );
      const def4 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
        group: 'step1',
      );

      expect(def1, equals(def2));
      expect(def1.hashCode, equals(def2.hashCode));

      expect(def1, isNot(equals(def3)));
      expect(def1.hashCode, isNot(equals(def3.hashCode)));

      expect(def1, isNot(equals(def4)));
      expect(def1.hashCode, isNot(equals(def4.hashCode)));
    });

    test('toString includes asyncValidators parameter', () {
      const asyncVal = _TestAsyncValidator<String>();
      const defWithAsync = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        asyncValidators: [asyncVal],
      );
      const defNullAsync = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
      );

      expect(defWithAsync.toString(), contains('asyncValidators: ['));
      expect(defNullAsync.toString(), contains('asyncValidators: null'));
    });
  });
}
