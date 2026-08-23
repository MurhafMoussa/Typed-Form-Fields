import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/widget_showcase_screen.dart';

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

  group('WidgetShowcaseScreen Integration Tests', () {
    testWidgets('should render pre-built widgets showcase screen and interact with controls', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const WidgetShowcaseScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Widget Showcase'), findsOneWidget);

      // Verify Text Field
      final textField = find.byType(TextFormField).first;
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Sample Text');
      await tester.pumpAndSettle();

      // Verify Checkbox
      final checkbox = find.byType(CheckboxListTile).first;
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify Dropdown
      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      expect(dropdown, findsOneWidget);
    });
  });
}
