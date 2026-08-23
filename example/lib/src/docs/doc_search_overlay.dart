import 'package:flutter/material.dart';
import '../shell/app_routes.dart';

/// Pre-indexed search item entry in the Documentation & Showcase manifest.
class SearchManifestEntry {
  final String title;
  final String subtitle;
  final String route;
  final String category; // 'Documentation', 'Showcase'
  final List<String> keywords;

  const SearchManifestEntry({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.category,
    required this.keywords,
  });
}

/// Pre-indexed manifest of all documentation guides, sections, and showcase screens.
const List<SearchManifestEntry> searchManifestEntries = [
  // Showcase Screens
  SearchManifestEntry(
    title: 'Registration Showcase',
    subtitle: 'Cross-field password match, async username check, terms agreement',
    route: AppRoutes.registration,
    category: 'Showcase',
    keywords: ['registration', 'password', 'async', 'email', 'form'],
  ),
  SearchManifestEntry(
    title: 'Multi-Step Form Showcase',
    subtitle: 'Wizard navigation with fieldGroup partial validation',
    route: AppRoutes.multiStep,
    category: 'Showcase',
    keywords: ['multi-step', 'wizard', 'fieldGroup', 'grouping', 'steps'],
  ),
  SearchManifestEntry(
    title: 'Dynamic Form Showcase',
    subtitle: 'Add, remove, and reorder form array fields at runtime',
    route: AppRoutes.dynamicForm,
    category: 'Showcase',
    keywords: ['dynamic', 'array', 'add', 'remove', 'runtime'],
  ),

  // Documentation Guides
  SearchManifestEntry(
    title: 'Getting Started',
    subtitle: 'Installation, quick start example, and key features',
    route: AppRoutes.docsGettingStarted,
    category: 'Documentation',
    keywords: ['start', 'install', 'quickstart', 'setup', 'beginner'],
  ),
  SearchManifestEntry(
    title: 'Core Concepts',
    subtitle: 'TypedFormController, TypedFormFieldController, state reactivity',
    route: AppRoutes.docsCoreConcepts,
    category: 'Documentation',
    keywords: ['core', 'architecture', 'controller', 'state', 'reactivity'],
  ),
  SearchManifestEntry(
    title: 'Validation Strategies',
    subtitle: 'Real-time, OnSubmit, OnSubmitThenRealTime, and Disabled modes',
    route: AppRoutes.docsValidationStrategies,
    category: 'Documentation',
    keywords: ['strategies', 'realtime', 'submit', 'timing', 'validation'],
  ),
  SearchManifestEntry(
    title: 'Async Validation & Debouncing',
    subtitle: 'Remote API validation, debouncing, and loading indicators',
    route: AppRoutes.docsAsyncValidation,
    category: 'Documentation',
    keywords: ['async', 'debounce', 'remote', 'loading', 'api'],
  ),
  SearchManifestEntry(
    title: 'Field Grouping & Multi-Step',
    subtitle: 'Organizing fields into groups and partial group validation',
    route: AppRoutes.docsFieldGrouping,
    category: 'Documentation',
    keywords: ['grouping', 'fieldGroup', 'partial', 'wizard', 'step'],
  ),
  SearchManifestEntry(
    title: 'Custom Widgets & Dynamic Forms',
    subtitle: 'Using FieldWrapper and dynamic field array manipulation',
    route: AppRoutes.docsCustomWidgets,
    category: 'Documentation',
    keywords: ['custom', 'wrapper', 'FieldWrapper', 'dynamic', 'array'],
  ),
];

/// Client-side pre-indexed search overlay dialog.
class DocSearchOverlay extends StatefulWidget {
  final ValueChanged<String> onSelectRoute;

  const DocSearchOverlay({
    super.key,
    required this.onSelectRoute,
  });

  /// Displays the search overlay dialog.
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSelectRoute,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => DocSearchOverlay(onSelectRoute: onSelectRoute),
    );
  }

  @override
  State<DocSearchOverlay> createState() => _DocSearchOverlayState();
}

class _DocSearchOverlayState extends State<DocSearchOverlay> {
  final TextEditingController _queryController = TextEditingController();
  List<SearchManifestEntry> _filteredResults = searchManifestEntries;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onSearchChanged);
    _queryController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _queryController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResults = searchManifestEntries;
      } else {
        _filteredResults = searchManifestEntries.where((entry) {
          final matchesTitle = entry.title.toLowerCase().contains(query);
          final matchesSubtitle = entry.subtitle.toLowerCase().contains(query);
          final matchesCategory = entry.category.toLowerCase().contains(query);
          final matchesKeywords = entry.keywords
              .any((kw) => kw.toLowerCase().contains(query));

          return matchesTitle ||
              matchesSubtitle ||
              matchesCategory ||
              matchesKeywords;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      key: const Key('doc_search_overlay'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        height: 480,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Input Header
            TextField(
              key: const Key('doc_search_input'),
              controller: _queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search documentation & showcase screens...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _queryController.clear(),
                      )
                    : Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ESC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Search Results List
            Expanded(
              child: _filteredResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No matching entries found',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredResults.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final entry = _filteredResults[index];
                        final isDoc = entry.category == 'Documentation';

                        return ListTile(
                          key: Key('search_result_${entry.route.replaceAll('/', '_')}'),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          leading: Icon(
                            isDoc ? Icons.menu_book : Icons.widgets,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            entry.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onSelectRoute(entry.route);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
