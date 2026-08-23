import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';
import 'event_log_widget.dart';

/// Action buttons for Form Diagnostics (Reset Form, Validate Form/Group, Mark All Touched).
class DiagnosticActions extends StatelessWidget {
  final TypedFormController controller;
  final String? groupName;
  final void Function(FormEventLogEntry entry)? onEventLogged;

  const DiagnosticActions({
    super.key,
    required this.controller,
    this.groupName,
    this.onEventLogged,
  });

  void _showFeedback(BuildContext context, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? theme.colorScheme.error
            : (theme.brightness == Brightness.dark
                ? Colors.green.shade800
                : Colors.green.shade700),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Diagnostic Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              key: const Key('validate_form_button'),
              onPressed: () async {
                onEventLogged?.call(
                  FormEventLogEntry(
                    title: 'Validate Form Triggered',
                    detail: 'Executing validateForm()',
                    category: FormEventCategory.userAction,
                  ),
                );
                await controller.validateForm(
                  context,
                  onValidationPass: () {
                    onEventLogged?.call(
                      FormEventLogEntry(
                        title: 'Form Validation Passed',
                        detail: 'All fields are valid.',
                        category: FormEventCategory.validation,
                      ),
                    );
                    _showFeedback(context, 'Form validation passed!');
                  },
                  onValidationFail: () {
                    final errorCount = controller.state.errors.length;
                    onEventLogged?.call(
                      FormEventLogEntry(
                        title: 'Form Validation Failed',
                        detail: 'Found $errorCount error(s): ${controller.state.errors}',
                        category: FormEventCategory.validation,
                        isError: true,
                      ),
                    );
                    _showFeedback(
                      context,
                      'Validation failed with $errorCount error(s).',
                      isError: true,
                    );
                  },
                );
              },
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Validate Form'),
            ),
            if (groupName != null)
              OutlinedButton.icon(
                key: const Key('validate_group_button'),
                onPressed: () {
                  onEventLogged?.call(
                    FormEventLogEntry(
                      title: 'Validate Group Triggered',
                      detail: 'Executing validateGroup("$groupName")',
                      category: FormEventCategory.userAction,
                    ),
                  );
                  controller.validateGroup(
                    groupName!,
                    context: context,
                    onValidationPass: () {
                      onEventLogged?.call(
                        FormEventLogEntry(
                          title: 'Group Validation Passed',
                          detail: 'Group "$groupName" is valid.',
                          category: FormEventCategory.validation,
                        ),
                      );
                      _showFeedback(context, 'Group "$groupName" validation passed!');
                    },
                    onValidationFail: () {
                      onEventLogged?.call(
                        FormEventLogEntry(
                          title: 'Group Validation Failed',
                          detail: 'Group "$groupName" contains errors.',
                          category: FormEventCategory.validation,
                          isError: true,
                        ),
                      );
                      _showFeedback(
                        context,
                        'Group "$groupName" validation failed.',
                        isError: true,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: Text('Validate Group ($groupName)'),
              ),
            OutlinedButton.icon(
              key: const Key('mark_all_touched_button'),
              onPressed: () {
                controller.touchAllFields(context);
                onEventLogged?.call(
                  FormEventLogEntry(
                    title: 'Mark All Touched Triggered',
                    detail: 'Executing touchAllFields()',
                    category: FormEventCategory.userAction,
                  ),
                );
                _showFeedback(context, 'All fields marked as touched.');
              },
              icon: const Icon(Icons.touch_app_outlined, size: 16),
              label: const Text('Mark All Touched'),
            ),
            OutlinedButton.icon(
              key: const Key('reset_form_button'),
              onPressed: () {
                controller.resetForm();
                onEventLogged?.call(
                  FormEventLogEntry(
                    title: 'Reset Form Triggered',
                    detail: 'Executing resetForm()',
                    category: FormEventCategory.userAction,
                  ),
                );
                _showFeedback(context, 'Form reset to initial state.');
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Form'),
            ),
          ],
        ),
      ],
    );
  }
}
