import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <--- 1. Add this import
import 'package:typed_form_fields/typed_form_fields.dart';

import 'screens/dynamic_form_screen.dart';
import 'screens/field_wrapper_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/registration_form_screen.dart';
import 'screens/validation_strategies_screen.dart';
import 'screens/widget_showcase_screen.dart';

void main() {
  runApp(const TypedFormFieldsExampleApp());
}

class TypedFormFieldsExampleApp extends StatefulWidget {
  const TypedFormFieldsExampleApp({super.key});

  @override
  State<TypedFormFieldsExampleApp> createState() =>
      _TypedFormFieldsExampleAppState();
}

class _TypedFormFieldsExampleAppState extends State<TypedFormFieldsExampleApp> {
  Locale _currentLocale = const Locale('en');

  void _changeLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typed Form Fields Examples',
      locale: _currentLocale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Add localization delegates for validator error messages
      localizationsDelegates: [
        ValidatorLocalizationsDelegate.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // Supported locales for validation messages
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('de'), // German
        Locale('ar'), // Arabic
      ],
      home: ExampleHomeScreen(
        onLocaleChanged: _changeLocale,
        currentLocale: _currentLocale,
      ),
      routes: {
        '/registration': (context) => const RegistrationFormScreen(),
        '/login-form': (context) => const LoginFormScreen(),
        '/field-wrapper': (context) => const FieldWrapperScreen(),
        '/validation-strategies': (context) =>
            const ValidationStrategiesScreen(),
        '/dynamic-form': (context) => const DynamicFormScreen(),
        '/widget-showcase': (context) => const WidgetShowcaseScreen(),
      },
    );
  }
}

class ExampleHomeScreen extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  final Locale currentLocale;

  const ExampleHomeScreen({
    super.key,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typed Form Fields Examples'),
        centerTitle: true,
        actions: [
          _LanguageSwitcher(
            currentLocale: currentLocale,
            onLocaleChanged: onLocaleChanged,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 12),
                    Text(
                      'Production Ready Package',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✅ 564 comprehensive tests\n'
                      '✅ 100% coverage on core files\n'
                      '✅ Performance optimized with BlocConsumer\n'
                      '✅ TDD approach with extensive edge case testing',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Examples Section
            const Text(
              'Interactive Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildExampleCard(
                    context,
                    title: 'Registration Form',
                    description:
                        'Complete user registration with validation, password confirmation, and terms acceptance',
                    icon: Icons.person_add,
                    route: '/registration',
                    features: [
                      'Cross-field validation',
                      'Password confirmation',
                      'Terms acceptance',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleCard(
                    context,
                    title: 'Login Form Example',
                    description:
                        'Complete login form with TypedFormProvider and validation',
                    icon: Icons.login,
                    route: '/login-form',
                    features: [
                      'TypedFormProvider',
                      'Form validation',
                      'Async form submission',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleCard(
                    context,
                    title: 'FieldWrapper Showcase',
                    description:
                        'Universal widget integration with performance optimization',
                    icon: Icons.widgets,
                    route: '/field-wrapper',
                    features: [
                      'Universal integration',
                      'Performance optimized',
                      'Custom widgets',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleCard(
                    context,
                    title: 'Validation Strategies',
                    description:
                        'Interactive showcase of all 5 validation strategies',
                    icon: Icons.settings,
                    route: '/validation-strategies',
                    features: [
                      'All 5 strategies',
                      'Interactive examples',
                      'Real-time demos',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleCard(
                    context,
                    title: 'Dynamic Form',
                    description:
                        'Add and remove form fields dynamically with full validation',
                    icon: Icons.dynamic_form,
                    route: '/dynamic-form',
                    features: [
                      'Dynamic field addition',
                      'Field removal',
                      'Type-safe validation',
                      'Real-time updates',
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildExampleCard(
                    context,
                    title: 'Widget Showcase',
                    description:
                        'All 7 pre-built widgets with comprehensive examples',
                    icon: Icons.dashboard,
                    route: '/widget-showcase',
                    features: [
                      'All 7 widgets',
                      'Comprehensive examples',
                      'Interactive demos',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
    required List<String> features,
  }) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(33, 150, 243, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 32, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: features
                          .map(
                            (feature) => Chip(
                              label: Text(
                                feature,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Color.fromRGBO(
                                33,
                                150,
                                243,
                                0.1,
                              ),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) onLocaleChanged;

  const _LanguageSwitcher({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ar': 'العربية',
  };

  static const List<Locale> _supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ar'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language),
          const SizedBox(width: 4),
          Text(
            _languageNames[currentLocale.languageCode] ?? 'EN',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      tooltip: 'Change Language',
      onSelected: (Locale locale) {
        onLocaleChanged(locale);
      },
      itemBuilder: (BuildContext context) {
        return _supportedLocales.map((Locale locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 20, color: Colors.blue)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Text(
                  _languageNames[locale.languageCode] ?? locale.languageCode,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
