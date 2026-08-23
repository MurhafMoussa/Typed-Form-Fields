import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Comprehensive showcase of TypedFieldWrapper integration
/// with various Flutter widgets and design systems
class WidgetShowcaseScreen extends StatelessWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Showcase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypedFormProvider(
          fields: [
            // Text Field
            FormFieldDefinition<String>(
              name: 'textField',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(3),
              ],
              initialValue: '',
            ),
            // Number Field
            FormFieldDefinition<double>(
              name: 'numberField',
              validators: [
                TypedCommonValidators.required<double>(),
                TypedCommonValidators.custom<double>((value, context) {
                  if (value == null) return null;
                  if (value < 0.0) return 'Value must be at least 0.0';
                  if (value > 100.0) return 'Value must be at most 100.0';
                  return null;
                }),
              ],
              initialValue: 0.0,
            ),
            // Email Field
            FormFieldDefinition<String>(
              name: 'emailField',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.email(),
              ],
              initialValue: '',
            ),
            // Password Field
            FormFieldDefinition<String>(
              name: 'passwordField',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(8),
                TypedCommonValidators.pattern(
                  RegExp(r'[A-Z]'),
                  errorText: 'Must contain uppercase letter',
                ),
                TypedCommonValidators.pattern(
                  RegExp(r'[a-z]'),
                  errorText: 'Must contain lowercase letter',
                ),
                TypedCommonValidators.pattern(
                  RegExp(r'[0-9]'),
                  errorText: 'Must contain digit',
                ),
              ],
              initialValue: '',
            ),
            // Phone Field
            FormFieldDefinition<String>(
              name: 'phoneField',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.phoneNumber(),
              ],
              initialValue: '',
            ),
            // Checkbox Field
            FormFieldDefinition<bool>(
              name: 'checkboxField',
              validators: [TypedCommonValidators.mustBeTrue()],
              initialValue: false,
            ),
            // Dropdown Field
            FormFieldDefinition<String>(
              name: 'dropdownField',
              validators: [TypedCommonValidators.required<String>()],
              initialValue: '',
            ),
          ],
          validationStrategy: ValidationStrategy.realTimeOnly,
          child: (context) => const WidgetShowcaseView(),
        ),
      ),
    );
  }
}

/// Widget Showcase View
class WidgetShowcaseView extends StatelessWidget {
  const WidgetShowcaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TypedFieldWrapper Showcase',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Universal widget integration with built-in validation and performance optimizations',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Text Field
          const Text(
            'Text Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'textField',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Text Input',
                  hintText: 'Enter some text',
                  prefixIcon: const Icon(Icons.text_fields),
                  helperText: 'Minimum 3 characters',
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Number Field with TypedFieldWrapper
          const Text(
            'Number Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<double>(
            fieldName: 'numberField',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value?.toString() ?? '0',
                onChanged: (text) {
                  final number = double.tryParse(text);
                  if (number != null) updateValue(number);
                },
                decoration: InputDecoration(
                  labelText: 'Number Input',
                  hintText: 'Enter a number',
                  prefixIcon: const Icon(Icons.numbers),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Range: 0-100',
                ),
                keyboardType: TextInputType.number,
              );
            },
          ),
          const SizedBox(height: 24),

          // Email Field with TypedFieldWrapper
          const Text(
            'Email Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'emailField',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Valid email format required',
                ),
                keyboardType: TextInputType.emailAddress,
              );
            },
          ),
          const SizedBox(height: 24),

          // Password Field with TypedFieldWrapper
          const Text(
            'Password Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'passwordField',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a strong password',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Min 8 chars, uppercase, lowercase, digit',
                ),
                obscureText: true,
              );
            },
          ),
          const SizedBox(height: 24),

          // Phone Field with TypedFieldWrapper
          const Text(
            'Phone Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'phoneField',
            builder: (context, value, error, hasError, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Valid phone format required',
                ),
                keyboardType: TextInputType.phone,
              );
            },
          ),
          const SizedBox(height: 24),

          // Checkbox with TypedFieldWrapper
          const Text(
            'Checkbox Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<bool>(
            fieldName: 'checkboxField',
            builder: (context, value, error, hasError, updateValue) {
              return CheckboxListTile(
                title: const Text('I agree to the terms'),
                subtitle: Text(
                  hasError ? (error ?? '') : 'This checkbox must be checked',
                  style: TextStyle(color: hasError ? Colors.red : null),
                ),
                value: value ?? false,
                onChanged: (val) => updateValue(val ?? false),
              );
            },
          ),
          const SizedBox(height: 24),

          // Dropdown with TypedFieldWrapper
          const Text(
            'Dropdown Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'dropdownField',
            builder: (context, value, error, hasError, updateValue) {
              return DropdownButtonFormField<String>(
                initialValue: (value == null || value.isEmpty) ? null : value,
                decoration: InputDecoration(
                  labelText: 'Select an option',
                  hintText: 'Choose from the list',
                  prefixIcon: const Icon(Icons.arrow_drop_down),
                  helperText: 'Please select an option',
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'option2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'option3', child: Text('Option 3')),
                ],
                onChanged: updateValue,
              );
            },
          ),

          const SizedBox(height: 32),

          // Form Status
          TypedFormBuilder(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.isValid
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  border: Border.all(
                    color: state.isValid ? Colors.green : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isValid ? Icons.check_circle : Icons.info,
                          color: state.isValid ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Form Status: ${state.isValid ? 'Valid' : 'Invalid'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: state.isValid
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Validation Type: ${state.validationStrategy.name}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (state.values.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Values: ${state.values}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    if (state.errors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Errors: ${state.errors}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Widget Benefits
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TypedFieldWrapper Benefits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('✅ UI-Agnostic - works with any widget or design system'),
                  Text('✅ Consistent validation - automatic error handling'),
                  Text('✅ Type-safe - compile-time type checking'),
                  Text('✅ Performance optimized - field-specific rebuilds'),
                  Text('✅ Zero UI coupling - lightweight & future-proof'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          TypedFormBuilder(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isValid
                    ? () => _showFormData(context, state)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  state.isValid
                      ? 'Show Form Data'
                      : 'Please fill all required fields',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFormData(BuildContext context, TypedFormState state) {
    final formData = state.values;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Data'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: formData.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    debugPrint('Widget showcase data: $formData');
  }
}
