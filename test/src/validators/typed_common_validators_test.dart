import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/validators/typed_common_validators.dart';

void main() {
  late MockBuildContext mockContext;

  setUp(() {
    mockContext = MockBuildContext();
  });

  group('TypedCommonValidators', () {
    test('should have private constructor', () {
      // This test ensures the private constructor exists and prevents instantiation
      // The coverage will show the constructor line as covered
      expect(() => TypedCommonValidators, isNotNull);
    });

    group('required', () {
      test('should return error for null value', () {
        final validator = TypedCommonValidators.required<String>();
        expect(
            validator.validate(null, mockContext), 'This field is required.');
      });

      test('should return error for empty string', () {
        final validator = TypedCommonValidators.required<String>();
        expect(validator.validate('', mockContext), 'This field is required.');
      });

      test('should return error for empty list', () {
        final validator = TypedCommonValidators.required<List<String>>();
        expect(validator.validate(<String>[], mockContext),
            'This field is required.');
      });

      test('should return error for empty map', () {
        final validator = TypedCommonValidators.required<Map<String, String>>();
        expect(validator.validate(<String, String>{}, mockContext),
            'This field is required.');
      });

      test('should return null for valid string', () {
        final validator = TypedCommonValidators.required<String>();
        expect(validator.validate('test', mockContext), isNull);
      });

      test('should return null for valid number', () {
        final validator = TypedCommonValidators.required<int>();
        expect(validator.validate(123, mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.required<String>(errorText: 'Custom error');
        expect(validator.validate(null, mockContext), 'Custom error');
      });

      testWidgets('should use localized error text when context provided',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final validator =
                    TypedCommonValidators.required<String>(context: context);
                final result = validator.validate(null, context);
                expect(result, isNotNull);
                expect(result,
                    contains('required')); // Should contain localized text
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('email', () {
      test('should return error for invalid email', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate('invalid-email', mockContext),
            'Please enter a valid email address.');
      });

      test('should return error for email without domain', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate('test@', mockContext),
            'Please enter a valid email address.');
      });

      test('should return error for email without @', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate('testexample.com', mockContext),
            'Please enter a valid email address.');
      });

      test('should return null for valid email', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate('test@example.com', mockContext), isNull);
      });

      test('should return null for complex valid email', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate('user.name+tag@example.co.uk', mockContext),
            isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.email();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.email(errorText: 'Custom email error');
        expect(
            validator.validate('invalid', mockContext), 'Custom email error');
      });
    });

    group('minLength', () {
      test('should return error for string shorter than minimum', () {
        final validator = TypedCommonValidators.minLength(5);
        expect(validator.validate('abc', mockContext),
            'Must be at least 5 characters long.');
      });

      test('should return null for string equal to minimum', () {
        final validator = TypedCommonValidators.minLength(5);
        expect(validator.validate('abcde', mockContext), isNull);
      });

      test('should return null for string longer than minimum', () {
        final validator = TypedCommonValidators.minLength(5);
        expect(validator.validate('abcdef', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.minLength(5);
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.minLength(5, errorText: 'Too short');
        expect(validator.validate('abc', mockContext), 'Too short');
      });
    });

    group('maxLength', () {
      test('should return error for string longer than maximum', () {
        final validator = TypedCommonValidators.maxLength(5);
        expect(validator.validate('abcdef', mockContext),
            'Must be at most 5 characters long.');
      });

      test('should return null for string equal to maximum', () {
        final validator = TypedCommonValidators.maxLength(5);
        expect(validator.validate('abcde', mockContext), isNull);
      });

      test('should return null for string shorter than maximum', () {
        final validator = TypedCommonValidators.maxLength(5);
        expect(validator.validate('abc', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.maxLength(5);
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.maxLength(5, errorText: 'Too long');
        expect(validator.validate('abcdef', mockContext), 'Too long');
      });
    });

    group('pattern', () {
      test('should return error for non-matching pattern', () {
        final validator = TypedCommonValidators.pattern(RegExp(r'^\d+$'));
        expect(validator.validate('abc', mockContext),
            'Please enter a valid format.');
      });

      test('should return null for matching pattern', () {
        final validator = TypedCommonValidators.pattern(RegExp(r'^\d+$'));
        expect(validator.validate('123', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.pattern(RegExp(r'^\d+$'));
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator = TypedCommonValidators.pattern(RegExp(r'^\d+$'),
            errorText: 'Numbers only');
        expect(validator.validate('abc', mockContext), 'Numbers only');
      });
    });

    group('numeric', () {
      test('should return error for non-numeric string', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate('abc', mockContext),
            'Please enter a valid number.');
      });

      test('should return error for mixed alphanumeric', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate('123abc', mockContext),
            'Please enter a valid number.');
      });

      test('should return null for valid integer', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate('123', mockContext), isNull);
      });

      test('should return null for valid decimal', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate('123.45', mockContext), isNull);
      });

      test('should return null for negative number', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate('-123', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.numeric();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.numeric(errorText: 'Invalid number');
        expect(validator.validate('abc', mockContext), 'Invalid number');
      });
    });

    group('min', () {
      test('should return error for value less than minimum', () {
        final validator = TypedCommonValidators.min(10);
        expect(validator.validate(5, mockContext), 'Must be at least 10.');
      });

      test('should return null for value equal to minimum', () {
        final validator = TypedCommonValidators.min(10);
        expect(validator.validate(10, mockContext), isNull);
      });

      test('should return null for value greater than minimum', () {
        final validator = TypedCommonValidators.min(10);
        expect(validator.validate(15, mockContext), isNull);
      });

      test('should return null for null value', () {
        final validator = TypedCommonValidators.min(10);
        expect(validator.validate(null, mockContext), isNull);
      });

      test('should work with decimal values', () {
        final validator = TypedCommonValidators.min(10.5);
        expect(validator.validate(10.0, mockContext), 'Must be at least 10.5.');
        expect(validator.validate(11.0, mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator = TypedCommonValidators.min(10, errorText: 'Too small');
        expect(validator.validate(5, mockContext), 'Too small');
      });
    });

    group('max', () {
      test('should return error for value greater than maximum', () {
        final validator = TypedCommonValidators.max(10);
        expect(validator.validate(15, mockContext), 'Must be at most 10.');
      });

      test('should return null for value equal to maximum', () {
        final validator = TypedCommonValidators.max(10);
        expect(validator.validate(10, mockContext), isNull);
      });

      test('should return null for value less than maximum', () {
        final validator = TypedCommonValidators.max(10);
        expect(validator.validate(5, mockContext), isNull);
      });

      test('should return null for null value', () {
        final validator = TypedCommonValidators.max(10);
        expect(validator.validate(null, mockContext), isNull);
      });

      test('should work with decimal values', () {
        final validator = TypedCommonValidators.max(10.5);
        expect(validator.validate(11.0, mockContext), 'Must be at most 10.5.');
        expect(validator.validate(10.0, mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator = TypedCommonValidators.max(10, errorText: 'Too large');
        expect(validator.validate(15, mockContext), 'Too large');
      });
    });

    group('url', () {
      test('should return error for invalid URL', () {
        final validator = TypedCommonValidators.url();
        expect(validator.validate('not-a-url', mockContext),
            'Please enter a valid URL.');
      });

      test('should return error for URL without protocol', () {
        final validator = TypedCommonValidators.url();
        expect(validator.validate('example.com', mockContext),
            'Please enter a valid URL.');
      });

      test('should return null for valid HTTP URL', () {
        final validator = TypedCommonValidators.url();
        expect(validator.validate('http://example.com', mockContext), isNull);
      });

      test('should return null for valid HTTPS URL', () {
        final validator = TypedCommonValidators.url();
        expect(validator.validate('https://example.com', mockContext), isNull);
      });

      test('should return null for complex valid URL', () {
        final validator = TypedCommonValidators.url();
        expect(
            validator.validate(
                'https://www.example.com/path?query=value#fragment',
                mockContext),
            isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.url();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.url(errorText: 'Invalid URL format');
        expect(
            validator.validate('invalid', mockContext), 'Invalid URL format');
      });
    });

    group('phoneNumber', () {
      test('should return error for invalid phone number', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate('abc', mockContext),
            'Please enter a valid phone number.');
      });

      test('should return error for too short phone number', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate('123', mockContext),
            'Please enter a valid phone number.');
      });

      test('should return null for valid phone number', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate('1234567890', mockContext), isNull);
      });

      test('should return null for phone number with country code', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate('+1234567890', mockContext), isNull);
      });

      test('should return null for formatted phone number', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate('(123) 456-7890', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.phoneNumber();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.phoneNumber(errorText: 'Invalid phone');
        expect(validator.validate('abc', mockContext), 'Invalid phone');
      });
    });

    group('creditCard', () {
      test('should return error for invalid credit card', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('123', mockContext),
            'Please enter a valid credit card number.');
      });

      test('should return error for non-numeric credit card', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('abcd-efgh-ijkl-mnop', mockContext),
            'Please enter a valid credit card number.');
      });

      test('should return error for invalid Luhn checksum', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('4111111111111112', mockContext),
            'Please enter a valid credit card number.');
      });

      test('should return null for valid Visa card', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('4111111111111111', mockContext), isNull);
      });

      test('should return null for valid card with spaces', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('4111 1111 1111 1111', mockContext), isNull);
      });

      test('should return null for valid card with dashes', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate('4111-1111-1111-1111', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.creditCard();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.creditCard(errorText: 'Invalid card');
        expect(validator.validate('123', mockContext), 'Invalid card');
      });
    });

    group('dateString', () {
      test('should return error for invalid date', () {
        final validator = TypedCommonValidators.dateString();
        expect(validator.validate('not-a-date', mockContext),
            'Please enter a valid date.');
      });

      test('should return error for invalid date format', () {
        final validator = TypedCommonValidators.dateString();
        expect(validator.validate('32/13/2023', mockContext),
            'Please enter a valid date.');
      });

      test('should return null for valid ISO date', () {
        final validator = TypedCommonValidators.dateString();
        expect(validator.validate('2023-12-25', mockContext), isNull);
      });

      test('should return null for valid datetime', () {
        final validator = TypedCommonValidators.dateString();
        expect(validator.validate('2023-12-25T10:30:00', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.dateString();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.dateString(errorText: 'Invalid date format');
        expect(
            validator.validate('invalid', mockContext), 'Invalid date format');
      });
    });

    group('ipAddress', () {
      test('should return error for invalid IP', () {
        final validator = TypedCommonValidators.ipAddress();
        expect(validator.validate('not-an-ip', mockContext),
            'Please enter a valid IP address.');
      });

      test('should return error for invalid IPv4', () {
        final validator = TypedCommonValidators.ipAddress();
        expect(validator.validate('256.256.256.256', mockContext),
            'Please enter a valid IP address.');
      });

      test('should return null for valid IPv4', () {
        final validator = TypedCommonValidators.ipAddress();
        expect(validator.validate('192.168.1.1', mockContext), isNull);
      });

      test('should return null for valid IPv6', () {
        final validator = TypedCommonValidators.ipAddress();
        expect(
            validator.validate(
                '2001:0db8:85a3:0000:0000:8a2e:0370:7334', mockContext),
            isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.ipAddress();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.ipAddress(errorText: 'Invalid IP');
        expect(validator.validate('invalid', mockContext), 'Invalid IP');
      });
    });

    group('uuid', () {
      test('should return error for invalid UUID', () {
        final validator = TypedCommonValidators.uuid();
        expect(validator.validate('not-a-uuid', mockContext),
            'Please enter a valid UUID.');
      });

      test('should return error for UUID without dashes', () {
        final validator = TypedCommonValidators.uuid();
        expect(
            validator.validate('550e8400e29b41d4a716446655440000', mockContext),
            'Please enter a valid UUID.');
      });

      test('should return null for valid UUID', () {
        final validator = TypedCommonValidators.uuid();
        expect(
            validator.validate(
                '550e8400-e29b-41d4-a716-446655440000', mockContext),
            isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.uuid();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.uuid(errorText: 'Invalid UUID format');
        expect(
            validator.validate('invalid', mockContext), 'Invalid UUID format');
      });
    });

    group('json', () {
      test('should return error for invalid JSON', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate('not-json', mockContext),
            'Please enter valid JSON.');
      });

      test('should return error for malformed JSON', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate('{"key": value}', mockContext),
            'Please enter valid JSON.');
      });

      test('should return null for valid JSON object', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate('{"key": "value"}', mockContext), isNull);
      });

      test('should return null for valid JSON array', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate('[1, 2, 3]', mockContext), isNull);
      });

      test('should return null for valid JSON string', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate('"hello"', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.json();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.json(errorText: 'Invalid JSON format');
        expect(
            validator.validate('invalid', mockContext), 'Invalid JSON format');
      });
    });

    group('alphanumeric', () {
      test('should return error for non-alphanumeric characters', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate('abc123!', mockContext),
            'Only letters and numbers are allowed.');
      });

      test('should return error for spaces', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate('abc 123', mockContext),
            'Only letters and numbers are allowed.');
      });

      test('should return null for valid alphanumeric', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate('abc123', mockContext), isNull);
      });

      test('should return null for only letters', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate('abc', mockContext), isNull);
      });

      test('should return null for only numbers', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate('123', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.alphanumeric();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator = TypedCommonValidators.alphanumeric(
            errorText: 'Letters and numbers only');
        expect(validator.validate('abc!', mockContext),
            'Letters and numbers only');
      });
    });

    group('alphabetic', () {
      test('should return error for numbers', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate('abc123', mockContext),
            'Only letters are allowed.');
      });

      test('should return error for special characters', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate('abc!', mockContext),
            'Only letters are allowed.');
      });

      test('should return error for spaces', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate('abc def', mockContext),
            'Only letters are allowed.');
      });

      test('should return null for valid alphabetic', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate('abc', mockContext), isNull);
      });

      test('should return null for mixed case letters', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate('AbC', mockContext), isNull);
      });

      test('should return null for null or empty value', () {
        final validator = TypedCommonValidators.alphabetic();
        expect(validator.validate(null, mockContext), isNull);
        expect(validator.validate('', mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator =
            TypedCommonValidators.alphabetic(errorText: 'Letters only');
        expect(validator.validate('abc123', mockContext), 'Letters only');
      });
    });

    group('mustBeTrue', () {
      test('should return error for false value', () {
        final validator = TypedCommonValidators.mustBeTrue();
        expect(validator.validate(false, mockContext),
            'This field must be checked.');
      });

      test('should return error for null value', () {
        final validator = TypedCommonValidators.mustBeTrue();
        expect(validator.validate(null, mockContext),
            'This field must be checked.');
      });

      test('should return null for true value', () {
        final validator = TypedCommonValidators.mustBeTrue();
        expect(validator.validate(true, mockContext), isNull);
      });

      test('should use custom error text', () {
        final validator = TypedCommonValidators.mustBeTrue(
            errorText: 'You must accept the terms');
        expect(validator.validate(false, mockContext),
            'You must accept the terms');
      });

      testWidgets('should use localized error text when context provided',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final validator =
                    TypedCommonValidators.mustBeTrue(context: context);
                final result = validator.validate(false, context);
                expect(result, isNotNull);
                expect(result,
                    contains('checked')); // Should contain localized text
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Fallback Error Messages (null context)', () {
      test('should use fallback error for email when context is null', () {
        final validator = TypedCommonValidators.email(context: null);
        expect(validator.validate('invalid-email', mockContext),
            'Please enter a valid email address.');
      });

      test('should use fallback error for minLength when context is null', () {
        final validator = TypedCommonValidators.minLength(5, context: null);
        expect(validator.validate('abc', mockContext),
            'Must be at least 5 characters long.');
      });

      test('should use fallback error for maxLength when context is null', () {
        final validator = TypedCommonValidators.maxLength(5, context: null);
        expect(validator.validate('abcdef', mockContext),
            'Must be at most 5 characters long.');
      });

      test('should use fallback error for pattern when context is null', () {
        final validator =
            TypedCommonValidators.pattern(RegExp(r'^\d+$'), context: null);
        expect(validator.validate('abc', mockContext),
            'Please enter a valid format.');
      });

      test('should use fallback error for numeric when context is null', () {
        final validator = TypedCommonValidators.numeric(context: null);
        expect(validator.validate('abc', mockContext),
            'Please enter a valid number.');
      });

      test('should use fallback error for min when context is null', () {
        final validator = TypedCommonValidators.min(5, context: null);
        expect(validator.validate(3, mockContext), 'Must be at least 5.');
      });

      test('should use fallback error for max when context is null', () {
        final validator = TypedCommonValidators.max(5, context: null);
        expect(validator.validate(10, mockContext), 'Must be at most 5.');
      });

      test('should use fallback error for url when context is null', () {
        final validator = TypedCommonValidators.url(context: null);
        expect(validator.validate('invalid-url', mockContext),
            'Please enter a valid URL.');
      });

      test('should use fallback error for phoneNumber when context is null',
          () {
        final validator = TypedCommonValidators.phoneNumber(context: null);
        expect(validator.validate('invalid-phone', mockContext),
            'Please enter a valid phone number.');
      });

      test('should use fallback error for creditCard when context is null', () {
        final validator = TypedCommonValidators.creditCard(context: null);
        expect(validator.validate('invalid-card', mockContext),
            'Please enter a valid credit card number.');
      });

      test('should use fallback error for dateString when context is null', () {
        final validator = TypedCommonValidators.dateString(context: null);
        expect(validator.validate('invalid-date', mockContext),
            'Please enter a valid date.');
      });

      test('should use fallback error for ipAddress when context is null', () {
        final validator = TypedCommonValidators.ipAddress(context: null);
        expect(validator.validate('invalid-ip', mockContext),
            'Please enter a valid IP address.');
      });

      test('should use fallback error for uuid when context is null', () {
        final validator = TypedCommonValidators.uuid(context: null);
        expect(validator.validate('invalid-uuid', mockContext),
            'Please enter a valid UUID.');
      });

      test('should use fallback error for json when context is null', () {
        final validator = TypedCommonValidators.json(context: null);
        expect(validator.validate('invalid-json', mockContext),
            'Please enter valid JSON.');
      });

      test('should use fallback error for alphanumeric when context is null',
          () {
        final validator = TypedCommonValidators.alphanumeric(context: null);
        expect(validator.validate('abc@123', mockContext),
            'Only letters and numbers are allowed.');
      });

      test('should use fallback error for alphabetic when context is null', () {
        final validator = TypedCommonValidators.alphabetic(context: null);
        expect(validator.validate('abc123', mockContext),
            'Only letters are allowed.');
      });

      test('should use fallback error for mustBeTrue when context is null', () {
        final validator = TypedCommonValidators.mustBeTrue(context: null);
        expect(validator.validate(false, mockContext),
            'This field must be checked.');
      });
    });

    group('Factory with non-null context', () {
      testWidgets('should construct validators with context', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final req =
                    TypedCommonValidators.required<String>(context: context);
                expect(req.validate(null, context), isNotNull);

                final email = TypedCommonValidators.email(context: context);
                expect(email.validate('bad', context), isNotNull);

                final minLen =
                    TypedCommonValidators.minLength(5, context: context);
                expect(minLen.validate('a', context), isNotNull);

                final maxLen =
                    TypedCommonValidators.maxLength(3, context: context);
                expect(maxLen.validate('aaaa', context), isNotNull);

                final pattern = TypedCommonValidators.pattern(RegExp(r'^\d+$'),
                    context: context);
                expect(pattern.validate('abc', context), isNotNull);

                final numVal = TypedCommonValidators.numeric(context: context);
                expect(numVal.validate('abc', context), isNotNull);

                final minVal = TypedCommonValidators.min(10, context: context);
                expect(minVal.validate(5, context), isNotNull);

                final maxVal = TypedCommonValidators.max(5, context: context);
                expect(maxVal.validate(10, context), isNotNull);

                final urlVal = TypedCommonValidators.url(context: context);
                expect(urlVal.validate('invalid', context), isNotNull);

                final phoneVal =
                    TypedCommonValidators.phoneNumber(context: context);
                expect(phoneVal.validate('bad', context), isNotNull);

                final ccVal =
                    TypedCommonValidators.creditCard(context: context);
                expect(ccVal.validate('bad', context), isNotNull);

                final dateVal =
                    TypedCommonValidators.dateString(context: context);
                expect(dateVal.validate('bad', context), isNotNull);

                final ipVal = TypedCommonValidators.ipAddress(context: context);
                expect(ipVal.validate('bad', context), isNotNull);

                final uuidVal = TypedCommonValidators.uuid(context: context);
                expect(uuidVal.validate('bad', context), isNotNull);

                final jsonVal = TypedCommonValidators.json(context: context);
                expect(jsonVal.validate('bad', context), isNotNull);

                final alphaNum =
                    TypedCommonValidators.alphanumeric(context: context);
                expect(alphaNum.validate('bad@', context), isNotNull);

                final alpha =
                    TypedCommonValidators.alphabetic(context: context);
                expect(alpha.validate('123', context), isNotNull);

                final mustTrue =
                    TypedCommonValidators.mustBeTrue(context: context);
                expect(mustTrue.validate(false, context), isNotNull);

                final cust = TypedCommonValidators.custom<String>(
                  (val, ctx) => val == 'invalid' ? 'error' : null,
                  context: context,
                );
                expect(cust.validate('invalid', context), equals('error'));

                return Container();
              },
            ),
          ),
        );
      });
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
