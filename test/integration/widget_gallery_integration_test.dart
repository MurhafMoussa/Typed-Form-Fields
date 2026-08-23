// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/src/screens/widget_gallery_screen.dart';

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

  group('WidgetGalleryScreen Integration Tests', () {
    testWidgets('should render pre-built widgets showcase and inspector panel', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const WidgetGalleryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Widget Showcase'), findsOneWidget);
      expect(find.byKey(const Key('inspector_panel')), findsOneWidget);

      // Verify text inputs
      expect(find.byKey(const Key('gallery_input_text')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_email')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_password')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_number')), findsOneWidget);

      // Verify selection controls
      expect(find.byKey(const Key('gallery_input_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('radio_plan_standard')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_switch')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('gallery_input_slider')), findsOneWidget);
      expect(find.byKey(const Key('star_rating_1')), findsOneWidget);
    });

    testWidgets('should interact with input fields and update form state', (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const WidgetGalleryScreen()));
      await tester.pumpAndSettle();

      // Enter Text
      final textField = find.byKey(const Key('gallery_input_text'));
      await tester.enterText(textField, 'Sample Text');
      await tester.pumpAndSettle();

      // Enter Email
      final emailField = find.byKey(const Key('gallery_input_email'));
      await tester.enterText(emailField, 'gallery@example.com');
      await tester.pumpAndSettle();

      // Toggle Radio
      await tester.tap(find.byKey(const Key('radio_plan_pro')));
      await tester.pumpAndSettle();

      // Toggle Switch
      await tester.tap(find.byKey(const Key('gallery_input_switch')));
      await tester.pumpAndSettle();

      // Tap Checkbox
      await tester.tap(find.byKey(const Key('gallery_input_checkbox')));
      await tester.pumpAndSettle();

      // Tap Star Rating
      await tester.tap(find.byKey(const Key('star_rating_4')));
      await tester.pumpAndSettle();
    });

    testWidgets('should verify strategy switching in inspector panel', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const WidgetGalleryScreen()));
      await tester.pumpAndSettle();

      // Switch to Actions & Strategy tab in InspectorPanel
      await tester.tap(find.byKey(const Key('tab_diagnostics')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('strategy_dropdown')), findsOneWidget);
    });

    testWidgets('should verify RTL layout rendering for Arabic locale', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(
        const WidgetGalleryScreen(),
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      final scaffoldElement = tester.element(find.byType(WidgetGalleryScreen));
      final textDirection = Directionality.of(scaffoldElement);
      expect(textDirection, TextDirection.rtl);
    });
  });
}
