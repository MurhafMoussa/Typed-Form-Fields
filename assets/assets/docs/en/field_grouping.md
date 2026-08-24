# Field Grouping & Multi-Step Forms

Group related form fields using `group` metadata tags to build multi-step wizards, tabbed forms, or segmented checkout processes with partial step validation.

## Overview & Prerequisites

Multi-step workflows require validating individual steps before allowing users to proceed:
- **Group Metadata Tag**: Assign `group: 'step_name'` to `FormFieldDefinition`.
- **Group Validation**: Invoke `context.validateGroup('step_name')` or `context.isGroupValid('step_name')`.
- **Group Touch**: Use `context.touchGroup('step_name')` to mark all fields in a group as touched.

---

## Step-by-Step Code Walkthrough

### Step 1: Assign Group Tags to Form Fields

Group fields logically by step (e.g. `'account'`, `'personal'`, `'payment'`):

```dart
TypedFormProvider(
  fields: [
    // Step 1 Fields
    FormFieldDefinition<String>(
      name: 'email',
      group: 'account',
      validators: [
        TypedCommonValidators.required<String>(),
        TypedCommonValidators.email(),
      ],
      initialValue: '',
    ),
    // Step 2 Fields
    FormFieldDefinition<String>(
      name: 'fullName',
      group: 'personal',
      validators: [
        TypedCommonValidators.required<String>(),
      ],
      initialValue: '',
    ),
  ],
  child: (context) => MultiStepWizardWidget(),
)
```

### Step 2: Validate Step on Navigation

Validate only the current group when the user clicks "Next":

```dart
void onNextStepPressed(BuildContext context, String currentStep) {
  context.validateGroup(
    currentStep,
    onValidationPass: () {
      // Advance wizard step
      setState(() => currentStepIndex++);
    },
    onValidationFail: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please resolve step errors before proceeding')),
      );
    },
  );
}
```

### Step 3: Passive Group Validity Check

Enable or disable navigation buttons passively without marking untouched fields:

```dart
final isPersonalStepValid = context.isGroupValid('personal');
```

---

## Complete Runnable Example

Below is a runnable 2-step multi-step form wizard powered by field grouping:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class MultiStepWizardForm extends StatefulWidget {
  const MultiStepWizardForm({super.key});

  @override
  State<MultiStepWizardForm> createState() => _MultiStepWizardFormState();
}

class _MultiStepWizardFormState extends State<MultiStepWizardForm> {
  int _currentStep = 0;

  final List<String> _stepGroups = ['account', 'personal'];

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      fields: [
        // Group 1: Account
        FormFieldDefinition<String>(
          name: 'email',
          group: 'account',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
          initialValue: '',
        ),
        // Group 2: Personal
        FormFieldDefinition<String>(
          name: 'fullName',
          group: 'personal',
          validators: [
            TypedCommonValidators.required<String>(),
          ],
          initialValue: '',
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Step Indicators
            Row(
              children: [
                Expanded(
                  child: Chip(
                    label: const Text('1. Account'),
                    backgroundColor: _currentStep == 0 ? Colors.blue.shade100 : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Chip(
                    label: const Text('2. Personal'),
                    backgroundColor: _currentStep == 1 ? Colors.blue.shade100 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Step Content
            if (_currentStep == 0)
              TypedFieldWrapper<String>(
                fieldName: 'email',
                builder: (context, field) {
                  return TextFormField(
                    initialValue: field.value,
                    onChanged: field.updateValue,
                    decoration: InputDecoration(
                      labelText: 'Account Email',
                      errorText: field.displayError,
                    ),
                  );
                },
              )
            else
              TypedFieldWrapper<String>(
                fieldName: 'fullName',
                builder: (context, field) {
                  return TextFormField(
                    initialValue: field.value,
                    onChanged: field.updateValue,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      errorText: field.displayError,
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Wizard Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: () {
                    final currentGroup = _stepGroups[_currentStep];
                    context.validateGroup(
                      currentGroup,
                      onValidationPass: () {
                        if (_currentStep < _stepGroups.length - 1) {
                          setState(() => _currentStep++);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Multi-Step Wizard Complete!')),
                          );
                        }
                      },
                    );
                  },
                  child: Text(_currentStep < _stepGroups.length - 1 ? 'Next' : 'Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Live Interactive Demo

Try navigating through the steps in the live multi-step wizard demo below:

<live-demo id="multi-step" />
