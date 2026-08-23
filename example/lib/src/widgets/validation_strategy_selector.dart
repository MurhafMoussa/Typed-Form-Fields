import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Interactive ValidationStrategy dropdown selector component for switching
/// active validation behavior in real-time.
class ValidationStrategySelector extends StatelessWidget {
  final ValidationStrategy currentStrategy;
  final ValueChanged<ValidationStrategy> onStrategyChanged;

  const ValidationStrategySelector({
    super.key,
    required this.currentStrategy,
    required this.onStrategyChanged,
  });

  static const Map<ValidationStrategy, String> _strategyLabels = {
    ValidationStrategy.realTimeOnly: 'Real Time Only',
    ValidationStrategy.onSubmitOnly: 'On Submit Only',
    ValidationStrategy.onSubmitThenRealTime: 'On Submit Then Real Time',
    ValidationStrategy.allFieldsRealTime: 'All Fields Real Time',
    ValidationStrategy.disabled: 'Disabled',
  };

  static const Map<ValidationStrategy, String> _strategyDescriptions = {
    ValidationStrategy.realTimeOnly:
        'Validates fields immediately as the user edits them.',
    ValidationStrategy.onSubmitOnly:
        'Suppresses errors until form submission occurs.',
    ValidationStrategy.onSubmitThenRealTime:
        'Validates on submit first, then continues with real-time updates.',
    ValidationStrategy.allFieldsRealTime:
        'Validates all fields on every edit regardless of touched state.',
    ValidationStrategy.disabled:
        'Disables all automatic form validation execution.',
  };

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
              Icons.tune,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Validation Strategy',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ValidationStrategy>(
          key: const Key('strategy_dropdown'),
          initialValue: currentStrategy,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: ValidationStrategy.values.map((strategy) {
            return DropdownMenuItem<ValidationStrategy>(
              value: strategy,
              child: Text(
                _strategyLabels[strategy] ?? strategy.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onStrategyChanged(newValue);
            }
          },
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _strategyDescriptions[currentStrategy] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
