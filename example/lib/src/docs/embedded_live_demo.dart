import 'package:flutter/material.dart';
import '../screens/dynamic_form_screen.dart';
import '../screens/multi_step_form_screen.dart';
import '../screens/registration_form_screen.dart';
import '../screens/widget_gallery_screen.dart';

/// Embedded live interactive form component for documentation guides.
class EmbeddedLiveDemo extends StatelessWidget {
  final String demoId;

  const EmbeddedLiveDemo({
    super.key,
    required this.demoId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget demoContent;
    String title;

    switch (demoId) {
      case 'registration':
      case 'registration-form':
        demoContent = const RegistrationFormScreen(embedded: true);
        title = 'Interactive Demo: Registration Form';
        break;
      case 'widget-gallery':
      case 'widget-showcase':
        demoContent = const WidgetGalleryScreen(embedded: true);
        title = 'Interactive Demo: Typed Input Gallery';
        break;
      case 'multi-step':
      case 'multi-step-form':
        demoContent = const MultiStepFormScreen(embedded: true);
        title = 'Interactive Demo: Multi-Step Field Grouping';
        break;
      case 'dynamic-form':
      case 'dynamic-array':
        demoContent = const DynamicFormScreen(embedded: true);
        title = 'Interactive Demo: Dynamic Form Array';
        break;
      default:
        demoContent = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Demo identifier "$demoId" is not registered.'),
        );
        title = 'Interactive Demo: $demoId';
    }

    return Container(
      key: Key('live_demo_$demoId'),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE DEMO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Embedded Content Body
          SizedBox(
            height: 480,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
              child: SingleChildScrollView(
                child: demoContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
