import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/login_form_screen.dart';

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

  group('LoginFormScreen Integration Tests', () {
    testWidgets('should render login fields and handle validation', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LoginFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Login Form'), findsOneWidget);

      // Enter invalid email and short password
      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'bad');
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final passwordField = find.widgetWithText(TextFormField, 'Password').first;
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      // With invalid values, state status shows "Please complete all required fields"
      expect(find.text('Please complete all required fields'), findsOneWidget);
    });

    testWidgets('should perform successful login and support clearing form', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const LoginFormScreen()));
      await tester.pumpAndSettle();

      // Enter correct credentials
      final emailField = find.widgetWithText(TextFormField, 'Email').first;
      await tester.enterText(emailField, 'admin@example.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final passwordField = find.widgetWithText(TextFormField, 'Password').first;
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      final rememberMe = find.byType(Checkbox).first;
      await tester.tap(rememberMe);
      await tester.pumpAndSettle();

      expect(find.text('All fields are valid. Ready to submit!'), findsOneWidget);

      // Tap Login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Login').first;
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.textContaining('Login successful!'), findsOneWidget);

      // Test clear form button
      final clearButton = find.byIcon(Icons.clear).first;
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('Please complete all required fields'), findsOneWidget);
    });
  });
}
