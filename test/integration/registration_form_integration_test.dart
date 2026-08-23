// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/src/screens/registration_form_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child, {Locale locale = const Locale('en')}) {
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

  group('RegistrationFormScreen Integration Tests', () {
    testWidgets('should render registration form and inspector panel with strategy selector', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Registration Form'), findsWidgets);
      expect(find.byKey(const Key('inspector_panel')), findsOneWidget);
      expect(find.byKey(const Key('bloc_integration_toggle')), findsOneWidget);

      // Switch to Actions & Strategy tab in InspectorPanel
      await tester.tap(find.byKey(const Key('tab_diagnostics')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('strategy_dropdown')), findsOneWidget);
    });

    testWidgets('should render all registration fields and show errors on invalid input', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.byKey(const Key('input_email'));
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);

      // Enter mismatched confirm password
      final passwordField = find.byKey(const Key('input_password'));
      await tester.enterText(passwordField, 'Password123');
      await tester.pumpAndSettle();

      final confirmField = find.byKey(const Key('input_confirm_password'));
      await tester.enterText(confirmField, 'Password456');
      await tester.pumpAndSettle();

      expect(find.text('Fields do not match.'), findsOneWidget);
    });

    testWidgets('should complete full registration flow when valid inputs entered', (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      // Enter First Name
      await tester.enterText(find.byKey(const Key('input_first_name')), 'John');
      await tester.pumpAndSettle();

      // Enter Last Name
      await tester.enterText(find.byKey(const Key('input_last_name')), 'Doe');
      await tester.pumpAndSettle();

      // Enter Email
      await tester.enterText(find.byKey(const Key('input_email')), 'john.doe@example.com');
      await tester.pumpAndSettle();

      // Enter Phone
      await tester.enterText(find.byKey(const Key('input_phone')), '+12345678901');
      await tester.pumpAndSettle();

      // Enter Password
      await tester.enterText(find.byKey(const Key('input_password')), 'Password123');
      await tester.pumpAndSettle();

      // Enter Confirm Password
      await tester.enterText(find.byKey(const Key('input_confirm_password')), 'Password123');
      await tester.pumpAndSettle();

      // Toggle Terms Checkbox
      await tester.tap(find.byKey(const Key('checkbox_terms')));
      await tester.pumpAndSettle();

      // Submit Create Account Button
      final submitButton = find.byKey(const Key('submit_registration_button'));
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify AlertDialog success
      expect(find.text('Account Created!'), findsOneWidget);
      expect(find.text('Welcome John Doe!'), findsOneWidget);
    });

    testWidgets('should support BLoC integration mode toggle', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const RegistrationFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Active: TypedFormProvider Zero-Dependency Mode'), findsOneWidget);

      await tester.tap(find.byKey(const Key('bloc_integration_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Active: BlocProvider / BlocBuilder Integration'), findsOneWidget);
    });

    testWidgets('should verify RTL layout rendering for Arabic locale', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(
        const RegistrationFormScreen(),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      final scaffoldElement = tester.element(find.byType(RegistrationFormScreen));
      final textDirection = Directionality.of(scaffoldElement);
      expect(textDirection, TextDirection.rtl);
    });
  });
}
