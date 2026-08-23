import 'package:flutter/material.dart';

/// Item representation in Table of Contents.
class TocItem {
  final String title;
  final String anchorId;
  final int level; // 2 for H2, 3 for H3

  const TocItem({
    required this.title,
    required this.anchorId,
    required this.level,
  });

  /// Extracts H2 and H3 headings from raw markdown string.
  static List<TocItem> extractFromMarkdown(String rawMarkdown) {
    final List<TocItem> items = [];
    final lines = rawMarkdown.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('## ')) {
        final title = trimmed.substring(3).trim();
        final anchorId = _slugify(title);
        items.add(TocItem(title: title, anchorId: anchorId, level: 2));
      } else if (trimmed.startsWith('### ')) {
        final title = trimmed.substring(4).trim();
        final anchorId = _slugify(title);
        items.add(TocItem(title: title, anchorId: anchorId, level: 3));
      }
    }

    return items;
  }

  static String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}

/// Table of Contents widget for right-hand document outline navigation.
class TableOfContentsWidget extends StatelessWidget {
  final List<TocItem> items;
  final String? activeAnchorId;
  final ValueChanged<TocItem> onItemTap;

  const TableOfContentsWidget({
    super.key,
    required this.items,
    this.activeAnchorId,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.list_alt,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'On This Page',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  final isActive = item.anchorId == activeAnchorId;
                  final indent = item.level == 3 ? 12.0 : 0.0;

                  return InkWell(
                    key: Key('toc_item_${item.anchorId}'),
                    onTap: () => onItemTap(item),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: indent + 6,
                        right: 6,
                        top: 6,
                        bottom: 6,
                      ),
                      child: Row(
                        children: [
                          if (isActive)
                            Container(
                              width: 3,
                              height: 14,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: item.level == 3 ? 12 : 13,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
