import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

// ignore: unintended_html_in_doc_comment
/// Complete registration form example using TypedFieldWrapper<T>
/// This demonstrates the clean, universal integration approach
class RegistrationFormScreen extends StatelessWidget {
  const RegistrationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypedFormProvider(
          fields: [
            FormFieldDefinition<String>(
              name: 'firstName',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(2),
                TypedCommonValidators.alphabetic(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'lastName',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(2),
                TypedCommonValidators.alphabetic(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'email',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.email(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'phone',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.phoneNumber(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'password',
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
            FormFieldDefinition<String>(
              name: 'confirmPassword',
              validators: [TypedCrossFieldValidators.matches('password')],
              initialValue: '',
            ),
            FormFieldDefinition<bool>(
              name: 'agreeToTerms',
              validators: [TypedCommonValidators.mustBeTrue()],
              initialValue: false,
            ),
          ],
          validationStrategy: ValidationStrategy.realTimeOnly,
          child: (context) => const RegistrationFormView(),
        ),
      ),
    );
  }
}

/// Registration Form View Widget
class RegistrationFormView extends StatelessWidget {
  const RegistrationFormView({super.key});

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
            'Create Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Using TypedFieldWrapper<T> for Universal Integration',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
          ),
          const SizedBox(height: 32),

          // First Name with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'firstName',
            transformValue: (value) => value.trim(),
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  prefixIcon: const Icon(Icons.person),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Alphabetic characters only',
                ),
                textCapitalization: TextCapitalization.words,
              );
            },
          ),
          const SizedBox(height: 16),

          // Last Name with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'lastName',
            transformValue: (value) => value.trim(),
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Alphabetic characters only',
                ),
                textCapitalization: TextCapitalization.words,
              );
            },
          ),
          const SizedBox(height: 16),

          // Email with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'email',
            transformValue: (value) => value.toLowerCase().trim(),
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(Icons.email),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'We\'ll never share your email',
                ),
                keyboardType: TextInputType.emailAddress,
              );
            },
          ),
          const SizedBox(height: 16),

          // Phone with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'phone',
            transformValue: (value) => value.replaceAll(RegExp(r'[^\d+]'), ''),
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Format: +1234567890',
                ),
                keyboardType: TextInputType.phone,
              );
            },
          ),
          const SizedBox(height: 16),

          // Password with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'password',
            builder: (context, value, error, hasError, isValidating, updateValue) {
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
          const SizedBox(height: 16),

          // Confirm Password with TypedFieldWrapper
          TypedFieldWrapper<String>(
            fieldName: 'confirmPassword',
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return TextFormField(
                initialValue: value,
                onChanged: updateValue,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  errorText: hasError ? error : null,
                  border: const OutlineInputBorder(),
                  helperText: 'Must match your password',
                ),
                obscureText: true,
              );
            },
          ),
          const SizedBox(height: 16),

          // Terms Agreement with TypedFieldWrapper
          TypedFieldWrapper<bool>(
            fieldName: 'agreeToTerms',
            builder: (context, value, error, hasError, isValidating, updateValue) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('I agree to the Terms and Conditions'),
                    subtitle: const Text('You must agree to continue'),
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

          const SizedBox(height: 32),

          // Submit Button with Form State
          TypedFormBuilder(
            builder: (context, state) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        state.validationStrategy ==
                            ValidationStrategy.onSubmitThenRealTime
                        ? () => context.validateForm(
                            onValidationPass: () => _submitForm(context, state),
                            onValidationFail: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all fields'),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                          )
                        : state.isValid
                        ? () => _submitForm(context, state)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form Status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.isValid
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      border: Border.all(
                        color: state.isValid ? Colors.green : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.isValid ? Icons.check_circle : Icons.info,
                          color: state.isValid ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.isValid
                                ? 'All fields are valid. Ready to create account!'
                                : 'Please complete all required fields',
                            style: TextStyle(
                              color: state.isValid
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TypedFieldWrapper Benefits
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TypedFieldWrapper<T> Benefits:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('✅ Universal - works with ANY Flutter widget'),
                          Text('✅ Type-safe - compile-time type checking'),
                          Text('✅ Performance optimized - minimal rebuilds'),
                          Text('✅ Value transformation - pre-process values'),
                          Text('✅ Error handling - consistent error display'),
                          Text('✅ Validation strategies - flexible timing'),
                          SizedBox(height: 12),
                          Text(
                            'Try different validation types above!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Debug Info
                  if (state.values.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Info:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Values: ${state.values}'),
                          if (state.errors.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Error Details: ${state.errors}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context, TypedFormState state) {
    // Type-safe access to form values
    final userData = {
      'firstName': state.getValue<String>('firstName'),
      'lastName': state.getValue<String>('lastName'),
      'email': state.getValue<String>('email'),
      'phone': state.getValue<String>('phone'),
      'password': state.getValue<String>('password'),
      'agreeToTerms': state.getValue<bool>('agreeToTerms'),
    };

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome ${userData['firstName']} ${userData['lastName']}!'),
            const SizedBox(height: 8),
            Text('Email: ${userData['email']}'),
            Text('Phone: ${userData['phone']}'),
            const SizedBox(height: 8),
            const Text('Your account has been successfully created.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Send data to your backend
    debugPrint('Registration data: $userData');
  }
}
