import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../example/lib/screens/validation_strategies_screen.dart';

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

  group('ValidationStrategiesScreen Integration Tests', () {
    testWidgets('should render all 5 strategy options and allow opening interactive strategy demo', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableWidget(const ValidationStrategiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Validation Strategies'), findsWidgets);
      expect(find.text('onSubmitOnly'), findsOneWidget);
      expect(find.text('onSubmitThenRealTime'), findsOneWidget);
      expect(find.text('realTimeOnly'), findsOneWidget);
      expect(find.text('allFieldsRealTime'), findsOneWidget);
      expect(find.text('disabled'), findsOneWidget);

      // Tap on onSubmitOnly card to launch demo
      await tester.tap(find.text('onSubmitOnly'));
      await tester.pumpAndSettle();

      expect(find.byType(StrategyExampleScreen), findsOneWidget);
      expect(find.text('onSubmitOnly Example'), findsOneWidget);
    });
  });
}
