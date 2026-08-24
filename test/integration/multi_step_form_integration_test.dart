// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/src/screens/multi_step_form_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child,
      {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
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
      home: child,
    );
  }

  group('MultiStepFormScreen Integration Tests', () {
    testWidgets('should render multi-step form wizard and inspector panel',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Multi-Step Form Wizard'), findsOneWidget);
      expect(find.byKey(const Key('inspector_panel')), findsOneWidget);
      expect(find.text('Step 1: Personal Information'), findsOneWidget);
    });

    testWidgets(
        'should prevent advancement when Step 1 fields are empty/invalid',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Step 1: Personal Information'), findsOneWidget);

      // Click Next Step without filling fields
      final nextButton = find.byKey(const Key('btn_step_next'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should remain on Step 1 and show error messages on required fields
      expect(find.text('Step 1: Personal Information'), findsOneWidget);
      expect(find.text('Please fix errors in Personal Info before proceeding.'),
          findsOneWidget);
      expect(find.text('This field is required.'), findsNWidgets(2));
    });

    testWidgets(
        'should validate Step 1, advance to Step 2, and handle Step 2 validation',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Fill Step 1 with valid inputs
      await tester.enterText(
          find.byKey(const Key('step_input_full_name')), 'Jane Doe');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('step_input_email')), 'jane.doe@example.com');
      await tester.pumpAndSettle();

      // Click Next Step
      final nextButton = find.byKey(const Key('btn_step_next'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should advance to Step 2: Address Details
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      // Try advancing from Step 2 without filling required address fields
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should stay on Step 2 and display validation errors
      expect(find.text('Step 2: Address Details'), findsOneWidget);
      expect(
          find.text('Please fix errors in Address Details before proceeding.'),
          findsOneWidget);
    });

    testWidgets(
        'should complete full multi-step registration flow successfully',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Step 1: Personal Info
      await tester.enterText(
          find.byKey(const Key('step_input_full_name')), 'Alice Smith');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('step_input_email')), 'alice.smith@example.com');
      await tester.pumpAndSettle();

      final nextButton = find.byKey(const Key('btn_step_next'));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Address Details
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('step_input_street')), '123 Tech Lane');
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('step_input_city')), 'San Francisco');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('step_input_zip')), '94105');
      await tester.pumpAndSettle();

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Confirmation
      expect(find.text('Step 3: Confirmation'), findsOneWidget);

      final submitButton = find.byKey(const Key('btn_step_submit'));

      // Tap Submit without accepting terms
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please accept terms and conditions to submit.'),
          findsOneWidget);

      // Check accept terms checkbox
      await tester.tap(find.byKey(const Key('step_input_accept_terms')));
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

    testWidgets(
        'should support navigating back to previous steps and retain values',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const MultiStepFormScreen()));
      await tester.pumpAndSettle();

      // Step 1
      await tester.enterText(
          find.byKey(const Key('step_input_full_name')), 'Bob Vance');
      await tester.enterText(find.byKey(const Key('step_input_email')),
          'bob@vancerefrigeration.com');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_step_next')));
      await tester.pumpAndSettle();

      // Step 2
      expect(find.text('Step 2: Address Details'), findsOneWidget);

      // Tap Back button
      final backButton = find.byKey(const Key('btn_step_back'));
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Step 1
      expect(find.text('Step 1: Personal Information'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Bob Vance'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'bob@vancerefrigeration.com'),
          findsOneWidget);
    });

    testWidgets('should verify RTL layout rendering for Arabic locale',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(
        const MultiStepFormScreen(),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      final scaffoldElement = tester.element(find.byType(MultiStepFormScreen));
      final textDirection = Directionality.of(scaffoldElement);
      expect(textDirection, TextDirection.rtl);
    });
  });
}
