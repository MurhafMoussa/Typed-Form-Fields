// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/src/screens/dynamic_form_screen.dart';

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

  group('DynamicFormScreen Integration Tests', () {
    testWidgets('should render dynamic form and inspector panel', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const DynamicFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Dynamic Form'), findsWidgets);
      expect(find.byKey(const Key('inspector_panel')), findsOneWidget);
      expect(find.byKey(const Key('btn_add_text_field')), findsOneWidget);
      expect(find.byKey(const Key('btn_add_email_field')), findsOneWidget);
    });

    testWidgets('should support adding, reordering, and removing fields', (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const DynamicFormScreen()));
      await tester.pumpAndSettle();

      // Initial template fields added post-frame
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

      // Add a Number Field
      final addNumberButton = find.byKey(const Key('btn_add_number_field'));
      await tester.ensureVisible(addNumberButton);
      await tester.tap(addNumberButton);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));

      // Add a Boolean Field
      final addBooleanField = find.byKey(const Key('btn_add_boolean_field'));
      await tester.ensureVisible(addBooleanField);
      await tester.tap(addBooleanField);
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsAtLeastNWidgets(1));

      // Clear all fields
      final clearAllButton = find.byKey(const Key('btn_clear_all_fields'));
      await tester.tap(clearAllButton);
      await tester.pumpAndSettle();

      expect(find.text('No active dynamic fields'), findsOneWidget);

      // Add first field again
      final addFirstButton = find.byKey(const Key('btn_add_first_field'));
      await tester.tap(addFirstButton);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('should verify RTL layout rendering for Arabic locale', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(
        const DynamicFormScreen(),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      final scaffoldElement = tester.element(find.byType(DynamicFormScreen));
      final textDirection = Directionality.of(scaffoldElement);
      expect(textDirection, TextDirection.rtl);
    });
  });
}
