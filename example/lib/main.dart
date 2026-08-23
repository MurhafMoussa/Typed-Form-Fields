import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import 'screens/bloc_form_screen.dart';
import 'screens/dynamic_form_screen.dart';
import 'screens/field_wrapper_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/multi_step_form_screen.dart';
import 'screens/registration_form_screen.dart';
import 'screens/validation_strategies_screen.dart';
import 'screens/widget_showcase_screen.dart';
import 'src/screens/docs_placeholder_screen.dart';
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
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _themeController = widget.themeController ?? ThemeController();
    _currentLocale = widget.initialLocale ?? const Locale('en');
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Typed Form Fields Showcase & Docs',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: _currentLocale,
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
          initialRoute: AppRoutes.initial,
          onGenerateRoute: (settings) {
            final name = settings.name ?? AppRoutes.initial;
            final normalizedRoute =
                (name == '/') ? AppRoutes.initial : name;

            Widget page;

            switch (normalizedRoute) {
              case AppRoutes.registration:
                page = const RegistrationFormScreen();
                break;
              case AppRoutes.widgetGallery:
              case '/widget-showcase':
                page = const WidgetShowcaseScreen();
                break;
              case AppRoutes.multiStep:
              case '/multi-step-form':
                page = const MultiStepFormScreen();
                break;
              case AppRoutes.dynamicForm:
                page = const DynamicFormScreen();
                break;
              case AppRoutes.docsGettingStarted:
              case AppRoutes.docsCoreConcepts:
              case AppRoutes.docsValidationStrategies:
              case AppRoutes.docsAsyncValidation:
              case AppRoutes.docsFieldGrouping:
              case AppRoutes.docsCustomWidgets:
                page = DocsPlaceholderScreen(docRoute: normalizedRoute);
                break;
              case '/login-form':
                page = const LoginFormScreen();
                break;
              case '/field-wrapper':
                page = const FieldWrapperScreen();
                break;
              case '/validation-strategies':
                page = const ValidationStrategiesScreen();
                break;
              case '/bloc-form':
                page = const BlocFormScreen();
                break;
              default:
                page = const RegistrationFormScreen();
            }

            return MaterialPageRoute(
              settings: settings,
              builder: (context) => AppShell(
                currentRoute: normalizedRoute,
                onNavigate: (route) {
                  if (ModalRoute.of(context)?.settings.name != route) {
                    Navigator.of(context).pushReplacementNamed(route);
                  }
                },
                themeController: _themeController,
                currentLocale: _currentLocale,
                onLocaleChanged: _changeLocale,
                child: page,
              ),
            );
          },
        );
      },
    );
  }
}
