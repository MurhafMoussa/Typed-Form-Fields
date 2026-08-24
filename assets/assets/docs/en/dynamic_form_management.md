# Dynamic Form Management

Manage dynamically changing form arrays, update values and validators at runtime, inject external errors, and reset form state seamlessly with `TypedFormController`.

## Overview & Prerequisites

Dynamic form management APIs allow applications to alter form structure and state at runtime:
- **Field Addition & Removal**: `addField<T>()` and `removeField()`.
- **Programmatic Value Updates**: `updateFormField<T>()` and `updateFields()`.
- **Runtime Validator Updates**: `updateFieldValidators<T>()`.
- **External Error Injection**: `updateError()` and `updateErrors()` (ideal for backend response errors).
- **Form Reset**: `resetForm()`.

---

## Step-by-Step Code Walkthrough

### Step 1: Adding and Removing Fields at Runtime

Add or remove fields dynamically without recreating the `TypedFormController`:

```dart
final controller = context.formCubit;

// Add a new dynamic field
controller.addField<String>(
  field: FormFieldDefinition<String>(
    name: 'item_$newId',
    validators: [TypedCommonValidators.required<String>()],
    initialValue: '',
  ),
  context: context,
);

// Remove a dynamic field
controller.removeField('item_$targetId', context: context);
```

### Step 2: Updating Form Field Values Programmatically

Update single or multiple field values:

```dart
// Update single field value
context.updateFormField<String>('email', 'newemail@example.com');

// Batch update multiple field values
controller.updateFields(
  fieldValues: {
    'firstName': 'John',
    'lastName': 'Doe',
  },
  context: context,
);
```

### Step 3: Updating Validators & External Errors

Dynamically change validation rules or inject backend API error messages:

```dart
// Update validators at runtime
controller.updateFieldValidators<String>(
  name: 'password',
  validators: [
    TypedCommonValidators.required(),
    TypedCommonValidators.minLength(12),
  ],
  context: context,
);

// Inject custom external error message (e.g. from backend API)
controller.updateError(
  fieldName: 'email',
  errorMessage: 'Email is already registered on our server',
  context: context,
);
```

### Step 4: Resetting Form State

Reset all form fields to their initial values and clear error/touched flags:

```dart
controller.resetForm();
```

---

## Complete Runnable Example

Below is a complete runnable dynamic form array example allowing users to add, remove, and reset items dynamically:

```dart
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

class DynamicArrayFormExample extends StatefulWidget {
  const DynamicArrayFormExample({super.key});

  @override
  State<DynamicArrayFormExample> createState() => _DynamicArrayFormExampleState();
}

class _DynamicArrayFormExampleState extends State<DynamicArrayFormExample> {
  final List<String> _itemKeys = ['item_0'];
  int _counter = 1;

  @override
  Widget build(BuildContext context) {
    return TypedFormProvider(
      fields: [
        FormFieldDefinition<String>(
          name: 'item_0',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'First Item',
        ),
      ],
      child: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dynamic Items (${_itemKeys.length})', style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: () {
                    final key = 'item_$_counter';
                    _counter++;
                    setState(() => _itemKeys.add(key));
                    context.formCubit.addField<String>(
                      field: FormFieldDefinition<String>(
                        name: key,
                        validators: [TypedCommonValidators.required<String>()],
                        initialValue: '',
                      ),
                      context: context,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._itemKeys.map((key) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TypedFieldWrapper<String>(
                        fieldName: key,
                        builder: (context, field) {
                          return TextFormField(
                            initialValue: field.value,
                            onChanged: field.updateValue,
                            decoration: InputDecoration(
                              labelText: 'Item ($key)',
                              errorText: field.displayError,
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _itemKeys.length > 1
                          ? () {
                              setState(() => _itemKeys.remove(key));
                              context.formCubit.removeField(key, context: context);
                            }
                          : null,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.formCubit.resetForm(),
                    child: const Text('Reset Form'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.validateForm(
                        onValidationPass: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dynamic Form Submitted Successfully!')),
                          );
                        },
                      );
                    },
                    child: const Text('Submit Form'),
                  ),
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

Try adding and removing dynamic field items in the live demo below:

<live-demo id="dynamic-form" />
