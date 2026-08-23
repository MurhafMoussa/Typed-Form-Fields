import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// TypedFieldWrapper showcase demonstrating universal widget integration
/// and performance optimization features
class FieldWrapperScreen extends StatelessWidget {
  const FieldWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TypedFieldWrapper Showcase'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypedFormProvider(
          fields: [
            FormFieldDefinition<String>(
              name: 'textField',
              validators: [TypedCommonValidators.required<String>()],
              initialValue: '',
            ),
            FormFieldDefinition<bool>(
              name: 'checkbox',
              validators: [TypedCommonValidators.mustBeTrue()],
              initialValue: false,
            ),
            FormFieldDefinition<double>(
              name: 'slider',
              validators: [
                TypedCommonValidators.custom<double>((value, context) {
                  if (value == null) return null;
                  if (value < 0.0) return 'Value must be at least 0.0';
                  if (value > 100.0) return 'Value must be at most 100.0';
                  return null;
                }),
              ],
              initialValue: 50.0,
            ),
          ],
          validationStrategy: ValidationStrategy.allFieldsRealTime,
          child: (context) => const TypedFieldWrapperView(),
        ),
      ),
    );
  }
}

/// TypedFieldWrapper View Widget
class TypedFieldWrapperView extends StatelessWidget {
  const TypedFieldWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Validation Type Selector
          TypedFormBuilder(
            builder: (context, state) {
              return Row(
                children: [
                  const Text(
                    'Validation: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<ValidationStrategy>(
                    value: state.validationStrategy,
                    items: const [
                      DropdownMenuItem(
                        value: ValidationStrategy.onSubmitThenRealTime,
                        child: Text('On Submit'),
                      ),
                      DropdownMenuItem(
                        value: ValidationStrategy.allFieldsRealTime,
                        child: Text('All Fields'),
                      ),
                      DropdownMenuItem(
                        value: ValidationStrategy.realTimeOnly,
                        child: Text('Fields Being Edited'),
                      ),
                      DropdownMenuItem(
                        value: ValidationStrategy.disabled,
                        child: Text('Disabled'),
                      ),
                    ],
                    onChanged: (type) {
                      if (type != null) {
                        TypedFormProvider.of(
                          context,
                        ).setValidationStrategy(type);
                      }
                    },
                    underline: Container(),
                    style: const TextStyle(color: Colors.blue),
                    dropdownColor: Colors.white,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'TypedFieldWrapper<T> Universal Integration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Transform any Flutter widget into a validated form field',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Text Field Example
          const Text(
            'Text Field with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<String>(
            fieldName: 'textField',
            debounceTime: const Duration(milliseconds: 300),
            transformValue: (value) => value.trim(),
            onFieldStateChanged: (value, error, hasError) {
              debugPrint('Text field changed: $value, hasError: $hasError');
            },
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Enter some text',
                  hintText: 'This field is required',
                  prefixIcon: const Icon(Icons.text_fields),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Debounced validation (300ms)',
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Checkbox Example
          const Text(
            'Checkbox with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<bool>(
            fieldName: 'checkbox',
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('I agree to the terms'),
                    subtitle: const Text('This checkbox must be checked'),
                    value: value ?? false,
                    onChanged: updateValue,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Slider Example
          const Text(
            'Slider with TypedFieldWrapper',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TypedFieldWrapper<double>(
            fieldName: 'slider',
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Value: ${value?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: value ?? 50.0,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    onChanged: updateValue,
                    activeColor: hasError ? Colors.red : Colors.blue,
                  ),
                  if (hasError)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                ],
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

          // Performance Info
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TypedFieldWrapper<T> Benefits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('✅ Universal - works with ANY Flutter widget'),
                  Text('✅ Type-safe - compile-time type checking'),
                  Text('✅ Performance optimized - minimal rebuilds'),
                  Text('✅ Debouncing - configurable update delays'),
                  Text('✅ Value transformation - pre-process values'),
                  Text('✅ Error handling - consistent error display'),
                  Text('✅ Listener support - react to changes'),
                  SizedBox(height: 12),
                  Text(
                    'Performance Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• StreamBuilder with initialData for fast rendering'),
                  Text('• Field-specific state updates'),
                  Text('• Debounced validation to reduce API calls'),
                  Text('• Transform values before storing'),
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
                    ? () {
                        // Get form values with type safety
                        final textValue = context.getFormValue<String>(
                          'textField',
                        )!;
                        final checkboxValue = context.getFormValue<bool>(
                          'checkbox',
                        )!;
                        final sliderValue = context.getFormValue<double>(
                          'slider',
                        )!;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Form submitted!\n'
                              'Text: $textValue\n'
                              'Checkbox: $checkboxValue\n'
                              'Slider: $sliderValue',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  state.isValid
                      ? 'Submit Form'
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
}
