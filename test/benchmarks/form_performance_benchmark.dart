import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

/// Benchmark for form field updates
class FormFieldUpdateBenchmark extends BenchmarkBase {
  FormFieldUpdateBenchmark() : super('FormFieldUpdate');

  late TypedFormController _controller;
  late BuildContext _context;

  @override
  void setup() {
    final testFields = List.generate(
        100,
        (index) => FormFieldDefinition<String>(
              name: 'field_$index',
              validators: [TypedCommonValidators.required<String>()],
              initialValue: '',
            ));

    _controller = TypedFormController(fields: testFields);
    _context = _MockBuildContext();
  }

  @override
  void run() {
    // Update a single field
    _controller.updateField(
      fieldName: 'field_50',
      value: 'test_value',
      context: _context,
    );
  }

  @override
  void teardown() {
    _controller.close();
  }
}

/// Benchmark for form validation
class FormValidationBenchmark extends BenchmarkBase {
  FormValidationBenchmark() : super('FormValidation');

  late TypedFormController _controller;
  late BuildContext _context;

  @override
  void setup() {
    final testFields = List.generate(
        50,
        (index) => FormFieldDefinition<String>(
              name: 'field_$index',
              validators: [
                TypedCommonValidators.required<String>(),
                TypedCommonValidators.minLength(3),
                TypedCommonValidators.maxLength(20),
              ],
              initialValue: 'test_value_$index',
            ));

    _controller = TypedFormController(fields: testFields);
    _context = _MockBuildContext();
  }

  @override
  void run() {
    // Validate the entire form
    _controller.validateForm(
      _context,
      onValidationPass: () {},
      onValidationFail: () {},
    );
  }

  @override
  void teardown() {
    _controller.close();
  }
}

/// Benchmark for multiple field updates
class MultipleFieldUpdateBenchmark extends BenchmarkBase {
  MultipleFieldUpdateBenchmark() : super('MultipleFieldUpdate');

  late TypedFormController _controller;
  late BuildContext _context;

  @override
  void setup() {
    final testFields = List.generate(
        50,
        (index) => FormFieldDefinition<String>(
              name: 'field_$index',
              validators: [TypedCommonValidators.required<String>()],
              initialValue: '',
            ));

    _controller = TypedFormController(fields: testFields);
    _context = _MockBuildContext();
  }

  @override
  void run() {
    // Update multiple fields at once
    final fieldValues = <String, String?>{};
    for (int i = 0; i < 10; i++) {
      fieldValues['field_$i'] = 'updated_value_$i';
    }

    _controller.updateFields(
      fieldValues: fieldValues,
      context: _context,
    );
  }

  @override
  void teardown() {
    _controller.close();
  }
}

/// Benchmark for cross-field validation
class CrossFieldValidationBenchmark extends BenchmarkBase {
  CrossFieldValidationBenchmark() : super('CrossFieldValidation');

  late TypedFormController _controller;
  late BuildContext _context;

  @override
  void setup() {
    final testFields = [
      FormFieldDefinition<String>(
        name: 'password',
        validators: [TypedCommonValidators.required<String>()],
        initialValue: 'password123',
      ),
      FormFieldDefinition<String>(
        name: 'confirmPassword',
        validators: [
          TypedCommonValidators.required<String>(),
          TypedCrossFieldValidator<String>(
            dependentFields: ['password'],
            validator: (value, fieldValues, context) {
              final password = fieldValues['password'] as String?;
              if (value != password) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
        initialValue: 'password123',
      ),
    ];

    _controller = TypedFormController(fields: testFields);
    _context = _MockBuildContext();
  }

  @override
  void run() {
    // Update the confirm password field to trigger cross-field validation
    _controller.updateField(
      fieldName: 'confirmPassword',
      value: 'different_password',
      context: _context,
    );
  }

  @override
  void teardown() {
    _controller.close();
  }
}

/// Benchmark for form state access
class FormStateAccessBenchmark extends BenchmarkBase {
  FormStateAccessBenchmark() : super('FormStateAccess');

  late TypedFormController _controller;

  @override
  void setup() {
    final testFields = List.generate(
        100,
        (index) => FormFieldDefinition<String>(
              name: 'field_$index',
              validators: [TypedCommonValidators.required<String>()],
              initialValue: 'value_$index',
            ));

    _controller = TypedFormController(fields: testFields);
  }

  @override
  void run() {
    // Access form state multiple times
    for (int i = 0; i < 100; i++) {
      _controller.getValue<String>('field_$i');
    }
  }

  @override
  void teardown() {
    _controller.close();
  }
}

/// Mock BuildContext for benchmarks
class _MockBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  bool get mounted => true;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor,
          {Object? aspect}) =>
      throw UnimplementedError();

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
          {Object? aspect}) =>
      null;

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  void dispatchNotification(Notification notification) {}

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() => null;

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() => null;

  @override
  RenderObject? findRenderObject() => null;

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() =>
          null;

  @override
  BuildOwner? get owner => null;

  @override
  Size? get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => throw UnimplementedError();
}

/// Main function to run all benchmarks
void main() {
  // print('Running Typed Form Fields Performance Benchmarks...\n');

  // Run benchmarks
  FormFieldUpdateBenchmark().report();
  FormValidationBenchmark().report();
  MultipleFieldUpdateBenchmark().report();
  CrossFieldValidationBenchmark().report();
  FormStateAccessBenchmark().report();

  // print('\nBenchmarks completed!');
}
