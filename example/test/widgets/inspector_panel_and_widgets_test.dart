// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../../lib/src/widgets/diagnostic_actions.dart';
import '../../lib/src/widgets/event_log_widget.dart';
import '../../lib/src/widgets/inspector_panel.dart';
import '../../lib/src/widgets/json_viewer.dart';
import '../../lib/src/widgets/showcase_card.dart';
import '../../lib/src/widgets/validation_strategy_selector.dart';

void main() {
  group('ShowcaseCard Widget Tests', () {
    testWidgets(
      'renders title, description, header widgets, and child content',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShowcaseCard(
                title: 'Card Title',
                description: 'Card Subtitle Description',
                headerLeading: Icon(Icons.star, key: Key('card_leading')),
                headerTrailing: Text('Badge', key: Key('card_trailing')),
                child: Text('Card Content Body'),
              ),
            ),
          ),
        );

        expect(find.text('Card Title'), findsOneWidget);
        expect(find.text('Card Subtitle Description'), findsOneWidget);
        expect(find.byKey(const Key('card_leading')), findsOneWidget);
        expect(find.byKey(const Key('card_trailing')), findsOneWidget);
        expect(find.text('Card Content Body'), findsOneWidget);
      },
    );
  });

  group('EventLogWidget Tests', () {
    testWidgets('displays empty state message when no logs present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EventLogWidget(logs: const [], onClearLogs: () {}),
          ),
        ),
      );

      expect(find.text('No events recorded yet.'), findsOneWidget);
      expect(find.byKey(const Key('clear_event_log_button')), findsOneWidget);
    });

    testWidgets('renders log entries and handles clear button tap', (
      WidgetTester tester,
    ) async {
      bool cleared = false;
      final logs = [
        FormEventLogEntry(
          title: 'Field Changed',
          detail: 'username = john',
          category: FormEventCategory.stateChange,
        ),
        FormEventLogEntry(
          title: 'Validation Error',
          detail: 'Required field missing',
          category: FormEventCategory.validation,
          isError: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: EventLogWidget(
                logs: logs,
                onClearLogs: () => cleared = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Field Changed'), findsOneWidget);
      expect(find.text('username = john'), findsOneWidget);
      expect(find.text('Validation Error'), findsOneWidget);

      await tester.tap(find.byKey(const Key('clear_event_log_button')));
      await tester.pump();

      expect(cleared, isTrue);
    });
  });

  group('JsonViewer Tests', () {
    testWidgets('renders formatted JSON tree and supports copy button', (
      WidgetTester tester,
    ) async {
      final jsonMap = {
        'values': {'email': 'test@example.com'},
        'errors': <String, String>{},
        'isValid': true,
        'isDirty': false,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 300, child: JsonViewer(jsonMap: jsonMap)),
          ),
        ),
      );

      expect(find.byKey(const Key('json_viewer')), findsOneWidget);
      expect(find.textContaining('test@example.com'), findsOneWidget);
      expect(find.byKey(const Key('copy_json_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('copy_json_button')));
      await tester.pumpAndSettle();

      expect(find.text('Copied'), findsOneWidget);
    });
  });

  group('ValidationStrategySelector Tests', () {
    testWidgets('renders strategy dropdown and notifies strategy selection', (
      WidgetTester tester,
    ) async {
      ValidationStrategy? selectedStrategy;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationStrategySelector(
              currentStrategy: ValidationStrategy.realTimeOnly,
              onStrategyChanged: (s) => selectedStrategy = s,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('strategy_dropdown')), findsOneWidget);
      expect(find.text('Real Time Only'), findsOneWidget);

      await tester.tap(find.byKey(const Key('strategy_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('On Submit Only').last);
      await tester.pumpAndSettle();

      expect(selectedStrategy, equals(ValidationStrategy.onSubmitOnly));
    });
  });

  group('DiagnosticActions Tests', () {
    testWidgets('triggers controller methods on action button taps', (
      WidgetTester tester,
    ) async {
      FormEventLogEntry? lastLoggedEntry;
      final fields = [
        FormFieldDefinition<String>(
          name: 'username',
          initialValue: 'alice',
          validators: [TypedCommonValidators.required<String>()],
        ),
      ];
      final controller = TypedFormController(fields: fields);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DiagnosticActions(
                controller: controller,
                groupName: 'step1',
                onEventLogged: (entry) => lastLoggedEntry = entry,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('validate_form_button')), findsOneWidget);
      expect(find.byKey(const Key('validate_group_button')), findsOneWidget);
      expect(find.byKey(const Key('mark_all_touched_button')), findsOneWidget);
      expect(find.byKey(const Key('reset_form_button')), findsOneWidget);

      // Tap Mark All Touched
      await tester.tap(find.byKey(const Key('mark_all_touched_button')));
      await tester.pumpAndSettle();
      expect(controller.isTouched('username'), isTrue);
      expect(lastLoggedEntry?.title, equals('Mark All Touched Triggered'));

      // Tap Reset Form
      await tester.tap(find.byKey(const Key('reset_form_button')));
      await tester.pumpAndSettle();
      expect(controller.isTouched('username'), isFalse);
      expect(lastLoggedEntry?.title, equals('Reset Form Triggered'));

      // Tap Validate Form
      await tester.tap(find.byKey(const Key('validate_form_button')));
      await tester.pumpAndSettle();
      expect(lastLoggedEntry?.title, equals('Form Validation Passed'));
    });
  });

  group('InspectorPanel Integration Tests', () {
    testWidgets(
      'renders desktop side-by-side layout with child form and inspector',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final fields = <FormFieldDefinition>[
          FormFieldDefinition<String>(
            name: 'email',
            initialValue: 'user@domain.com',
            validators: const [],
          ),
        ];
        final controller = TypedFormController(fields: fields);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InspectorPanel(
                controller: controller,
                child: const Text('Live Form Preview'),
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('inspector_panel')), findsOneWidget);
        expect(find.text('Live Form Preview'), findsOneWidget);
        expect(find.text('Live State Inspector'), findsOneWidget);
        expect(find.byKey(const Key('tab_json_state')), findsOneWidget);
        expect(find.byKey(const Key('tab_event_log')), findsOneWidget);
        expect(find.byKey(const Key('tab_diagnostics')), findsOneWidget);
      },
    );

    testWidgets('renders mobile tabbed view layout on small viewports', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fields = <FormFieldDefinition>[
        FormFieldDefinition<String>(
          name: 'email',
          initialValue: 'mobile@domain.com',
          validators: const [],
        ),
      ];
      final controller = TypedFormController(fields: fields);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPanel(
              controller: controller,
              child: const Text('Mobile Live Form Preview'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('inspector_panel')), findsOneWidget);
      expect(find.byKey(const Key('tab_preview')), findsOneWidget);
      expect(find.byKey(const Key('tab_json_state')), findsOneWidget);
      expect(find.byKey(const Key('tab_event_log')), findsOneWidget);
      expect(find.byKey(const Key('tab_diagnostics')), findsOneWidget);
    });
  });
}
