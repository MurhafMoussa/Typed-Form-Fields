import 'package:flutter/material.dart';

/// Canonical route path constants for the example application.
abstract class AppRoutes {
  static const String registration = '/registration';
  static const String widgetGallery = '/widget-gallery';
  static const String multiStep = '/multi-step';
  static const String dynamicForm = '/dynamic-form';

  // Docs canonical routes
  static const String docsGettingStarted = '/docs/getting-started';
  static const String docsCoreConcepts = '/docs/core-concepts';
  static const String docsValidationStrategies = '/docs/validation-strategies';
  static const String docsAsyncValidation = '/docs/async-validation';
  static const String docsFieldGrouping = '/docs/field-grouping';
  static const String docsCustomWidgets = '/docs/custom-widgets';

  /// Default route when launching the application.
  static const String initial = registration;

  /// Map of canonical doc routes to display titles.
  static const Map<String, String> docRoutesMap = {
    docsGettingStarted: 'Getting Started',
    docsCoreConcepts: 'Core Concepts',
    docsValidationStrategies: 'Validation Strategies',
    docsAsyncValidation: 'Async Validation',
    docsFieldGrouping: 'Field Grouping',
    docsCustomWidgets: 'Custom Widgets',
  };
}

/// Navigation item definition for shell navigation.
class NavItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Key key;

  const NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.key,
  });
}

/// Primary showcase navigation items available in the shell.
const List<NavItem> primaryNavItems = [
  NavItem(
    route: AppRoutes.registration,
    label: 'Registration',
    icon: Icons.app_registration_outlined,
    selectedIcon: Icons.app_registration,
    key: Key('nav_registration'),
  ),
  NavItem(
    route: AppRoutes.widgetGallery,
    label: 'Widget Gallery',
    icon: Icons.widgets_outlined,
    selectedIcon: Icons.widgets,
    key: Key('nav_widget_gallery'),
  ),
  NavItem(
    route: AppRoutes.multiStep,
    label: 'Multi-Step',
    icon: Icons.linear_scale_outlined,
    selectedIcon: Icons.linear_scale,
    key: Key('nav_multi_step'),
  ),
  NavItem(
    route: AppRoutes.dynamicForm,
    label: 'Dynamic Form',
    icon: Icons.dynamic_form_outlined,
    selectedIcon: Icons.dynamic_form,
    key: Key('nav_dynamic_form'),
  ),
  NavItem(
    route: AppRoutes.docsGettingStarted,
    label: 'Docs',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    key: Key('nav_docs'),
  ),
];
