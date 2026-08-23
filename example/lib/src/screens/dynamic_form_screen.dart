import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../widgets/inspector_panel.dart';
import '../widgets/showcase_card.dart';

/// Dynamic Form Showcase Screen demonstrating adding, removing, and reordering form fields at runtime
/// with type safety, real-time state updates, and dual-pane state inspection.
class DynamicFormScreen extends StatefulWidget {
  final bool embedded;

  const DynamicFormScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  late final TypedFormController _controller;
  final List<FormFieldDefinition> _orderedFields = [];
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _controller = TypedFormController(
      fields: const [],
      validationStrategy: ValidationStrategy.realTimeOnly,
    );

    // Add initial template fields after initial frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _addInitialFields(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _addInitialFields(BuildContext context) {
    _createAndAddField('text', context);
    _createAndAddField('email', context);
  }

  void _createAndAddField(String type, BuildContext context) {
    setState(() {
      _counter++;
      final fieldName = '${type}_$_counter';

      FormFieldDefinition field;
      switch (type) {
        case 'email':
          field = FormFieldDefinition<String>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<String>(),
              TypedCommonValidators.email(),
            ],
            initialValue: '',
          );
          break;
        case 'number':
          field = FormFieldDefinition<double>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<double>(),
              TypedCommonValidators.custom<double>((val, ctx) {
                if (val == null) return null;
                if (val < 0) return 'Value must be positive';
                return null;
              }),
            ],
            initialValue: 0.0,
          );
          break;
        case 'boolean':
          field = FormFieldDefinition<bool>(
            name: fieldName,
            validators: [
              TypedCommonValidators.mustBeTrue(
                errorText: 'Toggle must be enabled',
              ),
            ],
            initialValue: false,
          );
          break;
        default: // text
          field = FormFieldDefinition<String>(
            name: fieldName,
            validators: [
              TypedCommonValidators.required<String>(),
              TypedCommonValidators.minLength(2),
            ],
            initialValue: '',
          );
      }

      _orderedFields.add(field);
      _controller.addField(field: field, context: context);
    });
  }

  void _removeField(String fieldName, BuildContext context) {
    setState(() {
      _orderedFields.removeWhere((f) => f.name == fieldName);
      _controller.removeField(fieldName, context: context);
    });
  }

  void _moveFieldUp(int index) {
    if (index > 0) {
      setState(() {
        final item = _orderedFields.removeAt(index);
        _orderedFields.insert(index - 1, item);
      });
    }
  }

  void _moveFieldDown(int index) {
    if (index < _orderedFields.length - 1) {
      setState(() {
        final item = _orderedFields.removeAt(index);
        _orderedFields.insert(index + 1, item);
      });
    }
  }

  void _clearAllFields(BuildContext context) {
    setState(() {
      final names = _orderedFields.map((f) => f.name).toList();
      for (final name in names) {
        _controller.removeField(name, context: context);
      }
      _orderedFields.clear();
    });
  }

  Widget _buildFieldItem(
    BuildContext context,
    FormFieldDefinition fieldDef,
    int index,
  ) {
    final fieldName = fieldDef.name;
    final isEmailType = fieldName.startsWith('email_');
    final isNumberType = fieldName.startsWith('number_');
    final isBooleanType = fieldName.startsWith('boolean_');

    Widget inputWidget;

    if (isBooleanType) {
      inputWidget = TypedFieldWrapper<bool>(
        fieldName: fieldName,
        builder: (context, field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                key: Key('dynamic_input_$fieldName'),
                title: Text('Toggle Option (#${index + 1})'),
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
      );
    } else if (isNumberType) {
      inputWidget = TypedFieldWrapper<double>(
        fieldName: fieldName,
        builder: (context, field) {
          return TextFormField(
            key: Key('dynamic_input_$fieldName'),
            initialValue: field.value?.toString() ?? '',
            onChanged: (val) {
              final parsed = double.tryParse(val);
              field.updateValue(parsed ?? 0.0);
            },
            decoration: InputDecoration(
              labelText: 'Number Input (#${index + 1})',
              hintText: 'Enter positive number',
              prefixIcon: const Icon(Icons.numbers),
              errorText: field.displayError,
            ),
            keyboardType: TextInputType.number,
          );
        },
      );
    } else if (isEmailType) {
      inputWidget = TypedFieldWrapper<String>(
        fieldName: fieldName,
        builder: (context, field) {
          return TextFormField(
            key: Key('dynamic_input_$fieldName'),
            initialValue: field.value,
            onChanged: field.updateValue,
            decoration: InputDecoration(
              labelText: 'Email Field (#${index + 1})',
              hintText: 'Enter valid email',
              prefixIcon: const Icon(Icons.email_outlined),
              errorText: field.displayError,
            ),
            keyboardType: TextInputType.emailAddress,
          );
        },
      );
    } else {
      inputWidget = TypedFieldWrapper<String>(
        fieldName: fieldName,
        builder: (context, field) {
          return TextFormField(
            key: Key('dynamic_input_$fieldName'),
            initialValue: field.value,
            onChanged: field.updateValue,
            decoration: InputDecoration(
              labelText: 'Text Field (#${index + 1})',
              hintText: 'Enter text value',
              prefixIcon: const Icon(Icons.title),
              errorText: field.displayError,
            ),
          );
        },
      );
    }

    return Container(
      key: Key('dynamic_card_$fieldName'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  '${index + 1}. ${fieldName.split('_').first.toUpperCase()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),

              // Move Up Button
              IconButton(
                key: Key('move_up_$fieldName'),
                icon: const Icon(Icons.arrow_upward, size: 18),
                onPressed: index > 0 ? () => _moveFieldUp(index) : null,
                tooltip: 'Move Up',
              ),

              // Move Down Button
              IconButton(
                key: Key('move_down_$fieldName'),
                icon: const Icon(Icons.arrow_downward, size: 18),
                onPressed: index < _orderedFields.length - 1
                    ? () => _moveFieldDown(index)
                    : null,
                tooltip: 'Move Down',
              ),

              // Remove Button
              IconButton(
                key: Key('delete_$fieldName'),
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: () => _removeField(fieldName, context),
                tooltip: 'Remove Field',
              ),
            ],
          ),
          const SizedBox(height: 8),
          inputWidget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: BlocProvider<TypedFormController>.value(
        value: _controller,
        child: Builder(
          builder: (ctx) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShowcaseCard(
                title: 'Dynamic Form',
                description:
                    'Add, remove, and reorder fields dynamically at runtime while maintaining full type safety.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toolbar: Add Field Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Active Fields (${_orderedFields.length})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_orderedFields.isNotEmpty)
                          TextButton.icon(
                            key: const Key('btn_clear_all_fields'),
                            onPressed: () => _clearAllFields(ctx),
                            icon: const Icon(Icons.delete_sweep, size: 16),
                            label: const Text('Clear All', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          key: const Key('btn_add_text_field'),
                          onPressed: () => _createAndAddField('text', ctx),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Text Field'),
                        ),
                        ElevatedButton.icon(
                          key: const Key('btn_add_email_field'),
                          onPressed: () => _createAndAddField('email', ctx),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Email Field'),
                        ),
                        ElevatedButton.icon(
                          key: const Key('btn_add_number_field'),
                          onPressed: () => _createAndAddField('number', ctx),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Number Field'),
                        ),
                        ElevatedButton.icon(
                          key: const Key('btn_add_boolean_field'),
                          onPressed: () => _createAndAddField('boolean', ctx),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Boolean Field'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // List of Dynamic Fields
                    if (_orderedFields.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.dynamic_form, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text(
                              'No active dynamic fields',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              key: const Key('btn_add_first_field'),
                              onPressed: () => _createAndAddField('text', ctx),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Field'),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: List.generate(
                          _orderedFields.length,
                          (index) => _buildFieldItem(ctx, _orderedFields[index], index),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Submit Action Button
                    BlocBuilder<TypedFormController, TypedFormState>(
                      bloc: _controller,
                      builder: (context, state) {
                        return ElevatedButton.icon(
                          key: const Key('btn_submit_dynamic_form'),
                          onPressed: (state.isValid && _orderedFields.isNotEmpty)
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (dlgCtx) => AlertDialog(
                                      title: const Text('Form Data'),
                                      content: Text('Active values:\n${state.values}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dlgCtx).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            _orderedFields.isEmpty
                                ? 'Add fields to submit'
                                : state.isValid
                                    ? 'Submit Dynamic Form'
                                    : 'Fix validation errors',
                          ),
                        );
                      },
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
