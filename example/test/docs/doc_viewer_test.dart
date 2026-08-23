// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typed_form_fields/typed_form_fields.dart';
import '../../lib/src/docs/doc_search_overlay.dart';
import '../../lib/src/docs/doc_sidebar.dart';
import '../../lib/src/docs/doc_viewer_widget.dart';
import '../../lib/src/docs/embedded_live_demo.dart';
import '../../lib/src/docs/table_of_contents_widget.dart';
import '../../lib/src/shell/app_routes.dart';

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
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
      Locale('es'),
      Locale('fr'),
      Locale('de'),
      Locale('ar'),
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1280,
      1024,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  group('DocGuideParser Unit Tests', () {
    test('splits markdown string on live-demo tags correctly', () {
      const input = '''
# Heading
Some text here.
<live-demo id="registration" />
Some text after.
''';

      final segments = DocGuideParser.parse(input);
      expect(segments.length, equals(3));
      expect(segments[0], isA<MarkdownTextSegment>());
      expect(
        (segments[0] as MarkdownTextSegment).content,
        contains('# Heading'),
      );
      expect(segments[1], isA<LiveDemoSegment>());
      expect((segments[1] as LiveDemoSegment).demoId, equals('registration'));
      expect(segments[2], isA<MarkdownTextSegment>());
      expect(
        (segments[2] as MarkdownTextSegment).content,
        contains('Some text after.'),
      );
    });
  });

  group('TocItem Unit Tests', () {
    test('extracts H2 and H3 headings from raw markdown', () {
      const markdown = '''
# Title
## H2 First Section
Some body text.
### H3 Subsection
More text.
## H2 Second Section
''';

      final items = TocItem.extractFromMarkdown(markdown);
      expect(items.length, equals(3));
      expect(items[0].title, equals('H2 First Section'));
      expect(items[0].level, equals(2));
      expect(items[0].anchorId, equals('h2-first-section'));

      expect(items[1].title, equals('H3 Subsection'));
      expect(items[1].level, equals(3));
      expect(items[1].anchorId, equals('h3-subsection'));

      expect(items[2].title, equals('H2 Second Section'));
      expect(items[2].level, equals(2));
      expect(items[2].anchorId, equals('h2-second-section'));
    });
  });

  group('EmbeddedLiveDemo Widget Tests', () {
    testWidgets('renders Registration demo correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const EmbeddedLiveDemo(demoId: 'registration')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('live_demo_registration')), findsOneWidget);
      expect(find.text('Interactive Demo: Registration Form'), findsOneWidget);
    });

    testWidgets('renders Multi-Step demo correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const EmbeddedLiveDemo(demoId: 'multi-step')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('live_demo_multi-step')), findsOneWidget);
      expect(
        find.text('Interactive Demo: Multi-Step Field Grouping'),
        findsOneWidget,
      );
    });

    testWidgets('renders Dynamic Form demo correctly', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(const EmbeddedLiveDemo(demoId: 'dynamic-form')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key('live_demo_dynamic-form')), findsOneWidget);
      expect(find.text('Interactive Demo: Dynamic Form Array'), findsOneWidget);
    });
  });

  group('TableOfContentsWidget Tests', () {
    testWidgets('renders TOC items and handles click callback', (tester) async {
      TocItem? selectedItem;
      final items = [
        const TocItem(title: 'Overview', anchorId: 'overview', level: 2),
        const TocItem(title: 'Details', anchorId: 'details', level: 3),
      ];

      await tester.pumpWidget(
        _wrapWithApp(
          TableOfContentsWidget(
            items: items,
            activeAnchorId: 'overview',
            onItemTap: (item) => selectedItem = item,
          ),
        ),
      );

      expect(find.text('On This Page'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.byKey(const Key('toc_item_details')));
      expect(selectedItem?.anchorId, equals('details'));
    });
  });

  group('DocSidebar Widget Tests', () {
    testWidgets('renders documentation sections and triggers navigation', (
      tester,
    ) async {
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapWithApp(
          DocSidebar(
            currentRoute: AppRoutes.docsGettingStarted,
            onSelectRoute: (route) => selectedRoute = route,
          ),
        ),
      );

      expect(find.text('Getting Started'), findsOneWidget);
      expect(find.text('Core Concepts'), findsOneWidget);
      expect(find.text('Validation Strategies'), findsOneWidget);

      await tester.tap(find.text('Core Concepts'));
      expect(selectedRoute, equals(AppRoutes.docsCoreConcepts));
    });
  });

  group('DocSearchOverlay Widget Tests', () {
    testWidgets('filters search manifest and handles selection', (
      tester,
    ) async {
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapWithApp(
          DocSearchOverlay(onSelectRoute: (route) => selectedRoute = route),
        ),
      );

      expect(find.byKey(const Key('doc_search_overlay')), findsOneWidget);
      expect(find.text('Getting Started'), findsOneWidget);

      // Enter search text
      await tester.enterText(
        find.byKey(const Key('doc_search_input')),
        'wizard',
      );
      await tester.pumpAndSettle();

      expect(find.text('Multi-Step Form Showcase'), findsOneWidget);

      await tester.tap(find.text('Multi-Step Form Showcase'));
      await tester.pumpAndSettle();

      expect(selectedRoute, equals(AppRoutes.multiStep));
    });
  });

  group('DocViewerWidget Asset Integration Tests', () {
    test(
      'loads all 6 English documentation markdown files from rootBundle',
      () async {
        final guideFiles = [
          'getting_started.md',
          'core_concepts.md',
          'validation_strategies.md',
          'async_validation.md',
          'field_grouping.md',
          'dynamic_form_management.md',
        ];

        for (final fileName in guideFiles) {
          final content = await rootBundle.loadString(
            'assets/docs/en/$fileName',
          );
          expect(content, isNotEmpty, reason: '$fileName should not be empty');
          expect(
            content,
            contains('<live-demo'),
            reason: '$fileName should contain live-demo tag',
          );
        }
      },
    );

    testWidgets('loads and renders all 6 documentation guide routes', (
      tester,
    ) async {
      final routes = [
        AppRoutes.docsGettingStarted,
        AppRoutes.docsCoreConcepts,
        AppRoutes.docsValidationStrategies,
        AppRoutes.docsAsyncValidation,
        AppRoutes.docsFieldGrouping,
        AppRoutes.docsDynamicFormManagement,
      ];

      for (final route in routes) {
        await tester.pumpWidget(
          _wrapWithApp(
            DocViewerWidget(
              docRoute: route,
              locale: const Locale('en'),
              onNavigate: (_) {},
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(DocViewerWidget), findsOneWidget);
        expect(find.textContaining('Failed to load document'), findsNothing);
      }
    });

    testWidgets(
      'handles locale fallback to English when localized asset missing',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithApp(
            DocViewerWidget(
              docRoute: AppRoutes.docsGettingStarted,
              locale: const Locale('de'),
              onNavigate: (_) {},
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(DocViewerWidget), findsOneWidget);
      },
    );
  });

  group('ShadcnCodeBlockBuilder Tests', () {
    testWidgets(
      'renders copy code button and copies code to clipboard on tap',
      (tester) async {
        const markdownData = '''
```dart
void main() {
  print("Hello World");
}
```
''';

        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) {
                return MarkdownBody(
                  data: markdownData,
                  builders: {'code': ShadcnCodeBlockBuilder(context)},
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final copyButton = find.byKey(const Key('copy_code_button')).first;
        expect(copyButton, findsOneWidget);

        await tester.tap(copyButton);
        await tester.pump();

        expect(find.text('Code copied to clipboard!'), findsOneWidget);
      },
    );
  });
}
