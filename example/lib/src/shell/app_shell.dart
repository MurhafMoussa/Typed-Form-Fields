import 'package:flutter/material.dart';
import '../docs/doc_search_overlay.dart';
import '../theme/theme_controller.dart';
import 'app_routes.dart';
import 'top_app_bar.dart';

/// Responsive Application Shell providing top app bar and adaptive navigation
/// (`NavigationRail`/`Drawer` on desktop/tablet, `NavigationBar` on mobile).
class AppShell extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final Widget child;
  final ThemeController themeController;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onGitHubPressed;

  const AppShell({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.child,
    required this.themeController,
    required this.currentLocale,
    required this.onLocaleChanged,
    this.onSearchPressed,
    this.onGitHubPressed,
  });

  /// Breakpoint threshold distinguishing desktop/tablet viewports from mobile.
  static const double desktopBreakpoint = 768.0;

  int get _selectedIndex {
    final normalized = currentRoute.startsWith('/docs')
        ? AppRoutes.docsGettingStarted
        : currentRoute;

    final index = primaryNavItems.indexWhere(
      (item) => item.route == normalized,
    );
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= desktopBreakpoint;
    final isRtl = currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: ExampleTopAppBar(
          themeController: themeController,
          currentLocale: currentLocale,
          onLocaleChanged: onLocaleChanged,
          onSearchPressed:
              onSearchPressed ??
              () => DocSearchOverlay.show(context, onSelectRoute: onNavigate),
          onGitHubPressed: onGitHubPressed,
        ),
        body: isDesktop ? _buildDesktopLayout(context) : child,
        bottomNavigationBar: isDesktop
            ? null
            : _buildMobileNavigationBar(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            final targetRoute = primaryNavItems[index].route;
            onNavigate(targetRoute);
          },
          labelType: NavigationRailLabelType.all,
          extended: false,
          leading: const SizedBox(height: 8),
          destinations: primaryNavItems.map((item) {
            return NavigationRailDestination(
              icon: Icon(item.icon, key: item.key),
              selectedIcon: Icon(item.selectedIcon, key: item.key),
              label: Text(item.label),
            );
          }).toList(),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.colorScheme.outline,
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildMobileNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        final targetRoute = primaryNavItems[index].route;
        onNavigate(targetRoute);
      },
      destinations: primaryNavItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon, key: item.key),
          selectedIcon: Icon(item.selectedIcon, key: item.key),
          label: item.label,
        );
      }).toList(),
    );
  }
}
