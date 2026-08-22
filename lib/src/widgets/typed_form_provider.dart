import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/src/core/typed_form_controller.dart';
import 'package:typed_form_fields/src/core/validation_strategy.dart';
import 'package:typed_form_fields/src/models/models.dart';

/// A widget that provides form state management to its descendants.
///
/// This widget automatically sets up the form cubit and provides it to all
/// child widgets, eliminating the need for manual BlocProvider setup.
/// Uses BLoC internally for optimal performance with buildWhen/listenWhen.
///
/// **Key Features:**
/// - **Zero Dependencies for Users**: No need to install flutter_bloc
/// - **Automatic Setup**: Handles all provider configuration internally
/// - **Clean API**: Simple widget-based API
/// - **Type Safety**: Full type safety for form fields
/// - **Performance**: Uses BLoC internally with optimized rebuilds
///
/// **Usage Example:**
/// ```dart
/// TypedFormProvider(
///   fields: [
///     TypedFormDefinition<String>(
///       name: 'email',
///       validators: [CommonValidators.required<String>(), CommonValidators.email()],
///       initialValue: '',
///     ),
///     TypedFormDefinition<bool>(
///       name: 'termsAccepted',
///       validators: [CommonValidators.mustBeTrue()],
///       initialValue: false,
///     ),
///   ],
///   child: (context) => MyFormView(),
/// )
/// ```
class TypedFormProvider extends StatefulWidget {
  /// Creates a TypedFormProvider widget.
  const TypedFormProvider({
    super.key,
    required this.fields,
    required this.child,
    this.validationStrategy = ValidationStrategy.realTimeOnly,
    this.onFormStateChanged,
  });

  /// The form fields to manage.
  final List<FormFieldDefinition> fields;

  /// The child widget builder that will have access to the form state.
  /// The BuildContext parameter allows direct access to TypedFormProvider.of(context).
  final Widget Function(BuildContext context) child;

  /// The validation strategy to use.
  final ValidationStrategy validationStrategy;

  /// Optional callback for form state changes.
  final void Function(TypedFormState state)? onFormStateChanged;

  @override
  State<TypedFormProvider> createState() => _TypedFormProviderState();

  /// Gets the form cubit from the current context.
  ///
  /// This method allows you to access the form cubit from anywhere
  /// in the widget tree below the FormProvider.
  static TypedFormController of(BuildContext context) {
    try {
      return context.read<TypedFormController>();
    } catch (e) {
      throw FlutterError(
        'TypedFormProvider.of() called with a context that does not contain a TypedFormProvider.\n'
        'No ancestor could be found starting from the context that was passed to TypedFormProvider.of().\n'
        'The context used was:\n'
        '  $context\n'
        'Make sure that the TypedFormProvider is an ancestor of the widget that is trying to access it.',
      );
    }
  }
}

class _TypedFormProviderState extends State<TypedFormProvider> {
  late final TypedFormController _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TypedFormController(
      fields: widget.fields,
      validationStrategy: widget.validationStrategy,
    );

    // Listen to form state changes if callback is provided
    if (widget.onFormStateChanged != null) {
      _cubit.stream.listen(widget.onFormStateChanged!);
      // Call the callback immediately with the initial state
      widget.onFormStateChanged!(_cubit.state);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TypedFormController>.value(
      value: _cubit,
      child: Builder(builder: (context) {
        return widget.child(context);
      }),
    );
  }
}

/// A widget that rebuilds when the form state changes.
///
/// This widget provides a clean way to access form state using
/// BlocBuilder internally for optimal performance.
///
/// **Usage Example:**
/// ```dart
/// TypedFormBuilder(
///   builder: (context, state) {
///     return ElevatedButton(
///       onPressed: state.isValid ? () => submitForm() : null,
///       child: Text(state.isValid ? 'Submit' : 'Please fill all fields'),
///     );
///   },
/// )
/// ```
class TypedFormBuilder extends StatelessWidget {
  /// Creates a TypedFormBuilder widget.
  const TypedFormBuilder({
    super.key,
    required this.builder,
  });

  /// The builder function that receives the form state.
  final Widget Function(BuildContext context, TypedFormState state) builder;

  @override
  Widget build(BuildContext context) {
    final cubit = TypedFormProvider.of(context);

    return BlocBuilder<TypedFormController, TypedFormState>(
      bloc: cubit,
      builder: (context, state) {
        return builder(context, state);
      },
    );
  }
}

/// A widget that listens to form state changes without rebuilding.
///
/// This widget is useful for side effects like logging, analytics,
/// or triggering other actions when the form state changes.
/// Uses BlocListener internally for optimal performance.
///
/// **Usage Example:**
/// ```dart
/// TypedFormListener(
///   listener: (context, state) {
///     if (state.isValid) {
///       // Log form completion
///       analytics.track('form_completed');
///     }
///   },
///   child: MyFormWidget(),
/// )
/// ```
class TypedFormListener extends StatefulWidget {
  /// Creates a TypedFormListener widget.
  const TypedFormListener({
    super.key,
    required this.listener,
    required this.child,
  });

  /// The listener function that receives form state changes.
  final void Function(BuildContext context, TypedFormState state) listener;

  /// The child widget.
  final Widget child;

  @override
  State<TypedFormListener> createState() => _TypedFormListenerState();
}

class _TypedFormListenerState extends State<TypedFormListener> {
  bool _hasCalledInitialListener = false;

  @override
  void initState() {
    super.initState();
    // Call the listener once with the initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasCalledInitialListener) {
        _hasCalledInitialListener = true;
        final cubit = TypedFormProvider.of(context);
        widget.listener(context, cubit.state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = TypedFormProvider.of(context);

    return BlocListener<TypedFormController, TypedFormState>(
      bloc: cubit,
      listener: (context, state) {
        widget.listener(context, state);
      },
      child: widget.child,
    );
  }
}

/// Extension methods for easier form access.
extension TypedFormProviderExtension on BuildContext {
  /// Gets the form cubit from the nearest TypedFormProvider.
  TypedFormController get formCubit => TypedFormProvider.of(this);

  /// Gets the current form state from the nearest TypedFormProvider.
  TypedFormState get formState => TypedFormProvider.of(this).state;

  /// Gets a form field value with type safety.
  T? getFormValue<T>(String fieldName) =>
      TypedFormProvider.of(this).getValue<T>(fieldName);

  /// Updates a form field value.
  void updateFormField<T>(String fieldName, T? value) {
    TypedFormProvider.of(this).updateField(
      fieldName: fieldName,
      value: value,
      context: this,
    );
  }

  /// Validates the entire form.
  void validateForm({
    required VoidCallback onValidationPass,
    VoidCallback? onValidationFail,
  }) {
    TypedFormProvider.of(this).validateForm(
      this,
      onValidationPass: onValidationPass,
      onValidationFail: onValidationFail,
    );
  }
}
