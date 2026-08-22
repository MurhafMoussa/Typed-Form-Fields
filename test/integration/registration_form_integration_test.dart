import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/registration_form_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        ValidatorLocalizationsDelegate.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    );
  }

  group('RegistrationFormScreen Integration Tests', () {
    testWidgets('should render all registration fields and show errors on invalid input', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Registration Form'), findsWidgets);

      // Enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);

      // Enter mismatched confirm password
      final passwordField = find.widgetWithText(TextFormField, 'Password').first;
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      final confirmField = find.widgetWithText(TextFormField, 'Confirm Password').first;
      await tester.enterText(confirmField, 'Password456');
      await tester.pumpAndSettle();

      expect(find.text('Fields do not match.'), findsOneWidget);
    });

    testWidgets('should complete full registration flow when valid inputs entered', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      // Enter First Name
      final firstNameField = find.widgetWithText(TextFormField, 'First Name').first;
      await tester.enterText(firstNameField, 'John');
      await tester.pumpAndSettle();

      // Enter Last Name
      final lastNameField = find.widgetWithText(TextFormField, 'Last Name').first;
      await tester.enterText(lastNameField, 'Doe');
      await tester.pumpAndSettle();

      // Enter Email
      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'john.doe@example.com');
      await tester.pumpAndSettle();

      // Enter Phone
      final phoneField = find.widgetWithText(TextFormField, 'Phone Number').first;
      await tester.enterText(phoneField, '+12345678901');
      await tester.pumpAndSettle();

      // Enter Password
      final passwordField = find.widgetWithText(TextFormField, 'Password').first;
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      // Enter Confirm Password
      final confirmField = find.widgetWithText(TextFormField, 'Confirm Password').first;
      await tester.enterText(confirmField, 'Password123');
      await tester.pumpAndSettle();

      // Toggle Terms Checkbox
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Submit Create Account Button
      final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account').first;
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Verify AlertDialog success
      expect(find.text('Account Created!'), findsOneWidget);
      expect(find.text('Welcome John Doe!'), findsOneWidget);
    });
  });
}
