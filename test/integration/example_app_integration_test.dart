import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../example/lib/main.dart';
import '../../example/lib/screens/dynamic_form_screen.dart';
import '../../example/lib/screens/field_wrapper_screen.dart';
import '../../example/lib/screens/login_form_screen.dart';
import '../../example/lib/screens/registration_form_screen.dart';
import '../../example/lib/screens/validation_strategies_screen.dart';
import '../../example/lib/screens/widget_showcase_screen.dart';

void main() {
  group('Example App Integration Tests', () {
    testWidgets('should render home screen and display example cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      expect(find.text('Typed Form Fields Examples'), findsWidgets);
      expect(find.text('Registration Form'), findsOneWidget);
      expect(find.text('Login Form Example'), findsOneWidget);
      expect(find.text('FieldWrapper Showcase'), findsOneWidget);
      expect(find.text('Validation Strategies'), findsOneWidget);
      expect(find.text('Dynamic Form'), findsOneWidget);
      expect(find.text('Widget Showcase'), findsOneWidget);
    });

    testWidgets('should switch application locale via language picker', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      final languageButton = find.byTooltip('Change Language');
      expect(languageButton, findsOneWidget);
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español').last);
      await tester.pumpAndSettle();

      expect(find.text('Español'), findsWidgets);
    });

    testWidgets('should navigate to all example screens and return home', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      // 1. Registration Form
      await tester.tap(find.text('Registration Form'));
      await tester.pumpAndSettle();
      expect(find.byType(RegistrationFormScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 2. Login Form Example
      await tester.tap(find.text('Login Form Example'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginFormScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 3. FieldWrapper Showcase
      await tester.tap(find.text('FieldWrapper Showcase'));
      await tester.pumpAndSettle();
      expect(find.byType(FieldWrapperScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 4. Validation Strategies
      await tester.tap(find.text('Validation Strategies'));
      await tester.pumpAndSettle();
      expect(find.byType(ValidationStrategiesScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 5. Dynamic Form
      await tester.tap(find.text('Dynamic Form'));
      await tester.pumpAndSettle();
      expect(find.byType(DynamicFormScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // 6. Widget Showcase
      await tester.tap(find.text('Widget Showcase'));
      await tester.pumpAndSettle();
      expect(find.byType(WidgetShowcaseScreen), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    });
  });
}
