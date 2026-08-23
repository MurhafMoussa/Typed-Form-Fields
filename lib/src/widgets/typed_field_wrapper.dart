import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// A high-performance universal wrapper widget that provides form validation integration
/// for any type of form field widget. This widget extracts the common
/// pattern used across all form fields for state management, validation,
/// and error handling with optimized rebuilds and listener support.
///
/// **Key Features:**
/// - **Universal**: Works with any widget type (TextField, Checkbox, Radio, etc.)
/// - **Performance Optimized**: Uses BlocConsumer with buildWhen/listenWhen for minimal rebuilds
/// - **FormProvider Access**: Can reach TypedFormController from anywhere in subtree
/// - **Type Safety**: Generic support for different field value types
/// - **Debouncing**: Optional delayed updates for performance
/// - **Value Transformation**: Optional value processing before form updates
/// - **Error Handling**: Consistent error extraction and display
/// - **Listener Support**: React to field state changes without rebuilding
///
/// **Usage Example:**
/// ```dart
/// TypedFieldWrapper<String>(
///   fieldName: 'email',
///   initialValue: 'user@example.com',
///   debounceTime: Duration(milliseconds: 300),
///   transformValue: (value) => value.toLowerCase().trim(),
///   onFieldStateChanged: (value, error, hasError) {
///     // React to field changes without rebuilding
///     print('Field changed: $value, hasError: $hasError');
///   },
///   builder: (context, field) {
///     return TextFormField(
///       initialValue: field.value,
///       onChanged: field.updateValue,
///       decoration: InputDecoration(
///         labelText: 'Email',
///         errorText: field.displayError,
///         suffixIcon: field.isValidating ? CircularProgressIndicator() : null,
///       ),
///     );
///   },
/// )
/// ```
class TypedFieldWrapper<T> extends StatefulWidget {
  const TypedFieldWrapper({
    super.key,
    required this.fieldName,
    required this.builder,
    this.initialValue,
    this.debounceTime,
    this.transformValue,
    this.onValueChanged,
    this.onFieldStateChanged,
  });

  /// Unique identifier for the field within the form.
  final String fieldName;

  /// Builder function that receives the current field state and returns a widget.
  ///
  /// Parameters:
  /// - `context`: Build context
  /// - `field`: Current field state containing `value`, `error`, `hasError`, `isValidating`, and `updateValue`
  final Widget Function(
    BuildContext context,
    TypedFieldState<T> field,
  ) builder;

  /// Initial value for the field.
  final T? initialValue;

  /// Time to wait before triggering form updates after value changes.
  /// Useful for search fields or other scenarios where you want to
  /// reduce the number of form updates during rapid changes.
  final Duration? debounceTime;

  /// Function to transform the value before updating the form state.
  /// Useful for formatting or normalizing input.
  final T Function(T value)? transformValue;

  /// Callback fired when the field value changes (before debouncing).
  final void Function(T? value)? onValueChanged;

  /// Callback fired when the field state changes (value, error, or hasError).
  /// This listener is called without triggering a rebuild, making it perfect
  /// for side effects like logging, analytics, or triggering other actions.
  final void Function(T? value, String? error, bool hasError)?
      onFieldStateChanged;

  @override
  State<TypedFieldWrapper<T>> createState() => _TypedFieldWrapperState<T>();
}

class _TypedFieldWrapperState<T> extends State<TypedFieldWrapper<T>> {
  Timer? _debounceTimer;
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;

    // Update form state with initial value if provided while preserving untouched state
    if (_currentValue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateFormState(_currentValue, touched: false);
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updateValue(T? value) {
    setState(() {
      _currentValue = value;
    });

    // Call the immediate callback if provided
    widget.onValueChanged?.call(value);

    // Handle debounced form updates
    if (widget.debounceTime != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceTime!, () {
        _updateFormState(value, touched: true);
      });
    } else {
      _updateFormState(value, touched: true);
    }
  }

  void _updateFormState(T? value, {bool touched = true}) {
    final transformedValue = value != null && widget.transformValue != null
        ? widget.transformValue!(value)
        : value;

    TypedFormProvider.of(context).updateField(
      fieldName: widget.fieldName,
      value: transformedValue,
      context: context,
      touched: touched,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = TypedFormProvider.of(context);

    return BlocConsumer<TypedFormController, TypedFormState>(
      bloc: cubit,
      buildWhen: (previous, current) {
        // Only rebuild if this specific field's value, error, or validation state changed
        final prevValue = previous.values[widget.fieldName];
        final currValue = current.values[widget.fieldName];
        final prevError = previous.errors[widget.fieldName];
        final currError = current.errors[widget.fieldName];
        final prevValidating =
            previous.validatingFields.contains(widget.fieldName);
        final currValidating =
            current.validatingFields.contains(widget.fieldName);

        return prevValue != currValue ||
            prevError != currError ||
            prevValidating != currValidating;
      },
      listenWhen: (previous, current) {
        // Only listen if this specific field's state changed
        final prevValue = previous.values[widget.fieldName];
        final currValue = current.values[widget.fieldName];
        final prevError = previous.errors[widget.fieldName];
        final currError = current.errors[widget.fieldName];
        final prevValidating =
            previous.validatingFields.contains(widget.fieldName);
        final currValidating =
            current.validatingFields.contains(widget.fieldName);

        return prevValue != currValue ||
            prevError != currError ||
            prevValidating != currValidating;
      },
      listener: (context, state) {
        // Call the field state change listener if provided
        if (widget.onFieldStateChanged != null) {
          final error = state.errors[widget.fieldName];
          final hasError = error != null && error.isNotEmpty;
          final formValue = state.values[widget.fieldName] as T?;
          final effectiveValue = formValue ?? _currentValue;

          widget.onFieldStateChanged!(effectiveValue, error, hasError);
        }
      },
      builder: (context, state) {
        final error = state.errors[widget.fieldName];
        final hasError = error != null && error.isNotEmpty;
        final formValue = state.values[widget.fieldName] as T?;
        final isValidating =
            state.validatingFields.contains(widget.fieldName);

        // Use form value if available, otherwise use current local value
        final effectiveValue = formValue ?? _currentValue;

        final fieldState = TypedFieldState<T>(
          fieldName: widget.fieldName,
          value: effectiveValue,
          error: error,
          hasError: hasError,
          isValidating: isValidating,
          updateValue: _updateValue,
        );

        return widget.builder(context, fieldState);
      },
    );
  }
}
