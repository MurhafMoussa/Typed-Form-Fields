import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../widgets/inspector_panel.dart';
import '../widgets/showcase_card.dart';

/// Simulated async validator for username availability check.
class SimulatedAvailabilityValidator extends AsyncValidator<String> {
  final String fieldLabel;

  const SimulatedAvailabilityValidator(this.fieldLabel);

  @override
  Future<String?> validate(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return Future.value(null);
    }
    return Future.delayed(
      const Duration(milliseconds: 500),
      () {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'admin' ||
            normalized == 'taken' ||
            normalized == 'admin@example.com' ||
            normalized == 'taken@example.com') {
          return '$fieldLabel "$value" is already taken';
        }
        return null;
      },
    );
  }
}

/// Consolidated Registration Form Screen with dual-pane state inspector,
/// cross-field password matching, simulated async availability check,
/// loading indicators, and BLoC mode toggle.
class RegistrationFormScreen extends StatefulWidget {
  final bool embedded;

  const RegistrationFormScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  late final TypedFormController _controller;
  bool _useBlocProvider = false;

  @override
  void initState() {
    super.initState();
    _controller = TypedFormController(
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
          name: 'username',
          validators: const [],
          asyncValidators: const [
            SimulatedAvailabilityValidator('Username'),
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
          validators: [
            TypedCommonValidators.mustBeTrue(
              errorText: 'You must agree to the terms to proceed',
            ),
          ],
          initialValue: false,
        ),
      ],
      validationStrategy: ValidationStrategy.realTimeOnly,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    _controller.validateForm(
      context,
      onValidationPass: () {
        final state = _controller.state;
        final firstName = state.getValue<String>('firstName') ?? '';
        final lastName = state.getValue<String>('lastName') ?? '';

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Account Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome $firstName $lastName!'),
                const SizedBox(height: 8),
                Text('Email: ${state.getValue<String>('email')}'),
                Text('Phone: ${state.getValue<String>('phone')}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      onValidationFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix errors in the form before submitting.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShowcaseCard(
            title: 'Registration Form',
            description:
                'Cross-field matching, debounced async availability check, and BLoC state integration.',
            headerTrailing: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('BLoC Mode', style: TextStyle(fontSize: 12)),
                  Switch(
                    key: const Key('bloc_integration_toggle'),
                    value: _useBlocProvider,
                    onChanged: (val) {
                      setState(() {
                        _useBlocProvider = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _useBlocProvider ? Icons.account_tree : Icons.widgets,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _useBlocProvider
                              ? 'Active: BlocProvider / BlocBuilder Integration'
                              : 'Active: TypedFormProvider Zero-Dependency Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // First Name
                TypedFieldWrapper<String>(
                  fieldName: 'firstName',
                  transformValue: (val) => val.trim(),
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_first_name'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        prefixIcon: const Icon(Icons.person),
                        errorText: field.displayError,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TypedFieldWrapper<String>(
                  fieldName: 'lastName',
                  transformValue: (val) => val.trim(),
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_last_name'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: field.displayError,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Username with Async Validator
                TypedFieldWrapper<String>(
                  fieldName: 'username',
                  debounceTime: const Duration(milliseconds: 300),
                  transformValue: (val) => val.trim(),
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_username'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Username (Optional)',
                        hintText: 'Try "admin" or "taken"',
                        prefixIcon: const Icon(Icons.account_circle),
                        errorText: field.displayError,
                        helperText: 'Async availability check on input',
                        suffixIcon: field.isValidating
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    key: Key('username_loading'),
                                  ),
                                ),
                              )
                            : (field.value != null &&
                                    field.value!.isNotEmpty &&
                                    !field.hasError)
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TypedFieldWrapper<String>(
                  fieldName: 'email',
                  transformValue: (val) => val.trim().toLowerCase(),
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_email'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email),
                        errorText: field.displayError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TypedFieldWrapper<String>(
                  fieldName: 'phone',
                  transformValue: (val) => val.replaceAll(RegExp(r'[^\d+]'), ''),
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_phone'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+12345678901',
                        prefixIcon: const Icon(Icons.phone),
                        errorText: field.displayError,
                      ),
                      keyboardType: TextInputType.phone,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TypedFieldWrapper<String>(
                  fieldName: 'password',
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_password'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Min 8 chars, uppercase, lowercase, digit',
                        prefixIcon: const Icon(Icons.lock),
                        errorText: field.displayError,
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TypedFieldWrapper<String>(
                  fieldName: 'confirmPassword',
                  builder: (context, field) {
                    return TextFormField(
                      key: const Key('input_confirm_password'),
                      initialValue: field.value,
                      onChanged: field.updateValue,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        errorText: field.displayError,
                      ),
                      obscureText: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Terms Agreement Checkbox
                TypedFieldWrapper<bool>(
                  fieldName: 'agreeToTerms',
                  builder: (context, field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          key: const Key('checkbox_terms'),
                          title: const Text('I agree to the Terms and Conditions'),
                          value: field.value ?? false,
                          onChanged: field.updateValue,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 2),
                            child: Text(
                              field.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                BlocBuilder<TypedFormController, TypedFormState>(
                  bloc: _controller,
                  builder: (context, state) {
                    return ElevatedButton.icon(
                      key: const Key('submit_registration_button'),
                      onPressed: state.isValidating ? null : () => _submitForm(context),
                      icon: state.isValidating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add),
                      label: Text(
                        state.isValidating
                            ? 'Checking Availability...'
                            : 'Create Account',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider<TypedFormController>.value(
      value: _controller,
      child: Builder(
        builder: (ctx) => InspectorPanel(
          controller: _controller,
          child: _buildFormContent(ctx),
        ),
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(body: body);
  }
}
