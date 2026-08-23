// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/src/screens/multi_step_form_screen.dart';
import '../lib/src/shell/app_routes.dart';
import '../lib/src/shell/app_shell.dart';
import '../lib/src/theme/app_theme.dart';
import '../lib/src/theme/shadcn_colors.dart';
import '../lib/src/theme/theme_controller.dart';

void main() {
  group('ThemeController', () {
    test('initializes with system mode by default', () {
      final controller = ThemeController();
      expect(controller.value, ThemeMode.system);
    });

    test('sets explicit theme mode', () {
      final controller = ThemeController();
      controller.setThemeMode(ThemeMode.dark);
      expect(controller.value, ThemeMode.dark);

      controller.setThemeMode(ThemeMode.light);
      expect(controller.value, ThemeMode.light);
    });

    test('toggles theme between light and dark', () {
      final controller = ThemeController(ThemeMode.light);
      controller.toggleTheme();
      expect(controller.value, ThemeMode.dark);

      controller.toggleTheme();
      expect(controller.value, ThemeMode.light);
    });

    test('toggles system mode based on platform brightness', () {
      final controller = ThemeController(ThemeMode.system);
      controller.toggleTheme(Brightness.light);
      expect(controller.value, ThemeMode.dark);

      final controller2 = ThemeController(ThemeMode.system);
      controller2.toggleTheme(Brightness.dark);
      expect(controller2.value, ThemeMode.light);
    });

    test('isDark resolves correctly based on platform brightness', () {
      final controller = ThemeController(ThemeMode.system);
      expect(controller.isDark(Brightness.dark), isTrue);
      expect(controller.isDark(Brightness.light), isFalse);

      controller.setThemeMode(ThemeMode.dark);
      expect(controller.isDark(Brightness.light), isTrue);

      controller.setThemeMode(ThemeMode.light);
      expect(controller.isDark(Brightness.dark), isFalse);
    });
  });

  group('AppTheme', () {
    test('lightTheme has M3 enabled, correct Shadcn colors and explicit primaryContainer tokens', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, ShadcnColors.lightBackground);
      expect(theme.cardTheme.color, ShadcnColors.lightCard);
      expect(theme.colorScheme.primaryContainer, ShadcnColors.slate100);
      expect(theme.colorScheme.onPrimaryContainer, ShadcnColors.slate900);
    });

    test('darkTheme has M3 enabled, correct Shadcn colors and explicit primaryContainer tokens', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, ShadcnColors.darkBackground);
      expect(theme.cardTheme.color, ShadcnColors.darkCard);
      expect(theme.colorScheme.primaryContainer, ShadcnColors.slate800);
      expect(theme.colorScheme.onPrimaryContainer, ShadcnColors.slate50);
    });
  });

  group('MultiStepFormScreen Theme Contrast', () {
    testWidgets('renders active step avatar badge text and step header card with high-contrast theme colors in light mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MultiStepFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Active step avatar badge text for Step 1 ('1')
      final avatarTextWidget = tester.widget<Text>(find.text('1'));
      expect(avatarTextWidget.style?.color, AppTheme.lightTheme.colorScheme.onPrimary);

      // Current step header card container fill
      final stepCardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Personal Info'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = stepCardContainer.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.lightTheme.colorScheme.primaryContainer);
    });

    testWidgets('renders active step avatar badge text and step header card with high-contrast theme colors in dark mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: MultiStepFormScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Active step avatar badge text for Step 1 ('1')
      final avatarTextWidget = tester.widget<Text>(find.text('1'));
      expect(avatarTextWidget.style?.color, AppTheme.darkTheme.colorScheme.onPrimary);

      // Current step header card container fill
      final stepCardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('Personal Info'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = stepCardContainer.decoration as BoxDecoration;
      expect(decoration.color, AppTheme.darkTheme.colorScheme.primaryContainer);
    });
  });

  group('AppShell Widget Tests', () {
    testWidgets('renders top bar buttons and mobile navigation bar on mobile viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final themeController = ThemeController(ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            currentRoute: AppRoutes.registration,
            onNavigate: (_) {},
            themeController: themeController,
            currentLocale: const Locale('en'),
            onLocaleChanged: (_) {},
            child: const Text('Mobile Body'),
          ),
        ),
      );

      expect(find.text('Mobile Body'), findsOneWidget);
      expect(find.byKey(const Key('theme_toggle_button')), findsOneWidget);
      expect(find.byKey(const Key('locale_switcher_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('search_button')), findsOneWidget);
      expect(find.byKey(const Key('github_link')), findsOneWidget);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders NavigationRail on desktop viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final themeController = ThemeController(ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            currentRoute: AppRoutes.registration,
            onNavigate: (_) {},
            themeController: themeController,
            currentLocale: const Locale('en'),
            onLocaleChanged: (_) {},
            child: const Text('Desktop Body'),
          ),
        ),
      );

      expect(find.text('Desktop Body'), findsOneWidget);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('supports RTL text direction for Arabic locale',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final themeController = ThemeController(ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            currentRoute: AppRoutes.registration,
            onNavigate: (_) {},
            themeController: themeController,
            currentLocale: const Locale('ar'),
            onLocaleChanged: (_) {},
            child: const Text('Arabic Shell Content'),
          ),
        ),
      );

      final scaffoldElement = tester.element(find.byType(Scaffold));
      final textDirection = Directionality.of(scaffoldElement);

      expect(textDirection, TextDirection.rtl);
    });
  });

  group('TypedFormFieldsExampleApp Integration Navigation', () {
    testWidgets('launches with AppShell and navigates between routes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const TypedFormFieldsExampleApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const Key('theme_toggle_button')), findsOneWidget);
      expect(find.byKey(const Key('nav_registration')), findsWidgets);

      // Toggling theme button switches theme mode
      await tester.tap(find.byKey(const Key('theme_toggle_button')));
      await tester.pumpAndSettle();

      // Tap on widget gallery navigation item
      await tester.tap(find.byKey(const Key('nav_widget_gallery')).first);
      await tester.pumpAndSettle();

      // Tap on docs navigation item
      await tester.tap(find.byKey(const Key('nav_docs')).first);
      await tester.pumpAndSettle();

      expect(find.text('Getting Started'), findsOneWidget);
    });
  });
}
