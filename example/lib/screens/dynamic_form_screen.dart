import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Dynamic form screen demonstrating adding and removing form fields
class DynamicFormScreen extends StatefulWidget {
  const DynamicFormScreen({super.key});

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final List<FormFieldDefinition> _dynamicFields = [];
  int _fieldCounter = 0;
  late TypedFormController _formController;

  @override
  void initState() {
    super.initState();

    // Create initial fields first
    _createInitialFields();

    // Initialize form controller with the initial fields
    _formController = TypedFormController(
      fields: _dynamicFields,
      validationStrategy: ValidationStrategy.realTimeOnly,
    );
  }

  void _createInitialFields() {
    // Add initial text field
    _fieldCounter++;
    final textField = _createFieldDefinition<String>(
      name: 'text_$_fieldCounter',
      validators: [
        TypedCommonValidators.required<String>(),
        TypedCommonValidators.minLength(2),
      ],
      initialValue: '',
    );
    _dynamicFields.add(textField);

    // Add initial email field
    _fieldCounter++;
    final emailField = _createFieldDefinition<String>(
      name: 'email_$_fieldCounter',
      validators: [
        TypedCommonValidators.required<String>(),
        TypedCommonValidators.email(),
      ],
      initialValue: '',
    );
    _dynamicFields.add(emailField);
  }

  // Helper method to create field definitions
  FormFieldDefinition<T> _createFieldDefinition<T>({
    required String name,
    required List<Validator<T>> validators,
    T? initialValue,
  }) {
    return FormFieldDefinition<T>(
      name: name,
      validators: validators,
      initialValue: initialValue,
    );
  }

  void _addField(String label, String type) {
    setState(() {
      _fieldCounter++;
      final fieldName = '${type}_$_fieldCounter';

      FormFieldDefinition field;
      switch (type) {
        case 'email':
          field = _createFieldDefinition<String>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<String>(),
              TypedCommonValidators.email(),
            ],
            initialValue: '',
          );
          break;
        case 'number':
          field = _createFieldDefinition<num>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<num>(),
              TypedCommonValidators.min(0),
            ],
            initialValue: 0,
          );
          break;
        case 'boolean':
          field = _createFieldDefinition<bool>(
            name: fieldName,
            validators: [],
            initialValue: false,
          );
          break;
        default: // text
          field = _createFieldDefinition<String>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<String>(),
              TypedCommonValidators.minLength(2),
            ],
            initialValue: '',
          );
      }

      // Add field to existing controller (this will also update the UI)
      _formController.addField(field: field, context: context);

      // Update our local list to keep it in sync with the controller
      _dynamicFields.add(field);
    });
  }

  void _removeField(String fieldName) {
    setState(() {
      // Remove field from existing controller
      _formController.removeField(fieldName, context: context);

      // Remove from our local list to keep it in sync
      _dynamicFields.removeWhere((field) => field.name == fieldName);
      _fieldCounter--;
    });
  }

  void _clearAllFields() {
    setState(() {
      // Remove all fields from the controller
      final fieldNames = _formController.state.fieldTypes.keys.toList();
      for (final fieldName in fieldNames) {
        _formController.removeField(fieldName, context: context);
      }

      _dynamicFields.clear();
      _fieldCounter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider<TypedFormController>(
        create: (context) => _formController,
        child: BlocBuilder<TypedFormController, TypedFormState>(
          builder: (context, state) {
            return state.fieldTypes.isEmpty
                ? _buildEmptyState()
                : _buildFormContent();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dynamic_form, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No fields added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some fields to get started!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addField('Name', 'text'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Field'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            color: Colors.purple.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dynamic_form, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'Dynamic Form Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add and remove form fields dynamically. Each field is fully validated and type-safe!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form Fields
          Expanded(
            child: BlocBuilder<TypedFormController, TypedFormState>(
              builder: (context, state) {
                final fieldNames = state.fieldTypes.keys.toList();
                return ListView.builder(
                  itemCount: fieldNames.length,
                  itemBuilder: (context, index) {
                    final fieldName = fieldNames[index];
                    final fieldType = state.fieldTypes[fieldName]!;
                    return _buildFieldCard(
                      context,
                      fieldName,
                      fieldType,
                      index,
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Add Field Buttons
          _buildAddFieldButtons(),

          const SizedBox(height: 16),

          // Form Actions
          _buildFormActions(),
        ],
      ),
    );
  }

  Widget _buildFieldCard(
    BuildContext context,
    String fieldName,
    Type fieldType,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Header
            Row(
              children: [
                Icon(_getFieldIcon(fieldType), color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getFieldLabel(fieldName),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                BlocBuilder<TypedFormController, TypedFormState>(
                  builder: (context, state) {
                    if (state.fieldTypes.length > 1) {
                      return IconButton(
                        onPressed: () => _removeField(fieldName),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove field',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Field Widget
            _buildFieldWidget(fieldName, fieldType),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWidget(String fieldName, Type fieldType) {
    // Since fieldType is dynamic due to type erasure, we'll determine the type from the field name
    if (fieldName.startsWith('text_') ||
        fieldName.startsWith('email_') ||
        fieldType == String ||
        fieldType.toString() == 'String') {
      return TypedFieldWrapper<String>(
        fieldName: fieldName,
        builder: (context, field) {
          return TextFormField(
            initialValue: field.value ?? '',
            onChanged: field.updateValue,
            decoration: InputDecoration(
              labelText: _getFieldLabel(fieldName),
              hintText: _getFieldHint(fieldName),
              errorText: field.displayError,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_getFieldIcon(fieldType)),
            ),
            keyboardType: _getKeyboardType(fieldName),
          );
        },
      );
    } else if (fieldName.startsWith('number_') ||
        fieldType == num ||
        fieldType.toString() == 'num') {
      return TypedFieldWrapper<num>(
        fieldName: fieldName,
        builder: (context, field) {
          return TextFormField(
            initialValue: field.value?.toString() ?? '0',
            onChanged: (text) {
              final numValue = num.tryParse(text) ?? 0;
              field.updateValue(numValue);
            },
            decoration: InputDecoration(
              labelText: _getFieldLabel(fieldName),
              hintText: _getFieldHint(fieldName),
              errorText: field.displayError,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_getFieldIcon(fieldType)),
            ),
            keyboardType: TextInputType.number,
          );
        },
      );
    } else if (fieldName.startsWith('boolean_') ||
        fieldType == bool ||
        fieldType.toString() == 'bool') {
      return TypedFieldWrapper<bool>(
        fieldName: fieldName,
        builder: (context, field) {
          return SwitchListTile(
            title: Text(_getFieldLabel(fieldName)),
            subtitle: field.hasError
                ? Text(field.error!, style: const TextStyle(color: Colors.red))
                : null,
            value: field.value ?? false,
            onChanged: field.updateValue,
            secondary: Icon(_getFieldIcon(fieldType)),
          );
        },
      );
    }

    return Text('Unsupported field type: $fieldType');
  }

  Widget _buildAddFieldButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Field',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAddButton('Text Field', 'text', Icons.text_fields),
                _buildAddButton('Email Field', 'email', Icons.email),
                _buildAddButton('Number Field', 'number', Icons.numbers),
                _buildAddButton('Boolean Field', 'boolean', Icons.toggle_on),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, String type, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _addField(label, type),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFormActions() {
    return BlocBuilder<TypedFormController, TypedFormState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Form Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Form State Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fields: ${state.fieldTypes.length}'),
                      Text('Valid: ${state.isValid}'),
                      Text('Errors: ${state.errors.length}'),
                      Text('Strategy: ${state.validationStrategy.name}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isValid
                            ? () => _showFormData(context, state)
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearAllFields,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFormData(BuildContext context, TypedFormState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Submitted form data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...state.values.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getFieldIcon(Type fieldType) {
    if (fieldType == String) return Icons.text_fields;
    if (fieldType == num) return Icons.numbers;
    if (fieldType == bool) return Icons.toggle_on;
    return Icons.help;
  }

  String _getFieldLabel(String fieldName) {
    if (fieldName.startsWith('text_')) return 'Text Field';
    if (fieldName.startsWith('email_')) return 'Email Field';
    if (fieldName.startsWith('number_')) return 'Number Field';
    if (fieldName.startsWith('boolean_')) return 'Boolean Field';
    return 'Field';
  }

  String _getFieldHint(String fieldName) {
    if (fieldName.startsWith('text_')) return 'Enter text...';
    if (fieldName.startsWith('email_')) return 'Enter email address...';
    if (fieldName.startsWith('number_')) return 'Enter number...';
    if (fieldName.startsWith('boolean_')) return 'Toggle on/off';
    return 'Enter value...';
  }

  TextInputType _getKeyboardType(String fieldName) {
    if (fieldName.startsWith('email_')) return TextInputType.emailAddress;
    if (fieldName.startsWith('number_')) return TextInputType.number;
    return TextInputType.text;
  }
}
