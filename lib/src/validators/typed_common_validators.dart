import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'validator.dart';
import 'validator_localizations.dart';

/// A collection of commonly used validators with built-in localization support.
///
/// This class provides static methods to create validators for common use cases
/// such as required fields, email validation, length validation, etc.
/// All validators support automatic localization based on the current context.
class TypedCommonValidators {
  TypedCommonValidators._(); // Private constructor to prevent instantiation

  /// Creates a validator that requires a non-null, non-empty value.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<T> required<T>({
    BuildContext? context,
    String? errorText,
  }) {
    return _RequiredValidator<T>(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).requiredFieldError
          : 'This field is required.',
    );
  }

  /// Creates a validator that checks for valid email format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> email({
    BuildContext? context,
    String? errorText,
  }) {
    return _EmailValidator(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).invalidEmailError
          : 'Please enter a valid email address.',
    );
  }

  /// Creates a validator that checks minimum string length.
  ///
  /// [minLength] is the minimum required length.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> minLength(
    int minLength, {
    BuildContext? context,
    String? errorText,
  }) {
    return _MinLengthValidator(
      minLength: minLength,
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).minLengthError(minLength)
          : 'Must be at least $minLength characters long.',
    );
  }

  /// Creates a validator that checks for a custom validator.
  ///
  /// [validator] is the custom validator function.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<T> custom<T>(
    String? Function(T? value, BuildContext context) validator, {
    BuildContext? context,
    String? errorText,
  }) {
    return _CustomValidator<T>(
      validator: validator,
    );
  }

  /// Creates a validator that checks maximum string length.
  ///
  /// [maxLength] is the maximum allowed length.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> maxLength(
    int maxLength, {
    BuildContext? context,
    String? errorText,
  }) {
    return _MaxLengthValidator(
      maxLength: maxLength,
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).maxLengthError(maxLength)
          : 'Must be at most $maxLength characters long.',
    );
  }

  /// Creates a validator that checks if the value matches a pattern.
  ///
  /// [pattern] is the regular expression to match against.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> pattern(
    RegExp pattern, {
    BuildContext? context,
    String? errorText,
  }) {
    return _PatternValidator(
      pattern: pattern,
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).invalidPatternError
          : 'Please enter a valid format.',
    );
  }

  /// Creates a validator that checks if the value is a valid number.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> numeric({
    BuildContext? context,
    String? errorText,
  }) {
    return _NumericValidator(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).invalidNumberError
          : 'Please enter a valid number.',
    );
  }

  /// Creates a validator that checks minimum numeric value.
  ///
  /// [minValue] is the minimum allowed value.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<num> min(
    num minValue, {
    BuildContext? context,
    String? errorText,
  }) {
    return _MinValueValidator(
      minValue: minValue,
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).minValueError(minValue)
              : 'Must be at least $minValue.'),
    );
  }

  /// Creates a validator that checks maximum numeric value.
  ///
  /// [maxValue] is the maximum allowed value.
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<num> max(
    num maxValue, {
    BuildContext? context,
    String? errorText,
  }) {
    return _MaxValueValidator(
      maxValue: maxValue,
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).maxValueError(maxValue)
              : 'Must be at most $maxValue.'),
    );
  }

  /// Creates a validator that checks for valid URL format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> url({
    BuildContext? context,
    String? errorText,
  }) {
    return _UrlValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidUrlError
              : 'Please enter a valid URL.'),
    );
  }

  /// Creates a validator that checks for valid phone number format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> phoneNumber({
    BuildContext? context,
    String? errorText,
  }) {
    return _PhoneValidator(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).invalidPhoneError
          : 'Please enter a valid phone number.',
    );
  }

  /// Creates a validator that checks for valid credit card number format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> creditCard({
    BuildContext? context,
    String? errorText,
  }) {
    return _CreditCardValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidCreditCardError
              : 'Please enter a valid credit card number.'),
    );
  }

  /// Creates a validator that checks for valid date string format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> dateString({
    BuildContext? context,
    String? errorText,
  }) {
    return _DateStringValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidDateError
              : 'Please enter a valid date.'),
    );
  }

  /// Creates a validator that checks for valid IP address format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> ipAddress({
    BuildContext? context,
    String? errorText,
  }) {
    return _IpAddressValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidIpError
              : 'Please enter a valid IP address.'),
    );
  }

  /// Creates a validator that checks for valid UUID format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> uuid({
    BuildContext? context,
    String? errorText,
  }) {
    return _UuidValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidUuidError
              : 'Please enter a valid UUID.'),
    );
  }

  /// Creates a validator that checks for valid JSON format.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> json({
    BuildContext? context,
    String? errorText,
  }) {
    return _JsonValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidJsonError
              : 'Please enter valid JSON.'),
    );
  }

  /// Creates a validator that allows only alphanumeric characters.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> alphanumeric({
    BuildContext? context,
    String? errorText,
  }) {
    return _AlphanumericValidator(
      errorText: errorText ??
          (context != null
              ? ValidatorLocalizations.of(context).invalidAlphanumericError
              : 'Only letters and numbers are allowed.'),
    );
  }

  /// Creates a validator that allows only alphabetic characters.
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<String> alphabetic({
    BuildContext? context,
    String? errorText,
  }) {
    return _AlphabeticValidator(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).invalidAlphabeticError
          : 'Only letters are allowed.',
    );
  }

  /// Creates a validator that requires a boolean value to be true.
  ///
  /// This is specifically designed for checkboxes that must be checked
  /// (e.g., "I agree to terms and conditions").
  ///
  /// [context] is used for localization. If null, uses default English messages.
  /// [errorText] overrides the localized message if provided.
  static Validator<bool> mustBeTrue({
    BuildContext? context,
    String? errorText,
  }) {
    return _MustBeTrueValidator(
      errorText: errorText,
      fallbackErrorText: context != null
          ? ValidatorLocalizations.of(context).mustBeTrueError
          : 'This field must be checked.',
    );
  }
}

// Private validator implementations

class _RequiredValidator<T> extends Validator<T> {
  const _RequiredValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(T? value, BuildContext context) {
    final localizedError =
        errorText ?? ValidatorLocalizations.of(context).requiredFieldError;
    if (value == null) return localizedError;
    if (value is String && value.isEmpty) return localizedError;
    if (value is Iterable && value.isEmpty) return localizedError;
    if (value is Map && value.isEmpty) return localizedError;
    return null;
  }
}

class _CustomValidator<T> extends Validator<T> {
  const _CustomValidator({required this.validator});

  final String? Function(T? value, BuildContext context) validator;

  @override
  String? validate(T? value, BuildContext context) {
    return validator(value, context);
  }
}

class _EmailValidator extends Validator<String> {
  const _EmailValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_emailRegex.hasMatch(value)) {
      return errorText ?? ValidatorLocalizations.of(context).invalidEmailError;
    }
    return null;
  }
}

class _MinLengthValidator extends Validator<String> {
  const _MinLengthValidator({
    required this.minLength,
    this.errorText,
    required this.fallbackErrorText,
  });

  final int minLength;
  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return errorText ??
          ValidatorLocalizations.of(context).minLengthError(minLength);
    }
    return null;
  }
}

class _MaxLengthValidator extends Validator<String> {
  const _MaxLengthValidator({
    required this.maxLength,
    this.errorText,
    required this.fallbackErrorText,
  });

  final int maxLength;
  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (value.length > maxLength) {
      return errorText ??
          ValidatorLocalizations.of(context).maxLengthError(maxLength);
    }
    return null;
  }
}

class _PatternValidator extends Validator<String> {
  const _PatternValidator({
    required this.pattern,
    this.errorText,
    required this.fallbackErrorText,
  });

  final RegExp pattern;
  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!pattern.hasMatch(value)) {
      return errorText ??
          ValidatorLocalizations.of(context).invalidPatternError;
    }
    return null;
  }
}

class _NumericValidator extends Validator<String> {
  const _NumericValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (num.tryParse(value) == null) {
      return errorText ?? ValidatorLocalizations.of(context).invalidNumberError;
    }
    return null;
  }
}

class _MinValueValidator extends Validator<num> {
  const _MinValueValidator({required this.minValue, required this.errorText});

  final num minValue;
  final String errorText;

  @override
  String? validate(num? value, BuildContext context) {
    if (value == null) return null;
    if (value < minValue) return errorText;
    return null;
  }
}

class _MaxValueValidator extends Validator<num> {
  const _MaxValueValidator({required this.maxValue, required this.errorText});

  final num maxValue;
  final String errorText;

  @override
  String? validate(num? value, BuildContext context) {
    if (value == null) return null;
    if (value > maxValue) return errorText;
    return null;
  }
}

class _UrlValidator extends Validator<String> {
  const _UrlValidator({required this.errorText});

  final String errorText;
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_urlRegex.hasMatch(value)) return errorText;
    return null;
  }
}

class _PhoneValidator extends Validator<String> {
  const _PhoneValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]{10,}$',
  );

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_phoneRegex.hasMatch(value)) {
      return errorText ?? ValidatorLocalizations.of(context).invalidPhoneError;
    }
    return null;
  }
}

class _CreditCardValidator extends Validator<String> {
  const _CreditCardValidator({required this.errorText});

  final String errorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Check if it's all digits and has valid length
    if (!RegExp(r'^\d{13,19}$').hasMatch(cleanValue)) return errorText;

    // Luhn algorithm check
    if (!_isValidLuhn(cleanValue)) return errorText;

    return null;
  }

  bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}

class _DateStringValidator extends Validator<String> {
  const _DateStringValidator({required this.errorText});

  final String errorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return errorText;
    }
  }
}

class _IpAddressValidator extends Validator<String> {
  const _IpAddressValidator({required this.errorText});

  final String errorText;
  static final RegExp _ipv4Regex = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );
  static final RegExp _ipv6Regex = RegExp(
    r'^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$',
  );

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_ipv4Regex.hasMatch(value) && !_ipv6Regex.hasMatch(value)) {
      return errorText;
    }
    return null;
  }
}

class _UuidValidator extends Validator<String> {
  const _UuidValidator({required this.errorText});

  final String errorText;
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_uuidRegex.hasMatch(value)) return errorText;
    return null;
  }
}

class _JsonValidator extends Validator<String> {
  const _JsonValidator({required this.errorText});

  final String errorText;

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;

    try {
      jsonDecode(value);
      return null;
    } catch (e) {
      return errorText;
    }
  }
}

class _AlphanumericValidator extends Validator<String> {
  const _AlphanumericValidator({required this.errorText});

  final String errorText;
  static final RegExp _alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_alphanumericRegex.hasMatch(value)) return errorText;
    return null;
  }
}

class _AlphabeticValidator extends Validator<String> {
  const _AlphabeticValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;
  static final RegExp _alphabeticRegex = RegExp(r'^[a-zA-Z]+$');

  @override
  String? validate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) return null;
    if (!_alphabeticRegex.hasMatch(value)) {
      return errorText ??
          ValidatorLocalizations.of(context).invalidAlphabeticError;
    }
    return null;
  }
}

class _MustBeTrueValidator extends Validator<bool> {
  const _MustBeTrueValidator({
    this.errorText,
    required this.fallbackErrorText,
  });

  final String? errorText;
  final String fallbackErrorText;

  @override
  String? validate(bool? value, BuildContext context) {
    if (value != true) {
      return errorText ?? ValidatorLocalizations.of(context).mustBeTrueError;
    }
    return null;
  }
}
