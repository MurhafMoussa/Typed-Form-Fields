import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/dynamic_form_screen.dart';

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

  group('DynamicFormScreen Integration Tests', () {
    testWidgets('should render dynamic form and support adding/removing fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const DynamicFormScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Dynamic Form'), findsWidgets);

      // Verify initial fields exist
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));

      // Add a new Text Field
      final addTextButton = find.widgetWithText(ElevatedButton, 'Text Field');
      await tester.ensureVisible(addTextButton);
      await tester.tap(addTextButton);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));

      // Add an Email Field
      final addEmailButton = find.widgetWithText(ElevatedButton, 'Email Field');
      await tester.ensureVisible(addEmailButton);
      await tester.tap(addEmailButton);
      await tester.pumpAndSettle();

      // Tap remove icon on a field
      final deleteButtons = find.byIcon(Icons.delete);
      expect(deleteButtons, findsAtLeastNWidgets(1));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();
    });
  });
}
