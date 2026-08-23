import 'package:flutter/material.dart';
import '../shell/app_routes.dart';

/// Documentation section item metadata.
class DocSectionItem {
  final String route;
  final String title;
  final IconData icon;

  const DocSectionItem({
    required this.route,
    required this.title,
    required this.icon,
  });
}

/// All official documentation guide sections.
const List<DocSectionItem> docGuideSections = [
  DocSectionItem(
    route: AppRoutes.docsGettingStarted,
    title: 'Getting Started',
    icon: Icons.play_circle_outline,
  ),
  DocSectionItem(
    route: AppRoutes.docsCoreConcepts,
    title: 'Core Concepts',
    icon: Icons.architecture,
  ),
  DocSectionItem(
    route: AppRoutes.docsValidationStrategies,
    title: 'Validation Strategies',
    icon: Icons.rule,
  ),
  DocSectionItem(
    route: AppRoutes.docsAsyncValidation,
    title: 'Async Validation',
    icon: Icons.sync_lock,
  ),
  DocSectionItem(
    route: AppRoutes.docsFieldGrouping,
    title: 'Field Grouping',
    icon: Icons.grid_view,
  ),
  DocSectionItem(
    route: AppRoutes.docsDynamicFormManagement,
    title: 'Dynamic Form Management',
    icon: Icons.dynamic_form_outlined,
  ),
];

/// Sticky left navigation sidebar for the Embedded Documentation Hub.
class DocSidebar extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onSelectRoute;

  const DocSidebar({
    super.key,
    required this.currentRoute,
    required this.onSelectRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Documentation',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: docGuideSections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final section = docGuideSections[index];
                final isSelected = currentRoute == section.route;

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    key: Key(
                      'doc_sidebar_${section.route.replaceAll('/', '_')}',
                    ),
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    leading: Icon(
                      section.icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    title: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onTap: () => onSelectRoute(section.route),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
