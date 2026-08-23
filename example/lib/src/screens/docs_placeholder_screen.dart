import 'package:flutter/material.dart';
import '../shell/app_routes.dart';

/// Placeholder screen for documentation routes until Doc Hub module is loaded.
class DocsPlaceholderScreen extends StatelessWidget {
  final String docRoute;

  const DocsPlaceholderScreen({
    super.key,
    required this.docRoute,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppRoutes.docRoutesMap[docRoute] ?? 'Documentation';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $docRoute',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Documentation Hub rendering Markdown guides will be active in subsequent Work Items.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
