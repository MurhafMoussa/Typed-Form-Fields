import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import '../widgets/inspector_panel.dart';
import '../widgets/showcase_card.dart';

/// Interactive Widget Gallery Showcase Screen displaying all pre-built typed input widgets
/// and custom FieldWrapper components styled with Shadcn UI aesthetics.
class WidgetGalleryScreen extends StatefulWidget {
  final bool embedded;

  const WidgetGalleryScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  late final TypedFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TypedFormController(
      fields: [
        // Text Input
        FormFieldDefinition<String>(
          name: 'textField',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(3),
          ],
          initialValue: '',
        ),
        // Email Input
        FormFieldDefinition<String>(
          name: 'emailField',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.email(),
          ],
          initialValue: '',
        ),
        // Password Input
        FormFieldDefinition<String>(
          name: 'passwordField',
          validators: [
            TypedCommonValidators.required<String>(),
            TypedCommonValidators.minLength(8),
          ],
          initialValue: '',
        ),
        // Number Input
        FormFieldDefinition<double>(
          name: 'numberField',
          validators: [
            TypedCommonValidators.required<double>(),
            TypedCommonValidators.custom<double>((val, ctx) {
              if (val == null) return null;
              if (val < 0.0 || val > 100.0) return 'Value must be between 0 and 100';
              return null;
            }),
          ],
          initialValue: 25.0,
        ),
        // Dropdown Select Input
        FormFieldDefinition<String>(
          name: 'dropdownField',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: '',
        ),
        // Radio Group Choice Input
        FormFieldDefinition<String>(
          name: 'radioField',
          validators: [TypedCommonValidators.required<String>()],
          initialValue: 'standard',
        ),
        // Switch Input
        FormFieldDefinition<bool>(
          name: 'switchField',
          validators: const [],
          initialValue: true,
        ),
        // Checkbox Input
        FormFieldDefinition<bool>(
          name: 'checkboxField',
          validators: [
            TypedCommonValidators.mustBeTrue(
              errorText: 'Terms must be accepted',
            ),
          ],
          initialValue: false,
        ),
        // Slider Input
        FormFieldDefinition<double>(
          name: 'sliderField',
          validators: const [],
          initialValue: 50.0,
        ),
        // Custom FieldWrapper Star Rating
        FormFieldDefinition<int>(
          name: 'customStarRating',
          validators: [
            TypedCommonValidators.custom<int>((val, ctx) {
              if (val == null || val == 0) return 'Please select at least 1 star';
              return null;
            }),
          ],
          initialValue: 0,
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
                title: 'Widget Showcase',
                description:
                    'Pre-built typed input fields and custom FieldWrapper integration with Shadcn UI aesthetics.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Standard Text Controls
                    const Text(
                      'Text & Value Controls',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Text Field
                    TypedFieldWrapper<String>(
                      fieldName: 'textField',
                      builder: (context, field) {
                        return TextFormField(
                          key: const Key('gallery_input_text'),
                          initialValue: field.value,
                          onChanged: field.updateValue,
                          decoration: InputDecoration(
                            labelText: 'Text Input',
                            hintText: 'Enter text (min 3 chars)',
                            prefixIcon: const Icon(Icons.title),
                            errorText: field.displayError,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email Field
                    TypedFieldWrapper<String>(
                      fieldName: 'emailField',
                      builder: (context, field) {
                        return TextFormField(
                          key: const Key('gallery_input_email'),
                          initialValue: field.value,
                          onChanged: field.updateValue,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter valid email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            errorText: field.displayError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    TypedFieldWrapper<String>(
                      fieldName: 'passwordField',
                      builder: (context, field) {
                        return TextFormField(
                          key: const Key('gallery_input_password'),
                          initialValue: field.value,
                          onChanged: field.updateValue,
                          decoration: InputDecoration(
                            labelText: 'Password Input',
                            hintText: 'Min 8 chars',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText: field.displayError,
                          ),
                          obscureText: true,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Number Field
                    TypedFieldWrapper<double>(
                      fieldName: 'numberField',
                      builder: (context, field) {
                        return TextFormField(
                          key: const Key('gallery_input_number'),
                          initialValue: field.value?.toString() ?? '',
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            field.updateValue(parsed ?? 0.0);
                          },
                          decoration: InputDecoration(
                            labelText: 'Numeric Input (0 - 100)',
                            hintText: 'Enter number',
                            prefixIcon: const Icon(Icons.numbers),
                            errorText: field.displayError,
                          ),
                          keyboardType: TextInputType.number,
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Section 2: Selection & Choice Controls
                    const Text(
                      'Selection & Toggle Controls',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dropdown Field
                    TypedFieldWrapper<String>(
                      fieldName: 'dropdownField',
                      builder: (context, field) {
                        return DropdownButtonFormField<String>(
                          key: const Key('gallery_input_dropdown'),
                          initialValue: (field.value == null || field.value!.isEmpty)
                              ? null
                              : field.value,
                          decoration: InputDecoration(
                            labelText: 'Dropdown Option',
                            prefixIcon: const Icon(Icons.arrow_drop_down_circle_outlined),
                            errorText: field.displayError,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'developer',
                              child: Text('Software Developer'),
                            ),
                            DropdownMenuItem(
                              value: 'designer',
                              child: Text('UI/UX Designer'),
                            ),
                            DropdownMenuItem(
                              value: 'manager',
                              child: Text('Product Manager'),
                            ),
                          ],
                          onChanged: field.updateValue,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Radio Group Choice Field
                    TypedFieldWrapper<String>(
                      fieldName: 'radioField',
                      builder: (context, field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subscription Plan (Radio Group)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    key: const Key('radio_plan_standard'),
                                    title: const Text('Standard', style: TextStyle(fontSize: 12)),
                                    value: 'standard',
                                    groupValue: field.value,
                                    onChanged: field.updateValue,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    key: const Key('radio_plan_pro'),
                                    title: const Text('Pro', style: TextStyle(fontSize: 12)),
                                    value: 'pro',
                                    groupValue: field.value,
                                    onChanged: field.updateValue,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    key: const Key('radio_plan_enterprise'),
                                    title: const Text('Enterprise', style: TextStyle(fontSize: 12)),
                                    value: 'enterprise',
                                    groupValue: field.value,
                                    onChanged: field.updateValue,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Switch Field
                    TypedFieldWrapper<bool>(
                      fieldName: 'switchField',
                      builder: (context, field) {
                        return SwitchListTile(
                          key: const Key('gallery_input_switch'),
                          title: const Text('Enable Email Notifications'),
                          subtitle: const Text('Receive weekly summary reports'),
                          value: field.value ?? false,
                          onChanged: field.updateValue,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Checkbox Field
                    TypedFieldWrapper<bool>(
                      fieldName: 'checkboxField',
                      builder: (context, field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              key: const Key('gallery_input_checkbox'),
                              title: const Text('Accept Terms of Service'),
                              value: field.value ?? false,
                              onChanged: field.updateValue,
                              controlAffinity: ListTileControlAffinity.leading,
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

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Section 3: Sliders & Custom FieldWrapper Components
                    const Text(
                      'Interactive & Custom FieldWrapper',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Slider Field
                    TypedFieldWrapper<double>(
                      fieldName: 'sliderField',
                      builder: (context, field) {
                        final val = field.value ?? 0.0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Experience Level (Slider)', style: TextStyle(fontSize: 13)),
                                Text('${val.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Slider(
                              key: const Key('gallery_input_slider'),
                              value: val,
                              min: 0.0,
                              max: 100.0,
                              divisions: 20,
                              onChanged: field.updateValue,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Custom Star Rating Field (Custom FieldWrapper demonstration)
                    TypedFieldWrapper<int>(
                      fieldName: 'customStarRating',
                      builder: (context, field) {
                        final currentRating = field.value ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Custom Star Rating (Custom FieldWrapper<int>)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (index) {
                                final starIndex = index + 1;
                                final isSelected = starIndex <= currentRating;
                                return IconButton(
                                  key: Key('star_rating_$starIndex'),
                                  icon: Icon(
                                    isSelected ? Icons.star : Icons.star_border,
                                    color: isSelected ? Colors.amber : Colors.grey,
                                    size: 28,
                                  ),
                                  onPressed: () => field.updateValue(starIndex),
                                );
                              }),
                            ),
                            if (field.hasError)
                              Text(
                                field.error!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit Gallery Form Action
                    TypedFormBuilder(
                      builder: (context, state) {
                        return ElevatedButton.icon(
                          key: const Key('submit_gallery_button'),
                          onPressed: state.isValid
                              ? () {
                                  showDialog(
                                    context: context,
                                    builder: (dlgCtx) => AlertDialog(
                                      title: const Text('Gallery Form Submitted!'),
                                      content: Text('Form values:\n${state.values}'),
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
                            state.isValid ? 'Submit Gallery Form' : 'Complete Required Controls',
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
