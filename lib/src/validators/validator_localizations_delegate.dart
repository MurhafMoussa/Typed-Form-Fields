import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'validator_localizations.dart';

/// A [LocalizationsDelegate] for [ValidatorLocalizations].
///
/// This delegate is responsible for loading the appropriate localizations
/// for the validator error messages based on the current locale.
class ValidatorLocalizationsDelegate
    extends LocalizationsDelegate<ValidatorLocalizations> {
  const ValidatorLocalizationsDelegate();

  /// A static instance of the delegate for convenience.
  static const ValidatorLocalizationsDelegate delegate =
      ValidatorLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Currently supporting English, but can be extended for other languages
    return _supportedLocales.contains(locale.languageCode);
  }

  @override
  Future<ValidatorLocalizations> load(Locale locale) {
    return SynchronousFuture<ValidatorLocalizations>(_getLocalizations(locale));
  }

  @override
  bool shouldReload(ValidatorLocalizationsDelegate old) => false;

  /// List of supported language codes.
  static const List<String> _supportedLocales = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'ar', // Arabic
  ];

  /// Returns the appropriate localizations for the given [locale].
  ValidatorLocalizations _getLocalizations(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const EnglishValidatorLocalizations();
      case 'es':
        return const SpanishValidatorLocalizations();
      case 'fr':
        return const FrenchValidatorLocalizations();
      case 'de':
        return const GermanValidatorLocalizations();

      case 'ar':
        return const ArabicValidatorLocalizations();
      default:
        return const EnglishValidatorLocalizations();
    }
  }
}

/// English implementation of [ValidatorLocalizations].
class EnglishValidatorLocalizations extends ValidatorLocalizations {
  const EnglishValidatorLocalizations();

  @override
  Locale get locale => const Locale('en');

  @override
  String get asyncValidationError => 'Validation failed.';

  @override
  String get atLeastOneRequiredError =>
      'At least one field in this group is required.';

  @override
  String get conditionalValidationError =>
      'This field is required based on other selections.';

  @override
  String get dateAfterError => 'The end date must be after the start date.';

  @override
  String get dateBeforeError => 'The start date must be before the end date.';

  @override
  String fieldsDifferentError(String fieldName) {
    return 'This field must be different from $fieldName.';
  }

  @override
  String get fieldsMismatchError => 'Fields do not match.';

  @override
  String greaterThanFieldError(String fieldName) {
    return 'The value must be greater than $fieldName.';
  }

  @override
  String get invalidAlphabeticError => 'Only letters are allowed.';

  @override
  String get invalidAlphanumericError =>
      'Only letters and numbers are allowed.';

  @override
  String get invalidCreditCardError =>
      'Please enter a valid credit card number.';

  @override
  String get invalidDateError => 'Please enter a valid date.';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String get invalidIpError => 'Please enter a valid IP address.';

  @override
  String get invalidJsonError => 'Please enter valid JSON.';

  @override
  String get invalidNumberError => 'Please enter a valid number.';

  @override
  String get invalidPatternError => 'Please enter a valid format.';

  @override
  String get invalidPhoneError => 'Please enter a valid phone number.';

  @override
  String get invalidUrlError => 'Please enter a valid URL.';

  @override
  String get invalidUuidError => 'Please enter a valid UUID.';

  @override
  String lessThanFieldError(String fieldName) {
    return 'The value must be less than $fieldName.';
  }

  @override
  String maxLengthError(int maxLength) {
    return 'Must be at most $maxLength characters long.';
  }

  @override
  String maxValueError(num maxValue) {
    return 'Must be at most $maxValue.';
  }

  @override
  String minLengthError(int minLength) {
    return 'Must be at least $minLength characters long.';
  }

  @override
  String minValueError(num minValue) {
    return 'Must be at least $minValue.';
  }

  @override
  String get mustBeTrueError => 'This field must be checked.';

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String requiredWhenFieldNotEmptyError(String fieldName) {
    return 'This field is required when $fieldName is not empty.';
  }

  @override
  String requiredWhenFieldValueError(String fieldName, String value) {
    return 'This field is required when $fieldName is $value.';
  }

  @override
  String get sumConditionError =>
      'The sum of the fields must be equal to the condition.';
}

/// Spanish implementation of [ValidatorLocalizations].
class SpanishValidatorLocalizations extends ValidatorLocalizations {
  const SpanishValidatorLocalizations();

  @override
  Locale get locale => const Locale('es');

  @override
  String get requiredFieldError => 'Este campo es obligatorio.';

  @override
  String get invalidEmailError =>
      'Por favor, introduce una dirección de correo válida.';

  @override
  String minLengthError(int minLength) =>
      'Debe tener al menos $minLength caracteres.';

  @override
  String maxLengthError(int maxLength) =>
      'Debe tener como máximo $maxLength caracteres.';

  @override
  String get invalidNumberError => 'Por favor, introduce un número válido.';

  @override
  String minValueError(num minValue) => 'Debe ser al menos $minValue.';

  @override
  String maxValueError(num maxValue) => 'Debe ser como máximo $maxValue.';

  @override
  String get invalidPatternError => 'Por favor, introduce un formato válido.';

  @override
  String get invalidUrlError => 'Por favor, introduce una URL válida.';

  @override
  String get invalidPhoneError =>
      'Por favor, introduce un número de teléfono válido.';

  @override
  String get invalidCreditCardError =>
      'Por favor, introduce un número de tarjeta de crédito válido.';

  @override
  String get invalidDateError => 'Por favor, introduce una fecha válida.';

  @override
  String get invalidIpError => 'Por favor, introduce una dirección IP válida.';

  @override
  String get invalidUuidError => 'Por favor, introduce un UUID válido.';

  @override
  String get invalidJsonError => 'Por favor, introduce JSON válido.';

  @override
  String get invalidAlphanumericError => 'Solo se permiten letras y números.';

  @override
  String get invalidAlphabeticError => 'Solo se permiten letras.';

  @override
  String get conditionalValidationError =>
      'Este campo es obligatorio según otras selecciones.';

  @override
  String get fieldsMismatchError => 'Los campos no coinciden.';

  @override
  String fieldsDifferentError(String fieldName) =>
      'Este campo debe ser diferente de $fieldName.';

  @override
  String requiredWhenFieldValueError(String fieldName, String value) =>
      'Este campo es obligatorio cuando $fieldName es $value.';

  @override
  String requiredWhenFieldNotEmptyError(String fieldName) =>
      'Este campo es obligatorio cuando se proporciona $fieldName.';

  @override
  String get dateBeforeError =>
      'La fecha de inicio debe ser anterior a la fecha de fin.';

  @override
  String get dateAfterError =>
      'La fecha de fin debe ser posterior a la fecha de inicio.';

  @override
  String greaterThanFieldError(String fieldName) =>
      'El valor debe ser mayor que $fieldName.';

  @override
  String lessThanFieldError(String fieldName) =>
      'El valor debe ser menor que $fieldName.';

  @override
  String get sumConditionError => 'No se cumple la condición de suma.';

  @override
  String get atLeastOneRequiredError =>
      'Al menos un campo de este grupo es obligatorio.';

  @override
  String get asyncValidationError => 'La validación falló.';

  @override
  String get mustBeTrueError => 'Este campo debe estar marcado.';
}

/// French implementation of [ValidatorLocalizations].
class FrenchValidatorLocalizations extends ValidatorLocalizations {
  const FrenchValidatorLocalizations();

  @override
  Locale get locale => const Locale('fr');

  @override
  String get requiredFieldError => 'Ce champ est requis.';

  @override
  String get invalidEmailError => 'Veuillez saisir une adresse email valide.';

  @override
  String minLengthError(int minLength) =>
      'Doit contenir au moins $minLength caractères.';

  @override
  String maxLengthError(int maxLength) =>
      'Doit contenir au maximum $maxLength caractères.';

  @override
  String get invalidNumberError => 'Veuillez saisir un nombre valide.';

  @override
  String minValueError(num minValue) => 'Doit être au moins $minValue.';

  @override
  String maxValueError(num maxValue) => 'Doit être au maximum $maxValue.';

  @override
  String get invalidPatternError => 'Veuillez saisir un format valide.';

  @override
  String get invalidUrlError => 'Veuillez saisir une URL valide.';

  @override
  String get invalidPhoneError =>
      'Veuillez saisir un numéro de téléphone valide.';

  @override
  String get invalidCreditCardError =>
      'Veuillez saisir un numéro de carte de crédit valide.';

  @override
  String get invalidDateError => 'Veuillez saisir une date valide.';

  @override
  String get invalidIpError => 'Veuillez saisir une adresse IP valide.';

  @override
  String get invalidUuidError => 'Veuillez saisir un UUID valide.';

  @override
  String get invalidJsonError => 'Veuillez saisir du JSON valide.';

  @override
  String get invalidAlphanumericError =>
      'Seules les lettres et les chiffres sont autorisés.';

  @override
  String get invalidAlphabeticError => 'Seules les lettres sont autorisées.';

  @override
  String get conditionalValidationError =>
      'Ce champ est obligatoire selon d\'autres sélections.';

  @override
  String get fieldsMismatchError => 'Les champs ne correspondent pas.';

  @override
  String fieldsDifferentError(String fieldName) =>
      'Ce champ doit être différent de $fieldName.';

  @override
  String requiredWhenFieldValueError(String fieldName, String value) =>
      'Ce champ est obligatoire quand $fieldName est $value.';

  @override
  String requiredWhenFieldNotEmptyError(String fieldName) =>
      'Ce champ est obligatoire quand $fieldName est fourni.';

  @override
  String get dateBeforeError =>
      'La date de début doit être antérieure à la date de fin.';

  @override
  String get dateAfterError =>
      'La date de fin doit être postérieure à la date de début.';

  @override
  String greaterThanFieldError(String fieldName) =>
      'La valeur doit être supérieure à $fieldName.';

  @override
  String lessThanFieldError(String fieldName) =>
      'La valeur doit être inférieure à $fieldName.';

  @override
  String get sumConditionError => 'La condition de somme n\'est pas remplie.';

  @override
  String get atLeastOneRequiredError =>
      'Au moins un champ de ce groupe est obligatoire.';

  @override
  String get asyncValidationError => 'La validation a échoué.';

  @override
  String get mustBeTrueError => 'Ce champ doit être coché.';
}

/// German implementation of [ValidatorLocalizations].
class GermanValidatorLocalizations extends ValidatorLocalizations {
  const GermanValidatorLocalizations();

  @override
  Locale get locale => const Locale('de');

  @override
  String get requiredFieldError => 'Dieses Feld ist erforderlich.';

  @override
  String get invalidEmailError =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String minLengthError(int minLength) =>
      'Muss mindestens $minLength Zeichen lang sein.';

  @override
  String maxLengthError(int maxLength) =>
      'Darf höchstens $maxLength Zeichen lang sein.';

  @override
  String get invalidNumberError => 'Bitte geben Sie eine gültige Zahl ein.';

  @override
  String minValueError(num minValue) => 'Muss mindestens $minValue sein.';

  @override
  String maxValueError(num maxValue) => 'Darf höchstens $maxValue sein.';

  @override
  String get invalidPatternError => 'Bitte geben Sie ein gültiges Format ein.';

  @override
  String get invalidUrlError => 'Bitte geben Sie eine gültige URL ein.';

  @override
  String get invalidPhoneError =>
      'Bitte geben Sie eine gültige Telefonnummer ein.';

  @override
  String get invalidCreditCardError =>
      'Bitte geben Sie eine gültige Kreditkartennummer ein.';

  @override
  String get invalidDateError => 'Bitte geben Sie ein gültiges Datum ein.';

  @override
  String get invalidIpError => 'Bitte geben Sie eine gültige IP-Adresse ein.';

  @override
  String get invalidUuidError => 'Bitte geben Sie eine gültige UUID ein.';

  @override
  String get invalidJsonError => 'Bitte geben Sie gültiges JSON ein.';

  @override
  String get invalidAlphanumericError =>
      'Nur Buchstaben und Zahlen sind erlaubt.';

  @override
  String get invalidAlphabeticError => 'Nur Buchstaben sind erlaubt.';

  @override
  String get conditionalValidationError =>
      'Dieses Feld ist basierend auf anderen Auswahlen erforderlich.';

  @override
  String get fieldsMismatchError => 'Die Felder stimmen nicht überein.';

  @override
  String get asyncValidationError => 'Validierung fehlgeschlagen.';

  @override
  String get atLeastOneRequiredError =>
      'Mindestens ein Feld in dieser Gruppe ist erforderlich.';

  @override
  String get dateAfterError => 'Die Enddatum muss nach dem Startdatum liegen.';

  @override
  String get dateBeforeError => 'Das Startdatum muss vor dem Enddatum liegen.';

  @override
  String fieldsDifferentError(String fieldName) {
    return 'Dieses Feld muss unterschiedlich von $fieldName sein.';
  }

  @override
  String greaterThanFieldError(String fieldName) {
    return 'Der Wert muss größer als $fieldName sein.';
  }

  @override
  String lessThanFieldError(String fieldName) {
    return 'Der Wert muss kleiner als $fieldName sein.';
  }

  @override
  String get mustBeTrueError => 'Dieses Feld muss ausgewählt sein.';

  @override
  String requiredWhenFieldNotEmptyError(String fieldName) {
    return 'Dieses Feld ist erforderlich, wenn $fieldName angegeben ist.';
  }

  @override
  String requiredWhenFieldValueError(String fieldName, String value) {
    return 'Dieses Feld ist erforderlich, wenn $fieldName $value ist.';
  }

  @override
  String get sumConditionError =>
      'Die Summe der Felder muss der Bedingung entsprechen.';
}

/// Arabic implementation of [ValidatorLocalizations].
class ArabicValidatorLocalizations extends ValidatorLocalizations {
  const ArabicValidatorLocalizations();

  @override
  Locale get locale => const Locale('ar');

  @override
  String get requiredFieldError => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmailError => 'يرجى إدخال عنوان بريد إلكتروني صحيح.';

  @override
  String minLengthError(int minLength) =>
      'يجب أن يكون على الأقل $minLength حرفاً.';

  @override
  String maxLengthError(int maxLength) =>
      'يجب أن يكون على الأكثر $maxLength حرفاً.';

  @override
  String get invalidNumberError => 'يرجى إدخال رقم صحيح.';

  @override
  String minValueError(num minValue) => 'يجب أن يكون على الأقل $minValue.';

  @override
  String maxValueError(num maxValue) => 'يجب أن يكون على الأكثر $maxValue.';

  @override
  String get invalidPatternError => 'يرجى إدخال تنسيق صحيح.';

  @override
  String get invalidUrlError => 'يرجى إدخال رابط صحيح.';

  @override
  String get invalidPhoneError => 'يرجى إدخال رقم هاتف صحيح.';

  @override
  String get invalidCreditCardError => 'يرجى إدخال رقم بطاقة ائتمان صحيح.';

  @override
  String get invalidDateError => 'يرجى إدخال تاريخ صحيح.';

  @override
  String get invalidIpError => 'يرجى إدخال عنوان IP صحيح.';

  @override
  String get invalidUuidError => 'يرجى إدخال UUID صحيح.';

  @override
  String get invalidJsonError => 'يرجى إدخال JSON صحيح.';

  @override
  String get invalidAlphanumericError => 'يُسمح بالأحرف والأرقام فقط.';

  @override
  String get invalidAlphabeticError => 'يُسمح بالأحرف فقط.';

  @override
  String get conditionalValidationError =>
      'هذا الحقل مطلوب بناءً على اختيارات أخرى.';

  @override
  String get fieldsMismatchError => 'الحقول غير متطابقة.';

  @override
  String get asyncValidationError => 'فشل في التحقق.';

  @override
  String get atLeastOneRequiredError =>
      'يجب أن يكون على الأقل في الحقل في هذه المجموعة.';

  @override
  String get dateAfterError => 'يجب أن يكون التاريخ بعد التاريخ المبدئي.';

  @override
  String get dateBeforeError => 'يجب أن يكون التاريخ قبل التاريخ النهائي.';

  @override
  String fieldsDifferentError(String fieldName) {
    return 'يجب أن يكون هذا الحقل مختلف عن $fieldName.';
  }

  @override
  String greaterThanFieldError(String fieldName) {
    return 'يجب أن يكون القيمة أكبر من $fieldName.';
  }

  @override
  String lessThanFieldError(String fieldName) {
    return 'يجب أن يكون القيمة أصغر من $fieldName.';
  }

  @override
  String get mustBeTrueError => 'يجب أن يكون هذا الحقل محدد.';

  @override
  String requiredWhenFieldNotEmptyError(String fieldName) {
    return 'يجب أن يكون هذا الحقل مطلوب عندما يكون $fieldName موجود.';
  }

  @override
  String requiredWhenFieldValueError(String fieldName, String value) {
    return 'يجب أن يكون هذا الحقل مطلوب عندما يكون $fieldName $value.';
  }

  @override
  String get sumConditionError => 'يجب أن يكون مجموع الحقول يطابق الشرط.';
}
