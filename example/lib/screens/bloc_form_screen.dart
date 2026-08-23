import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

// ignore: unintended_html_in_doc_comment
/// Form example with TypedFormProvider integration
/// This demonstrates reactive validation with clean architecture and zero dependencies
class BlocFormScreen extends StatelessWidget {
  const BlocFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
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
        FormFieldDefinition<bool>(
          name: 'rememberMe',
          validators: [TypedCommonValidators.mustBeTrue()],
          initialValue: false,
        ),
      ],
      validationStrategy: ValidationStrategy.realTimeOnly,
      child: (context) => const LoginFormView(),
    );
  }
}

/// Helper functions for form operations
class LoginFormHelper {
  /// Submit the form
  static Future<void> submitLogin(BuildContext context) async {
    context.validateForm(
      onValidationPass: () async {
        try {
          // Simulate API call
          await Future.delayed(const Duration(seconds: 2));

          // Check if context is still valid before using it
          if (!context.mounted) return;

          final email = context.getFormValue<String>('email')!;
          final password = context.getFormValue<String>('password')!;
          final rememberMe = context.getFormValue<bool>('rememberMe') ?? false;

          debugPrint('Login attempt: $email, remember: $rememberMe');

          // Simulate success/failure
          if (email == 'admin@example.com' && password == 'password123') {
            // Success - in real app, navigate to home
            debugPrint('Login successful!');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login successful!\nEmail: $email\nRemember me: $rememberMe',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Failure
            debugPrint('Login failed!');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid email or password'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Login error: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onValidationFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the errors before submitting'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  /// Clear the form
  static void clearForm(BuildContext context) {
    context.updateFormField<String>('email', '');
    context.updateFormField<String>('password', '');
    context.updateFormField<bool>('rememberMe', false);
  }
}

/// Form View Widget
class LoginFormView extends StatelessWidget {
  const LoginFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Form'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => LoginFormHelper.clearForm(context),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Status
              TypedFormBuilder(
                builder: (context, state) {
                  return Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Form Status: ${state.isValid ? 'Valid' : 'Invalid'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Header
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'TypedFormProvider with zero dependencies',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
              ),
              const SizedBox(height: 32),

              // Email Field with TypedFieldWrapper
              TypedFieldWrapper<String>(
                fieldName: 'email',
                debounceTime: const Duration(milliseconds: 500),
                transformValue: (value) => value.toLowerCase().trim(),
                onFieldStateChanged: (value, error, hasError) {
                  if (value?.isNotEmpty == true) {
                    debugPrint(
                      'User started typing email: ${value?.length} chars',
                    );
                  }
                },
                builder: (context, value, error, hasError, isValidating, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Try: admin@example.com',
                      prefixIcon: const Icon(Icons.email),
                      errorText: hasError ? error : null,
                      border: const OutlineInputBorder(),
                      helperText: 'Debounced validation (500ms)',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Password Field with TypedFieldWrapper
              TypedFieldWrapper<String>(
                fieldName: 'password',
                debounceTime: const Duration(milliseconds: 300),
                builder: (context, value, error, hasError, isValidating, updateValue) {
                  return TextFormField(
                    initialValue: value,
                    onChanged: updateValue,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Try: password123',
                      prefixIcon: const Icon(Icons.lock),
                      errorText: hasError ? error : null,
                      border: const OutlineInputBorder(),
                      helperText: 'Minimum 8 characters',
                    ),
                    obscureText: true,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Remember Me with TypedFieldWrapper
              TypedFieldWrapper<bool>(
                fieldName: 'rememberMe',
                builder: (context, value, error, hasError, isValidating, updateValue) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text('Remember me'),
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

              // Login Button with Form State
              TypedFormBuilder(
                builder: (context, state) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: state.isValid
                            ? () => LoginFormHelper.submitLogin(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Login',
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
                              color: state.isValid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.isValid
                                    ? 'All fields are valid. Ready to submit!'
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

                      // TypedFormProvider Architecture Info
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TypedFormProvider Benefits:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('✅ Zero dependencies (no flutter_bloc)'),
                              Text('✅ Clean, simple API'),
                              Text('✅ Automatic state management'),
                              Text('✅ Type-safe form access'),
                              Text('✅ Performance optimized'),
                              SizedBox(height: 12),
                              Text(
                                'Try the demo:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Email: admin@example.com'),
                              Text('Password: password123'),
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
        ),
      ),
    );
  }
}
