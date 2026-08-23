import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../widgets/inspector_panel.dart';
import '../widgets/showcase_card.dart';

/// Interactive Multi-Step Form Wizard Screen showcasing field grouping,
/// step-by-step partial group validation, and dual-pane state inspection.
class MultiStepFormScreen extends StatefulWidget {
  final bool embedded;

  const MultiStepFormScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<MultiStepFormScreen> createState() => _MultiStepFormScreenState();
}

class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  late final TypedFormController _controller;
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

  @override
  void initState() {
    super.initState();
    _controller = TypedFormController(
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
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
        FormFieldDefinition<String>(
          name: 'city',
          group: 'address_info',
          validators: [TypedCommonValidators.required<String>()],
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
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _nextStep() {
    final currentGroup = _stepGroups[_currentStep];
    _controller.validateGroup(
      currentGroup,
      context: context,
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

  void _submitWizard() {
    final currentGroup = _stepGroups[_currentStep];
    _controller.validateGroup(
      currentGroup,
      context: context,
      onValidationPass: () {
        final state = _controller.state;
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

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 1: Personal Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<String>(
          fieldName: 'fullName',
          builder: (context, field) {
            return TextFormField(
              key: const Key('step_input_full_name'),
              initialValue: field.value,
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                errorText: field.displayError,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<String>(
          fieldName: 'email',
          builder: (context, field) {
            return TextFormField(
              key: const Key('step_input_email'),
              initialValue: field.value,
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email address',
                prefixIcon: const Icon(Icons.email),
                errorText: field.displayError,
              ),
              keyboardType: TextInputType.emailAddress,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 2: Address Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<String>(
          fieldName: 'street',
          builder: (context, field) {
            return TextFormField(
              key: const Key('step_input_street'),
              initialValue: field.value,
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'Street Address',
                hintText: '123 Main Street',
                prefixIcon: const Icon(Icons.home),
                errorText: field.displayError,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<String>(
          fieldName: 'city',
          builder: (context, field) {
            return TextFormField(
              key: const Key('step_input_city'),
              initialValue: field.value,
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'City',
                hintText: 'San Francisco',
                prefixIcon: const Icon(Icons.location_city),
                errorText: field.displayError,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<String>(
          fieldName: 'zipCode',
          builder: (context, field) {
            return TextFormField(
              key: const Key('step_input_zip'),
              initialValue: field.value,
              onChanged: field.updateValue,
              decoration: InputDecoration(
                labelText: 'ZIP Code',
                hintText: '94103',
                prefixIcon: const Icon(Icons.pin),
                errorText: field.displayError,
              ),
              keyboardType: TextInputType.number,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Step 3: Confirmation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TypedFieldWrapper<bool>(
          fieldName: 'subscribeNewsletter',
          builder: (context, field) {
            return CheckboxListTile(
              key: const Key('step_input_newsletter'),
              title: const Text('Subscribe to newsletter and updates'),
              value: field.value ?? false,
              onChanged: field.updateValue,
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
                  key: const Key('step_input_accept_terms'),
                  title: const Text('I accept terms and conditions'),
                  subtitle: const Text('Required to complete registration'),
                  value: field.value ?? false,
                  onChanged: field.updateValue,
                  contentPadding: EdgeInsets.zero,
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupName = _stepGroups[_currentStep];

    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: BlocProvider<TypedFormController>.value(
        value: _controller,
        child: Builder(
          builder: (ctx) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShowcaseCard(
                title: 'Multi-Step Form Wizard',
                description:
                    'Step-by-step wizard demonstrating fieldGroup partial validation API.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Progress Indicator Row
                    TypedFormBuilder(
                      builder: (context, state) {
                        return Row(
                          children: List.generate(_stepGroups.length, (index) {
                            final groupName = _stepGroups[index];
                            final isCurrent = index == _currentStep;
                            final isGroupValid = _controller.isGroupValid(
                              groupName,
                              context: context,
                            );

                            return Expanded(
                              child: InkWell(
                                key: Key('step_tab_$index'),
                                onTap: () {
                                  if (index < _currentStep) {
                                    setState(() {
                                      _currentStep = index;
                                    });
                                  } else if (index > _currentStep) {
                                    _nextStep();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color: isCurrent
                                          ? Theme.of(context).colorScheme.primary
                                          : (isGroupValid
                                              ? Colors.green
                                              : Theme.of(context).colorScheme.outline),
                                      width: isCurrent ? 1.5 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: isCurrent
                                            ? Theme.of(context).colorScheme.primary
                                            : (isGroupValid ? Colors.green : Colors.grey),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _stepTitles[index],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                                        ),
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
                    const SizedBox(height: 20),

                    // Active Step Content View
                    IndexedStack(
                      index: _currentStep,
                      children: [
                        _buildStep1Content(),
                        _buildStep2Content(),
                        _buildStep3Content(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Step Action Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton.icon(
                            key: const Key('btn_step_back'),
                            onPressed: _previousStep,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentStep < _stepGroups.length - 1)
                          ElevatedButton.icon(
                            key: const Key('btn_step_next'),
                            onPressed: _nextStep,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next Step'),
                          )
                        else
                          ElevatedButton.icon(
                            key: const Key('btn_step_submit'),
                            onPressed: _submitWizard,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Submit Registration'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final body = InspectorPanel(
      controller: _controller,
      groupName: activeGroupName,
      child: formBody,
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      body: body,
    );
  }
}
