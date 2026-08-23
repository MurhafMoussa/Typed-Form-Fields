import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import 'src/docs/doc_viewer_widget.dart';
import 'src/screens/dynamic_form_screen.dart';
import 'src/screens/multi_step_form_screen.dart';
import 'src/screens/registration_form_screen.dart';
import 'src/shell/app_routes.dart';
import 'src/shell/app_shell.dart';
import 'src/theme/app_theme.dart';
import 'src/theme/theme_controller.dart';

void main() {
  runApp(const TypedFormFieldsExampleApp());
}

class TypedFormFieldsExampleApp extends StatefulWidget {
  final ThemeController? themeController;
  final Locale? initialLocale;

  const TypedFormFieldsExampleApp({
    super.key,
    this.themeController,
    this.initialLocale,
  });

  @override
  State<TypedFormFieldsExampleApp> createState() =>
      _TypedFormFieldsExampleAppState();
}

class _TypedFormFieldsExampleAppState
    extends State<TypedFormFieldsExampleApp> {
  late final ThemeController _themeController;
  late final ValueNotifier<Locale> _localeNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController();
    _localeNotifier = ValueNotifier<Locale>(
      widget.initialLocale ?? const Locale('en'),
    );

    _router = GoRouter(
      initialLocation: AppRoutes.initial,
      refreshListenable: _localeNotifier,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final path = state.uri.path;
            final normalizedRoute = path.isEmpty ? AppRoutes.initial : path;

            return ValueListenableBuilder<Locale>(
              valueListenable: _localeNotifier,
              builder: (context, currentLocale, _) {
                return AppShell(
                  currentRoute: normalizedRoute,
                  onNavigate: (route) => context.go(route),
                  themeController: _themeController,
                  currentLocale: currentLocale,
                  onLocaleChanged: _changeLocale,
                  child: child,
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: AppRoutes.registration,
              builder: (context, state) => const RegistrationFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.multiStep,
              builder: (context, state) => const MultiStepFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.dynamicForm,
              builder: (context, state) => const DynamicFormScreen(),
            ),
            GoRoute(
              path: '/docs/:docId',
              builder: (context, state) {
                final docId = state.pathParameters['docId'] ?? 'getting-started';
                final docRoute = '/docs/$docId';
                return ValueListenableBuilder<Locale>(
                  valueListenable: _localeNotifier,
                  builder: (context, currentLocale, _) {
                    return DocViewerWidget(
                      docRoute: docRoute,
                      locale: currentLocale,
                      onNavigate: (route) => context.go(route),
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/login-form',
              redirect: (context, state) => AppRoutes.registration,
            ),
            GoRoute(
              path: '/bloc-form',
              redirect: (context, state) => AppRoutes.registration,
            ),
            GoRoute(
              path: '/widget-showcase',
              redirect: (context, state) => AppRoutes.registration,
            ),
            GoRoute(
              path: '/field-wrapper',
              redirect: (context, state) => AppRoutes.registration,
            ),
            GoRoute(
              path: '/validation-strategies',
              redirect: (context, state) => AppRoutes.registration,
            ),
            GoRoute(
              path: '/multi-step-form',
              redirect: (context, state) => AppRoutes.multiStep,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    super.dispose();
  }

  void _changeLocale(Locale locale) {
    _localeNotifier.value = locale;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: _localeNotifier,
          builder: (context, currentLocale, _) {
            return MaterialApp.router(
              title: 'Typed Form Fields Showcase & Docs',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: currentLocale,
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
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
