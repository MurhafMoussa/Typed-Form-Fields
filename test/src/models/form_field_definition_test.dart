import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/models/form_field_definition.dart';
import 'package:typed_form_fields/src/validators/validator.dart';

class _TestValidator<T> implements Validator<T> {
  const _TestValidator();

  @override
  String? validate(T? value, dynamic context) => null;
}

void main() {
  group('FormFieldDefinition', () {
    test('defaults group to null', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
      );

      expect(def.group, isNull);
    });

    test('accepts optional group parameter in constructor', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'test@example.com',
        group: 'step1',
      );

      expect(def.name, equals('email'));
      expect(def.group, equals('step1'));
      expect(def.initialValue, equals('test@example.com'));
    });

    test('copyWith updates and preserves group correctly', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
        group: 'step1',
      );

      final copy1 = def.copyWith(name: 'newEmail');
      expect(copy1.name, 'newEmail');
      expect(copy1.initialValue, 'a@b.com');
      expect(copy1.group, 'step1');

      final copy2 = def.copyWith(group: 'step2');
      expect(copy2.name, 'email');
      expect(copy2.group, 'step2');

      final copy3 = def.copyWith(validators: [], initialValue: 'c@d.com');
      expect(copy3.initialValue, 'c@d.com');
      expect(copy3.group, 'step1');
    });

    test('valueType and createValidator work correctly', () {
      const def = FormFieldDefinition<String>(
        name: 'email',
        validators: [_TestValidator<String>()],
      );

      expect(def.valueType, String);
      expect(def.createValidator(), isNotNull);
    });

    test('equality and hashCode reflect group parameter', () {
      const def1 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
        group: 'step1',
      );
      const def2 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
        group: 'step1',
      );
      const def3 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
        group: 'step2',
      );
      const def4 = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        initialValue: 'a@b.com',
      );

      expect(def1, equals(def2));
      expect(def1.hashCode, equals(def2.hashCode));

      expect(def1, isNot(equals(def3)));
      expect(def1.hashCode, isNot(equals(def3.hashCode)));

      expect(def1, isNot(equals(def4)));
      expect(def1.hashCode, isNot(equals(def4.hashCode)));
    });

    test('toString includes group parameter', () {
      const defWithGroup = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
        group: 'step1',
      );
      const defNullGroup = FormFieldDefinition<String>(
        name: 'email',
        validators: [],
      );

      expect(defWithGroup.toString(), contains('group: step1'));
      expect(defNullGroup.toString(), contains('group: null'));
    });
  });
}
