# Field Grouping & Multi-Step Forms

Field grouping allows segmenting a large form into logical subsets via `group` metadata tags, enabling partial validation for multi-step wizards, tabbed inputs, or segmented checkout cards.

## Overview & Architecture

Multi-step workflows require validating individual steps before allowing users to proceed:
1. **Group Metadata Tagging**: Assign `group: 'step_name'` to each `FormFieldDefinition`.
2. **Partial Step Validation**: Trigger validation specifically on fields belonging to a given group via `validateGroup()`.
3. **Passive Validity Checks**: Inspect step readiness via `isGroupValid()` without marking untouched fields.
4. **Group Touch Control**: Force display of validation messages across a group via `touchGroup()`.

---

## Detailed API Breakdown

### 1. Group Tagging in `FormFieldDefinition`

Assign string identifiers to the `group` property of field definitions:

```dart
final fields = [
  // Group 1: Personal Information
  FormFieldDefinition<String>(
    name: 'firstName',
    group: 'personal',
    validators: [TypedCommonValidators.required<String>()],
    initialValue: '',
  ),
  FormFieldDefinition<String>(
    name: 'lastName',
    group: 'personal',
    validators: [TypedCommonValidators.required<String>()],
    initialValue: '',
  ),
  // Group 2: Shipping Address
  FormFieldDefinition<String>(
    name: 'street',
    group: 'shipping',
    validators: [TypedCommonValidators.required<String>()],
    initialValue: '',
  ),
];
```

---

### 2. Group & Subset Validation Methods

Validate specific subsets of fields without evaluating the entire form state:

| Method | Parameters | Description |
| --- | --- | --- |
| `context.validateGroup()` | `groupName`, `onPass`, `onFail` | Marks fields in `groupName` touched and executes validation rules for that group. |
| `controller.validateGroup()` | `groupName`, `context`, `onPass`, `onFail` | Controller-level group validation method. |
| `context.validateFields()` | `fields`, `onPass`, `onFail` | Marks listed field names touched and executes validation rules for those fields. |
| `controller.validateFields()` | `fields`, `context`, `onPass`, `onFail` | Controller-level subset validation method. |

---

### 3. Passive Group Inspection & Touch APIs

Check if a step is valid before enabling a "Next" button without triggering visual error messages:

| Method | Return Type | Description |
| --- | --- | --- |
| `context.isGroupValid(groupName)` | `bool` | Returns `true` if all fields in `groupName` pass validation, without marking untouched fields. |
| `context.areFieldsValid(fieldNames)` | `bool` | Returns `true` if all listed `fieldNames` pass validation, without touching. |
| `context.touchGroup(groupName)` | `void` | Programmatically marks all fields belonging to `groupName` as touched. |

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
  child: (context) => const MultiStepWizardWidget(),
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
