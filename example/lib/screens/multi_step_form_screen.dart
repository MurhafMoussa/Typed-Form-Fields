import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Interactive Multi-Step Form Screen showcasing field grouping and step validation.
class MultiStepFormScreen extends StatelessWidget {
  const MultiStepFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Step Form Wizard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypedFormProvider(
          fields: [
            // Step 1: Personal Info
            FormFieldDefinition<String>(
              name: 'fullName',
              group: 'personal_info',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(2),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'email',
              group: 'personal_info',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.email(),
              ],
              initialValue: '',
            ),
            // Step 2: Address Info
            FormFieldDefinition<String>(
              name: 'street',
              group: 'address_info',
              validators: [
                TypedCommonValidators.required<String>(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'city',
              group: 'address_info',
              validators: [
                TypedCommonValidators.required<String>(),
              ],
              initialValue: '',
            ),
            FormFieldDefinition<String>(
              name: 'zipCode',
              group: 'address_info',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.pattern(
                  RegExp(r'^\d{5}$'),
                  errorText: 'ZIP code must be 5 digits',
                ),
              ],
              initialValue: '',
            ),
            // Step 3: Confirmation
            FormFieldDefinition<bool>(
              name: 'subscribeNewsletter',
              group: 'confirmation',
              validators: const [],
              initialValue: false,
            ),
            FormFieldDefinition<bool>(
              name: 'acceptTerms',
              group: 'confirmation',
              validators: [
                TypedCommonValidators.mustBeTrue(
                  errorText: 'You must accept the terms to complete registration',
                ),
              ],
              initialValue: false,
            ),
          ],
          validationStrategy: ValidationStrategy.onSubmitThenRealTime,
          child: (context) => const MultiStepFormView(),
        ),
      ),
    );
  }
}

/// Multi-Step Form View Widget handling step navigation and group validation
class MultiStepFormView extends StatefulWidget {
  const MultiStepFormView({super.key});

  @override
  State<MultiStepFormView> createState() => _MultiStepFormViewState();
}

class _MultiStepFormViewState extends State<MultiStepFormView> {
  int _currentStep = 0;

  final List<String> _stepGroups = [
    'personal_info',
    'address_info',
    'confirmation',
  ];

  final List<String> _stepTitles = [
    'Personal Info',
    'Address Details',
    'Confirmation',
  ];

  void _nextStep(BuildContext context) {
    final currentGroup = _stepGroups[_currentStep];
    context.validateGroup(
      currentGroup,
      onValidationPass: () {
        if (_currentStep < _stepGroups.length - 1) {
          setState(() {
            _currentStep++;
          });
        }
      },
      onValidationFail: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fix errors in ${_stepTitles[_currentStep]} before proceeding.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm(BuildContext context, TypedFormState state) {
    context.validateGroup(
      'confirmation',
      onValidationPass: () {
        final formData = {
          'fullName': state.getValue<String>('fullName'),
          'email': state.getValue<String>('email'),
          'street': state.getValue<String>('street'),
          'city': state.getValue<String>('city'),
          'zipCode': state.getValue<String>('zipCode'),
          'subscribeNewsletter': state.getValue<bool>('subscribeNewsletter'),
          'acceptTerms': state.getValue<bool>('acceptTerms'),
        };

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Registration Complete!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Full Name: ${formData['fullName']}'),
                  Text('Email: ${formData['email']}'),
                  Text('Street: ${formData['street']}'),
                  Text('City: ${formData['city']}'),
                  Text('ZIP Code: ${formData['zipCode']}'),
                  Text(
                    'Subscribed to newsletter: ${formData['subscribeNewsletter'] == true ? 'Yes' : 'No'}',
                  ),
                ],
              ),
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
            content: Text('Please accept terms and conditions to submit.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Instructions
          const Text(
            'Multi-Step Registration Wizard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Demonstrating Field Grouping and Group Validation API',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),

          // Step Progress Bar with Passive Group Validity Indicators
          TypedFormBuilder(
            builder: (context, state) {
              return Row(
                children: List.generate(_stepGroups.length, (index) {
                  final groupName = _stepGroups[index];
                  final isCurrent = index == _currentStep;
                  final isValid = context.isGroupValid(groupName);

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        // Allow tapping back to previous steps without validation
                        if (index < _currentStep) {
                          setState(() {
                            _currentStep = index;
                          });
                        } else if (index > _currentStep) {
                          // Validate current step before advancing via indicator tap
                          _nextStep(context);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.blue.shade50
                              : Colors.grey.shade100,
                          border: Border.all(
                            color: isCurrent
                                ? Colors.blue
                                : (isValid ? Colors.green : Colors.grey.shade400),
                            width: isCurrent ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: isCurrent
                                      ? Colors.blue
                                      : (isValid ? Colors.green : Colors.grey),
                                  child: Icon(
                                    isValid ? Icons.check : Icons.circle,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Step ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                      color: isCurrent
                                          ? Colors.blue
                                          : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stepTitles[index],
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 24),

          // Step Content
          IndexedStack(
            index: _currentStep,
            children: [
              _buildStep1PersonalInfo(),
              _buildStep2AddressInfo(),
              _buildStep3Confirmation(),
            ],
          ),

          const SizedBox(height: 24),

          // Action Navigation Buttons
          TypedFormBuilder(
            builder: (context, state) {
              final isLastStep = _currentStep == _stepGroups.length - 1;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  if (!isLastStep)
                    ElevatedButton.icon(
                      onPressed: () => _nextStep(context),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Step'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _submitForm(context, state),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Submit Registration'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Features Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Field Grouping Highlights:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• group: \'personal_info\' on FormFieldDefinition'),
                  Text('• context.validateGroup(\'step_name\') validates step fields'),
                  Text('• context.isGroupValid(\'step_name\') checks status passively'),
                  Text('• Automatically marks group fields touched on validation'),
                  Text('• Re-evaluates form validity seamlessly across steps'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1PersonalInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 1: Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'fullName',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    errorText: field.displayError,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'email',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email),
                    errorText: field.displayError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2AddressInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 2: Address Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'street',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'Street Address',
                    hintText: 'e.g. 123 Main St',
                    prefixIcon: const Icon(Icons.home),
                    errorText: field.displayError,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'city',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'e.g. New York',
                    prefixIcon: const Icon(Icons.location_city),
                    errorText: field.displayError,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<String>(
              fieldName: 'zipCode',
              builder: (context, field) {
                return TextFormField(
                  initialValue: field.value,
                  onChanged: field.updateValue,
                  decoration: InputDecoration(
                    labelText: 'ZIP Code',
                    hintText: 'e.g. 10001',
                    prefixIcon: const Icon(Icons.pin),
                    errorText: field.displayError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Confirmation() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step 3: Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TypedFieldWrapper<bool>(
              fieldName: 'subscribeNewsletter',
              builder: (context, field) {
                return CheckboxListTile(
                  title: const Text('Subscribe to product updates and newsletter'),
                  value: field.value ?? false,
                  onChanged: field.updateValue,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
            const SizedBox(height: 8),
            TypedFieldWrapper<bool>(
              fieldName: 'acceptTerms',
              builder: (context, field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('I accept the terms and conditions'),
                      subtitle: const Text('Required to complete registration'),
                      value: field.value ?? false,
                      onChanged: field.updateValue,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          field.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
