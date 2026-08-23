import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Supported locales and their human-readable display names.
const Map<String, String> supportedLocalesMap = {
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'ar': 'العربية',
};

/// Top App Bar component for the Example application shell.
class ExampleTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ThemeController themeController;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onGitHubPressed;

  const ExampleTopAppBar({
    super.key,
    required this.themeController,
    required this.currentLocale,
    required this.onLocaleChanged,
    this.onSearchPressed,
    this.onGitHubPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.check_box_outlined,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Typed Form Fields',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        // Search Button Placeholder
        IconButton(
          key: const Key('search_button'),
          icon: const Icon(Icons.search, size: 20),
          tooltip: 'Search documentation & forms (Ctrl+K)',
          onPressed: onSearchPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search index coming in Doc Hub module'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
        ),

        // Locale Switcher Dropdown
        PopupMenuButton<String>(
          key: const Key('locale_switcher_dropdown'),
          tooltip: 'Select Language',
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language, size: 20),
              const SizedBox(width: 4),
              Text(
                currentLocale.languageCode.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ),
          onSelected: (String langCode) {
            onLocaleChanged(Locale(langCode));
          },
          itemBuilder: (context) {
            return supportedLocalesMap.entries.map((entry) {
              final isSelected = entry.key == currentLocale.languageCode;
              return PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.primary,
                      )
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        ),

        // Theme Mode Toggle Button
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController,
          builder: (context, mode, _) {
            final icon = mode == ThemeMode.dark ||
                    (mode == ThemeMode.system && isDark)
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined;
            final tooltip = isDark
                ? 'Switch to Light Theme'
                : 'Switch to Dark Theme';

            return IconButton(
              key: const Key('theme_toggle_button'),
              icon: Icon(icon, size: 20),
              tooltip: tooltip,
              onPressed: () {
                final platformBrightness = MediaQuery.platformBrightnessOf(context);
                themeController.toggleTheme(platformBrightness);
              },
            );
          },
        ),

        // GitHub Repository Link
        IconButton(
          key: const Key('github_link'),
          icon: const Icon(Icons.code, size: 20),
          tooltip: 'GitHub Repository',
          onPressed: onGitHubPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GitHub: https://github.com/Murhaf/Typed-Form-Fields'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}
