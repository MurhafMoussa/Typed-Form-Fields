import 'package:flutter/material.dart';

/// Reusable Card component styled with Shadcn UI aesthetics (1px subtle border,
/// crisp rounded corners, dark/light theme aware, optional header/actions).
class ShowcaseCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;

  const ShowcaseCard({
    super.key,
    this.title,
    this.description,
    this.headerLeading,
    this.headerTrailing,
    required this.child,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeader = title != null ||
        description != null ||
        headerLeading != null ||
        headerTrailing != null;

    return Card(
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  if (headerLeading != null) ...[
                    headerLeading!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (headerTrailing != null) ...[
                    const SizedBox(width: 8),
                    Flexible(child: headerTrailing!),
                  ],
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline,
            ),
          ],
          if (contentPadding != null)
            Padding(
              padding: contentPadding!,
              child: child,
            )
          else
            child,
        ],
      ),
    );
  }
}
