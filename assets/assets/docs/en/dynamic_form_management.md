# Dynamic Form Management

Manage dynamically changing form arrays, update field values and validators at runtime, inject external server errors, and reset form state seamlessly with `TypedFormController`.

## Overview & Architecture

Dynamic forms require altering form structures and error states at runtime without destroying existing user inputs or re-instantiating state controllers:
1. **Dynamic Schema Modifications**: Register or remove field definitions on the fly via `addField()` and `removeField()`.
2. **Programmatic State Updates**: Mutate single or batch field values via `updateFormField()` and `updateFields()`.
3. **Runtime Validator Updates**: Adjust rules dynamically using `updateFieldValidators()`.
4. **Server Error Binding**: Inject backend API validation responses directly into form error state via `updateError()` and `updateErrors()`.
5. **Form Lifecycle Reset**: Restore original values and clear error/touched state via `resetForm()`.

---

## Detailed API Breakdown

### 1. Dynamic Field Registration & Removal

Dynamically modify the set of fields managed by `TypedFormController`:

| Method | Parameters | Description |
| --- | --- | --- |
| `controller.addField<T>()` | `field`, `context` | Registers a new `FormFieldDefinition<T>` and initializes its value and validation state. |
| `controller.addFields()` | `fields`, `context` | Registers multiple new `FormFieldDefinition` instances in batch. |
| `controller.removeField()` | `fieldName`, `context` | Removes field definition, value, error, and touched state for `fieldName`. |
| `controller.removeFields()` | `fieldNames`, `context` | Removes multiple field definitions and cleans up state in batch. |

---

### 2. Programmatic Value Mutators

Update field values programmatically from controllers, API responses, or auto-fill routines:

| Method | Parameters | Description |
| --- | --- | --- |
| `context.updateFormField<T>()` | `fieldName`, `value` | Context extension method to update a single field value. |
| `controller.updateField<T>()` | `fieldName`, `value`, `context` | Controller method to update single field value and run sync validators. |
| `controller.updateFieldWithDebounce<T>()` | `fieldName`, `value`, `context` | Updates field value and schedules debounced async validation. |
| `controller.updateFields()` | `fieldValues`, `context` | Programmatically updates multiple field values in a single batch state mutation. |

---

### 3. Dynamic Validators & Server Error Injection

Inject backend validation errors or update field rules at runtime:

| Method | Parameters | Description |
| --- | --- | --- |
| `controller.updateFieldValidators<T>()` | `name`, `validators`, `context` | Replaces validation rules for field `name` at runtime. |
| `controller.updateError()` | `fieldName`, `errorMessage`, `context` | Manually injects a custom error message onto `fieldName`. |
| `controller.updateErrors()` | `errors`, `context` | Injects a map of field errors (e.g., from a HTTP 422 API response) into form state. |

---

### 4. Lifecycle Reset & Touch Methods

| Method | Parameters | Description |
| --- | --- | --- |
| `controller.resetForm()` | *(none)* | Resets all field values to `initialValues` and clears all errors and touched flags. |
| `controller.touchAllFields()` | `context` | Programmatically marks every registered field in the form as touched. |

---

## Step-by-Step Code Walkthrough

### Step 1: Adding and Removing Fields at Runtime

Add or remove fields dynamically without recreating `TypedFormController`:

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

Update single or multiple field values programmatically:

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

### Step 3: Updating Validators & Server Error Binding

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

// Inject custom external error message (e.g. from HTTP 422 backend response)
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
