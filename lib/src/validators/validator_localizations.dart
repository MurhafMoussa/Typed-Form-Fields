import 'package:flutter/widgets.dart';

import 'validator_localizations_delegate.dart';

/// Abstract class that defines the interface for validator localizations.
///
/// This class provides localized error messages for form validators.
/// Implementations should provide translations for all required messages.
abstract class ValidatorLocalizations {
  const ValidatorLocalizations();

  /// The current locale for these localizations.
  Locale get locale;

  /// Retrieves the [ValidatorLocalizations] from the given [context].
  ///
  /// Returns the localized validator messages for the current locale.
  /// If no localizations are found, returns [EnglishValidatorLocalizations].
  static ValidatorLocalizations of(BuildContext context) {
    final localizations = Localizations.of(context, ValidatorLocalizations);
    if (localizations != null) {
      return localizations;
    }
    // Fallback to English if no localizations found
    return const EnglishValidatorLocalizations();
  }

  // Required field validation messages
  String get requiredFieldError;
  String get mustBeTrueError;

  // Email validation messages
  String get invalidEmailError;

  // Length validation messages
  String minLengthError(int minLength);

  String maxLengthError(int maxLength);

  // Numeric validation messages
  String get invalidNumberError;
  String minValueError(num minValue);
  String maxValueError(num maxValue);

  // Pattern validation messages
  String get invalidPatternError;

  // URL validation messages
  String get invalidUrlError;

  // Phone validation messages
  String get invalidPhoneError;

  // Credit card validation messages
  String get invalidCreditCardError;

  // Date validation messages
  String get invalidDateError;

  // IP address validation messages
  String get invalidIpError;

  // UUID validation messages
  String get invalidUuidError;

  // JSON validation messages
  String get invalidJsonError;

  // Alphanumeric validation messages
  String get invalidAlphanumericError;

  // Alphabetic validation messages
  String get invalidAlphabeticError;

  // Conditional validation messages
  String get conditionalValidationError;

  // Cross-field validation messages
  String get fieldsMismatchError;
  String fieldsDifferentError(String fieldName);
  String requiredWhenFieldValueError(String fieldName, String value);
  String requiredWhenFieldNotEmptyError(String fieldName);
  String get dateBeforeError;
  String get dateAfterError;
  String greaterThanFieldError(String fieldName);
  String lessThanFieldError(String fieldName);
  String get sumConditionError;
  String get atLeastOneRequiredError;
  // Async validation messages
  String get asyncValidationError;
}
