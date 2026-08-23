import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/multi_step_form_screen.dart';

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

  group('MultiStepFormScreen Integration Tests', () {
    testWidgets('should prevent advancement when Step 1 fields are empty/invalid', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Step 1: Personal Information'), findsOneWidget);

      // Click Next Step without filling fields
      final nextButton = find.widgetWithText(ElevatedButton, 'Next Step').first;
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should remain on Step 1 and show error messages on required fields
      expect(find.text('Step 1: Personal Information'), findsOneWidget);
      expect(find.text('Please fix errors in Personal Info before proceeding.'), findsOneWidget);

      // Verify errors displayed on Step 1 inputs
      expect(find.text('This field is required.'), findsNWidgets(2));
    });

    testWidgets('should validate Step 1, advance to Step 2, and handle Step 2 validation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Fill Step 1 with valid inputs
      final nameField = find.widgetWithText(TextFormField, 'Full Name').first;
      await tester.enterText(nameField, 'Jane Doe');
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'jane.doe@example.com');
      await tester.pumpAndSettle();

      // Click Next Step
      final nextButton = find.widgetWithText(ElevatedButton, 'Next Step').first;
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should advance to Step 2: Address Details
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      // Try advancing from Step 2 without filling required address fields
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should stay on Step 2 and display validation errors for street, city, zipCode
      expect(find.text('Step 2: Address Details'), findsOneWidget);
      expect(find.text('Please fix errors in Address Details before proceeding.'), findsOneWidget);
    });

    testWidgets('should complete full multi-step registration flow successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Step 1: Personal Info
      final nameField = find.widgetWithText(TextFormField, 'Full Name').first;
      await tester.enterText(nameField, 'Alice Smith');
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'alice.smith@example.com');
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(ElevatedButton, 'Next Step').first;
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Address Details
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      final streetField = find.widgetWithText(TextFormField, 'Street Address').first;
      await tester.enterText(streetField, '123 Tech Lane');
      await tester.pumpAndSettle();

      final cityField = find.widgetWithText(TextFormField, 'City').first;
      await tester.enterText(cityField, 'San Francisco');
      await tester.pumpAndSettle();

      final zipField = find.widgetWithText(TextFormField, 'ZIP Code').first;
      await tester.enterText(zipField, '94105');
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Confirmation
      expect(find.text('Step 3: Confirmation'), findsOneWidget);

      final submitButton = find.widgetWithText(ElevatedButton, 'Submit Registration').first;

      // Tap Submit without accepting terms
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please accept terms and conditions to submit.'), findsOneWidget);

      // Check accept terms checkbox
      final termsCheckbox = find.byType(Checkbox).last;
      await tester.tap(termsCheckbox);
      await tester.pumpAndSettle();

      // Tap Submit Registration
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify success dialog
      expect(find.text('Registration Complete!'), findsOneWidget);
      expect(find.text('Full Name: Alice Smith'), findsOneWidget);
      expect(find.text('Email: alice.smith@example.com'), findsOneWidget);
      expect(find.text('Street: 123 Tech Lane'), findsOneWidget);
      expect(find.text('City: San Francisco'), findsOneWidget);
      expect(find.text('ZIP Code: 94105'), findsOneWidget);
    });

    testWidgets('should support navigating back to previous steps and retain values', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Step 1
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name').first, 'Bob Vance');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email').first, 'bob@vancerefrigeration.com');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Next Step').first);
      await tester.pumpAndSettle();

      // Step 2
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      // Tap Back button
      final backButton = find.widgetWithText(OutlinedButton, 'Back').first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Step 1
      expect(find.text('Step 1: Personal Information'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Bob Vance'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'bob@vancerefrigeration.com'), findsOneWidget);
    });
  });
}
