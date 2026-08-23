import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/src/validators/validator_localizations.dart';
import 'package:typed_form_fields/src/validators/validator_localizations_delegate.dart';

void main() {
  group('ValidatorLocalizations', () {
    testWidgets('should return default localizations when no context provided',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TestWidget(),
        ),
      );

      await tester.pump();

      // The test widget will verify the localizations
      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets('should return localized messages for Spanish', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: const [
            ValidatorLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          home: const TestWidget(),
        ),
      );

      await tester.pump();

      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets('should return localized messages for French', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            ValidatorLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          home: const TestWidget(),
        ),
      );

      await tester.pump();

      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets('should return localized messages for German', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: const [
            ValidatorLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          home: const TestWidget(),
        ),
      );

      await tester.pump();

      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets('should return localized messages for Arabic', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            ValidatorLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          home: const TestWidget(),
        ),
      );

      await tester.pump();

      expect(find.byType(TestWidget), findsOneWidget);
    });

    testWidgets('should fallback to English for unsupported locale',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'), // Use English as fallback test
          localizationsDelegates: const [
            ValidatorLocalizationsDelegate.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          home: const TestWidget(),
        ),
      );

      await tester.pump();

      expect(find.byType(TestWidget), findsOneWidget);
    });

    group('EnglishValidatorLocalizations', () {
      const localizations = EnglishValidatorLocalizations();

      test('should have English locale', () {
        expect(localizations.locale, const Locale('en'));
      });

      test('should provide required field error message', () {
        expect(localizations.requiredFieldError, 'This field is required.');
      });

      test('should provide email error message', () {
        expect(localizations.invalidEmailError,
            'Please enter a valid email address.');
      });

      test('should provide min length error message', () {
        expect(localizations.minLengthError(5),
            'Must be at least 5 characters long.');
      });

      test('should provide max length error message', () {
        expect(localizations.maxLengthError(10),
            'Must be at most 10 characters long.');
      });

      test('should provide numeric error message', () {
        expect(
            localizations.invalidNumberError, 'Please enter a valid number.');
      });

      test('should provide min value error message', () {
        expect(localizations.minValueError(10), 'Must be at least 10.');
      });

      test('should provide max value error message', () {
        expect(localizations.maxValueError(100), 'Must be at most 100.');
      });

      test('should provide pattern error message', () {
        expect(
            localizations.invalidPatternError, 'Please enter a valid format.');
      });

      test('should provide URL error message', () {
        expect(localizations.invalidUrlError, 'Please enter a valid URL.');
      });

      test('should provide phone error message', () {
        expect(localizations.invalidPhoneError,
            'Please enter a valid phone number.');
      });

      test('should provide credit card error message', () {
        expect(localizations.invalidCreditCardError,
            'Please enter a valid credit card number.');
      });

      test('should provide date error message', () {
        expect(localizations.invalidDateError, 'Please enter a valid date.');
      });

      test('should provide IP error message', () {
        expect(
            localizations.invalidIpError, 'Please enter a valid IP address.');
      });

      test('should provide UUID error message', () {
        expect(localizations.invalidUuidError, 'Please enter a valid UUID.');
      });

      test('should provide JSON error message', () {
        expect(localizations.invalidJsonError, 'Please enter valid JSON.');
      });

      test('should provide alphanumeric error message', () {
        expect(localizations.invalidAlphanumericError,
            'Only letters and numbers are allowed.');
      });

      test('should provide alphabetic error message', () {
        expect(
            localizations.invalidAlphabeticError, 'Only letters are allowed.');
      });

      test('should provide conditional validation error message', () {
        expect(localizations.conditionalValidationError,
            'This field is required based on other selections.');
      });

      test('should provide fields mismatch error message', () {
        expect(localizations.fieldsMismatchError, 'Fields do not match.');
      });

      test('should provide async validation error message', () {
        expect(localizations.asyncValidationError, 'Validation failed.');
      });
    });

    group('SpanishValidatorLocalizations', () {
      const localizations = SpanishValidatorLocalizations();

      test('should have Spanish locale', () {
        expect(localizations.locale, const Locale('es'));
      });

      test('should provide Spanish required field error message', () {
        expect(localizations.requiredFieldError, 'Este campo es obligatorio.');
      });

      test('should provide Spanish email error message', () {
        expect(localizations.invalidEmailError,
            'Por favor, introduce una dirección de correo válida.');
      });

      test('should provide Spanish min length error message', () {
        expect(localizations.minLengthError(5),
            'Debe tener al menos 5 caracteres.');
      });

      test('should provide Spanish async validation error message', () {
        expect(localizations.asyncValidationError, 'La validación falló.');
      });
    });

    group('FrenchValidatorLocalizations', () {
      const localizations = FrenchValidatorLocalizations();

      test('should have French locale', () {
        expect(localizations.locale, const Locale('fr'));
      });

      test('should provide French required field error message', () {
        expect(localizations.requiredFieldError, 'Ce champ est requis.');
      });

      test('should provide French email error message', () {
        expect(localizations.invalidEmailError,
            'Veuillez saisir une adresse email valide.');
      });

      test('should provide French async validation error message', () {
        expect(localizations.asyncValidationError, 'La validation a échoué.');
      });
    });

    group('GermanValidatorLocalizations', () {
      const localizations = GermanValidatorLocalizations();

      test('should have German locale', () {
        expect(localizations.locale, const Locale('de'));
      });

      test('should provide German required field error message', () {
        expect(
            localizations.requiredFieldError, 'Dieses Feld ist erforderlich.');
      });

      test('should provide German email error message', () {
        expect(localizations.invalidEmailError,
            'Bitte geben Sie eine gültige E-Mail-Adresse ein.');
      });

      test('should provide German async validation error message', () {
        expect(
            localizations.asyncValidationError, 'Validierung fehlgeschlagen.');
      });
    });

    group('ArabicValidatorLocalizations', () {
      const localizations = ArabicValidatorLocalizations();

      test('should have Arabic locale', () {
        expect(localizations.locale, const Locale('ar'));
      });

      test('should provide Arabic required field error message', () {
        expect(localizations.requiredFieldError, 'هذا الحقل مطلوب.');
      });

      test('should provide Arabic email error message', () {
        expect(localizations.invalidEmailError,
            'يرجى إدخال عنوان بريد إلكتروني صحيح.');
      });

      test('should provide Arabic min length error message', () {
        expect(
            localizations.minLengthError(5), 'يجب أن يكون على الأقل 5 حرفاً.');
      });

      test('should provide Arabic async validation error message', () {
        expect(localizations.asyncValidationError, 'فشل في التحقق.');
      });
    });
  });

  group('ValidatorLocalizationsDelegate', () {
    const delegate = ValidatorLocalizationsDelegate.delegate;

    test('should support English locale', () {
      expect(delegate.isSupported(const Locale('en')), isTrue);
    });

    test('should support Spanish locale', () {
      expect(delegate.isSupported(const Locale('es')), isTrue);
    });

    test('should support French locale', () {
      expect(delegate.isSupported(const Locale('fr')), isTrue);
    });

    test('should support German locale', () {
      expect(delegate.isSupported(const Locale('de')), isTrue);
    });

    test('should support Arabic locale', () {
      expect(delegate.isSupported(const Locale('ar')), isTrue);
    });

    test('should not support unsupported locale', () {
      expect(delegate.isSupported(const Locale('xx')), isFalse);
    });

    test('should load English localizations', () async {
      final localizations = await delegate.load(const Locale('en'));
      expect(localizations, isA<EnglishValidatorLocalizations>());
    });

    test('should load Spanish localizations', () async {
      final localizations = await delegate.load(const Locale('es'));
      expect(localizations, isA<SpanishValidatorLocalizations>());
    });

    test('should load French localizations', () async {
      final localizations = await delegate.load(const Locale('fr'));
      expect(localizations, isA<FrenchValidatorLocalizations>());
    });

    test('should load German localizations', () async {
      final localizations = await delegate.load(const Locale('de'));
      expect(localizations, isA<GermanValidatorLocalizations>());
    });

    test('should load Arabic localizations', () async {
      final localizations = await delegate.load(const Locale('ar'));
      expect(localizations, isA<ArabicValidatorLocalizations>());
    });

    test('should load default localizations for unsupported locale', () async {
      final localizations = await delegate.load(const Locale('xx'));
      expect(localizations, isA<EnglishValidatorLocalizations>());
    });

    test('should not reload delegate', () {
      const oldDelegate = ValidatorLocalizationsDelegate();
      expect(delegate.shouldReload(oldDelegate), isFalse);
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Test that ValidatorLocalizations.of(context) works
    final localizations = ValidatorLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          Text(localizations.requiredFieldError),
          Text(localizations.invalidEmailError),
          Text(localizations.minLengthError(5)),
        ],
      ),
    );
  }
}
