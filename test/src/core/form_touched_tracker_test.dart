import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/core/form_touched_tracker.dart';

void main() {
  group('FormTouchedTracker', () {
    group('Initialization and touchedFields', () {
      test('initializes empty tracker by default', () {
        final tracker = FormTouchedTracker();
        expect(tracker.touchedFields, isEmpty);
      });

      test('initializes with provided field names set to false', () {
        final tracker = FormTouchedTracker(['username', 'email']);
        expect(
          tracker.touchedFields,
          equals({'username': false, 'email': false}),
        );
      });

      test('touchedFields returns an unmodifiable map', () {
        final tracker = FormTouchedTracker(['username']);
        expect(
          () => tracker.touchedFields['username'] = true,
          throwsUnsupportedError,
        );
      });
    });

    group('initialize', () {
      test('clears existing tracked fields and sets new fields to false', () {
        final tracker = FormTouchedTracker(['username']);
        tracker.markTouched('username');
        expect(tracker.isTouched('username'), isTrue);

        tracker.initialize(['email', 'age']);
        expect(tracker.isTouched('username'), isFalse);
        expect(tracker.isTouched('email'), isFalse);
        expect(tracker.isTouched('age'), isFalse);
        expect(tracker.touchedFields, equals({'email': false, 'age': false}));
      });
    });

    group('markTouched and isTouched', () {
      test('markTouched defaults to marking field as true', () {
        final tracker = FormTouchedTracker(['username']);
        tracker.markTouched('username');
        expect(tracker.isTouched('username'), isTrue);
      });

      test('markTouched can mark field as false explicitly', () {
        final tracker = FormTouchedTracker(['username']);
        tracker.markTouched('username');
        expect(tracker.isTouched('username'), isTrue);

        tracker.markTouched('username', false);
        expect(tracker.isTouched('username'), isFalse);
      });

      test('markTouched tracks and marks a new field if not previously tracked',
          () {
        final tracker = FormTouchedTracker();
        tracker.markTouched('newField');
        expect(tracker.isTouched('newField'), isTrue);
        expect(tracker.touchedFields, equals({'newField': true}));
      });

      test('isTouched returns false for untracked field', () {
        final tracker = FormTouchedTracker(['username']);
        expect(tracker.isTouched('unknown'), isFalse);
      });
    });

    group('markAllTouched', () {
      test('marks all tracked fields as true', () {
        final tracker = FormTouchedTracker(['username', 'email', 'age']);
        tracker.markAllTouched();
        expect(
          tracker.touchedFields,
          equals({'username': true, 'email': true, 'age': true}),
        );
      });
    });

    group('reset', () {
      test('resets all tracked fields to false', () {
        final tracker = FormTouchedTracker(['username', 'email']);
        tracker.markAllTouched();
        expect(tracker.isTouched('username'), isTrue);
        expect(tracker.isTouched('email'), isTrue);

        tracker.reset();
        expect(tracker.isTouched('username'), isFalse);
        expect(tracker.isTouched('email'), isFalse);
        expect(
          tracker.touchedFields,
          equals({'username': false, 'email': false}),
        );
      });
    });

    group('remove and removeFields', () {
      test('remove removes single field from tracking', () {
        final tracker = FormTouchedTracker(['username', 'email']);
        tracker.remove('username');

        expect(tracker.isTouched('username'), isFalse);
        expect(tracker.touchedFields, equals({'email': false}));
      });

      test('removeFields removes multiple fields from tracking', () {
        final tracker = FormTouchedTracker(['username', 'email', 'age']);
        tracker.removeFields(['username', 'age']);

        expect(tracker.touchedFields, equals({'email': false}));
      });
    });
  });
}
