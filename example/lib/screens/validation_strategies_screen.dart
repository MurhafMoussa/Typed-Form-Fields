import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Comprehensive validation strategies showcase
/// Demonstrates all 5 validation strategies with interactive examples
class ValidationStrategiesScreen extends StatelessWidget {
  const ValidationStrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Strategies'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validation Strategies Showcase',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Explore all 5 validation strategies with interactive examples. Each strategy provides different validation timing and behavior.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Strategy Examples
            Expanded(
              child: ListView(
                children: [
                  _buildStrategyCard(
                    context,
                    title: 'onSubmitOnly',
                    description:
                        'Validation only occurs on form submission. No automatic switching to real-time validation.',
                    icon: Icons.send,
                    color: Colors.orange,
                    strategy: ValidationStrategy.onSubmitOnly,
                    features: [
                      'Submit-only validation',
                      'No real-time feedback',
                      'Consistent behavior',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStrategyCard(
                    context,
                    title: 'onSubmitThenRealTime',
                    description:
                        'Validation on submit, then automatically switches to real-time if validation fails.',
                    icon: Icons.swap_horiz,
                    color: Colors.purple,
                    strategy: ValidationStrategy.onSubmitThenRealTime,
                    features: [
                      'Smart switching',
                      'User-friendly',
                      'Progressive enhancement',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStrategyCard(
                    context,
                    title: 'realTimeOnly',
                    description:
                        'Real-time validation for fields being edited. Default strategy.',
                    icon: Icons.edit,
                    color: Colors.blue,
                    strategy: ValidationStrategy.realTimeOnly,
                    features: [
                      'Real-time feedback',
                      'Edit-time validation',
                      'Performance optimized',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStrategyCard(
                    context,
                    title: 'allFieldsRealTime',
                    description:
                        'Real-time validation for all fields, even when not being edited.',
                    icon: Icons.all_inclusive,
                    color: Colors.green,
                    strategy: ValidationStrategy.allFieldsRealTime,
                    features: [
                      'All fields validated',
                      'Immediate feedback',
                      'Comprehensive validation',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStrategyCard(
                    context,
                    title: 'disabled',
                    description:
                        'No validation occurs. Useful for forms that don\'t need validation.',
                    icon: Icons.block,
                    color: Colors.red,
                    strategy: ValidationStrategy.disabled,
                    features: [
                      'No validation',
                      'Form submission only',
                      'Performance focused',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the asset path for a validation strategy
  String _getStrategyAssetPath(ValidationStrategy strategy) {
    switch (strategy) {
      case ValidationStrategy.onSubmitOnly:
        return 'assets/onSubmitOnly.webp';
      case ValidationStrategy.onSubmitThenRealTime:
        return 'assets/onSubmitThenRealTime.webp';
      case ValidationStrategy.realTimeOnly:
        return 'assets/realTimeOnly.webp';
      case ValidationStrategy.allFieldsRealTime:
        return 'assets/allFieldsRealTime.webp';
      case ValidationStrategy.disabled:
        return 'assets/disabled.webp';
    }
  }

  Widget _buildStrategyCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ValidationStrategy strategy,
    required List<String> features,
  }) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToStrategyExample(context, strategy, title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  const SizedBox(height: 8),
                  // Visual asset for the strategy
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        _getStrategyAssetPath(strategy),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: features
                          .map(
                            (feature) => Chip(
                              label: Text(
                                feature,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: color.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStrategyExample(
    BuildContext context,
    ValidationStrategy strategy,
    String title,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StrategyExampleScreen(strategy: strategy, title: title),
      ),
    );
  }
}

/// Individual strategy example screen
class StrategyExampleScreen extends StatelessWidget {
  final ValidationStrategy strategy;
  final String title;

  const StrategyExampleScreen({
    super.key,
    required this.strategy,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypedFormProvider(
          fields: [
            FormFieldDefinition<String>(
              name: 'email',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.email(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'password',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(8),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'confirmPassword',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCrossFieldValidators.matches<String>('password'),
              ],
              initialValue: '',
            ),
          ],
          validationStrategy: strategy,
          child: (context) => BlocBuilder<TypedFormController, TypedFormState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Strategy Info
                  Card(
                    color: _getStrategyColor(strategy).withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStrategyIcon(strategy),
                                color: _getStrategyColor(strategy),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Current Strategy: $title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getStrategyColor(strategy),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStrategyDescription(strategy),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Fields
                  TypedFieldWrapper<String>(
                    fieldName: 'email',
                    builder: (context, field) {
                      return TextFormField(
                        initialValue: field.value,
                        onChanged: field.updateValue,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email),
                          errorText: field.displayError,
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TypedFieldWrapper<String>(
                    fieldName: 'password',
                    builder: (context, field) {
                      return TextFormField(
                        initialValue: field.value,
                        onChanged: field.updateValue,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          errorText: field.displayError,
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TypedFieldWrapper<String>(
                    fieldName: 'confirmPassword',
                    builder: (context, field) {
                      return TextFormField(
                        initialValue: field.value,
                        onChanged: field.updateValue,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText: field.displayError,
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: state.validationStrategy.isSubmissionSpecific
                        ? () => context.formCubit.validateForm(
                            context,
                            onValidationPass: () =>
                                _handleSubmit(context, state),
                            onValidationFail: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all fields'),
                                  ),
                                ),
                          )
                        : state.isValid
                        ? () => _handleSubmit(context, state)
                        : null,
                    child: const Text('Submit Form'),
                  ),
                  const SizedBox(height: 16),

                  // Form State Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Form State',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Valid: ${state.isValid}'),
                          Text('Strategy: ${state.validationStrategy}'),
                          Text('Errors: ${state.errors.length}'),
                          if (state.errors.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Error Details:'),
                            ...state.errors.entries.map(
                              (entry) => Text(
                                '${entry.key}: ${entry.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, TypedFormState state) async {
    // Show success dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Submitted!'),
        content: Text(
          'Form submitted successfully with ${state.validationStrategy} strategy.\n\n'
          'Email: ${state.getValue<String>('email')}\n'
          'Password: ${'*' * (state.getValue<String>('password')?.length ?? 0)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getStrategyColor(ValidationStrategy strategy) {
    switch (strategy) {
      case ValidationStrategy.onSubmitOnly:
        return Colors.orange;
      case ValidationStrategy.onSubmitThenRealTime:
        return Colors.purple;
      case ValidationStrategy.realTimeOnly:
        return Colors.blue;
      case ValidationStrategy.allFieldsRealTime:
        return Colors.green;
      case ValidationStrategy.disabled:
        return Colors.red;
    }
  }

  IconData _getStrategyIcon(ValidationStrategy strategy) {
    switch (strategy) {
      case ValidationStrategy.onSubmitOnly:
        return Icons.send;
      case ValidationStrategy.onSubmitThenRealTime:
        return Icons.swap_horiz;
      case ValidationStrategy.realTimeOnly:
        return Icons.edit;
      case ValidationStrategy.allFieldsRealTime:
        return Icons.all_inclusive;
      case ValidationStrategy.disabled:
        return Icons.block;
    }
  }

  String _getStrategyDescription(ValidationStrategy strategy) {
    switch (strategy) {
      case ValidationStrategy.onSubmitOnly:
        return 'Validation only occurs when you submit the form. No real-time feedback while typing.';
      case ValidationStrategy.onSubmitThenRealTime:
        return 'Validation occurs on submit, then automatically switches to real-time validation if errors are found.';
      case ValidationStrategy.realTimeOnly:
        return 'Real-time validation for fields you are currently editing. Provides immediate feedback.';
      case ValidationStrategy.allFieldsRealTime:
        return 'Real-time validation for all fields, even when not being edited. Most comprehensive validation.';
      case ValidationStrategy.disabled:
        return 'No validation occurs. Form submission happens without any validation checks.';
    }
  }
}
