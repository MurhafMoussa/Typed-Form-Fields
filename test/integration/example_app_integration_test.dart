// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../example/lib/main.dart';
import '../../example/lib/src/screens/dynamic_form_screen.dart';
import '../../example/lib/src/screens/multi_step_form_screen.dart';
import '../../example/lib/src/screens/registration_form_screen.dart';
import '../../example/lib/src/shell/app_shell.dart';

void main() {
  group('Example App Integration Tests', () {
    testWidgets('should render AppShell and top app bar controls',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Typed Form Fields'), findsOneWidget);
      expect(find.byKey(const Key('theme_toggle_button')), findsOneWidget);
      expect(find.byKey(const Key('locale_switcher_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('search_button')), findsOneWidget);
      expect(find.byKey(const Key('github_link')), findsOneWidget);
    });

    testWidgets('should switch application locale via language picker dropdown',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      final languageDropdown =
          find.byKey(const Key('locale_switcher_dropdown'));
      expect(languageDropdown, findsOneWidget);
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español').last);
      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
    });

    testWidgets('should render RTL layout when Arabic locale selected',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      final languageDropdown =
          find.byKey(const Key('locale_switcher_dropdown'));
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('العربية').last);
      await tester.pumpAndSettle();

      expect(find.text('AR'), findsOneWidget);

      final scaffoldElement = tester.element(find.byType(Scaffold).first);
      final textDirection = Directionality.of(scaffoldElement);
      expect(textDirection, TextDirection.rtl);
    });

    testWidgets(
        'should navigate between showcase screens using shell navigation',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      // Initial route defaults to Registration
      expect(find.byType(RegistrationFormScreen), findsOneWidget);

      // Navigate to Multi-Step
      await tester.tap(find.byKey(const Key('nav_multi_step')).first);
      await tester.pumpAndSettle();
      expect(find.byType(MultiStepFormScreen), findsOneWidget);

      // Navigate to Dynamic Form
      await tester.tap(find.byKey(const Key('nav_dynamic_form')).first);
      await tester.pumpAndSettle();
      expect(find.byType(DynamicFormScreen), findsOneWidget);

      // Navigate to Docs
      await tester.tap(find.byKey(const Key('nav_docs')).first);
      await tester.pumpAndSettle();
      expect(find.text('Getting Started'), findsOneWidget);
    });
  });
}
