import 'dart:collection';

/// Internal helper class that manages touched state for form fields.
class FormTouchedTracker {
  /// Creates a [FormTouchedTracker], optionally initializing it with [fieldNames].
  FormTouchedTracker([Iterable<String>? fieldNames]) {
    if (fieldNames != null) {
      initialize(fieldNames);
    }
  }

  final Map<String, bool> _touched = {};

  /// Unmodifiable view of tracked field names and their touched state.
  Map<String, bool> get touchedFields => UnmodifiableMapView(_touched);

  /// Initializes tracking for [fieldNames], marking each as untouched (`false`).
  /// Replaces any previously tracked fields.
  void initialize(Iterable<String> fieldNames) {
    _touched.clear();
    for (final fieldName in fieldNames) {
      _touched[fieldName] = false;
    }
  }

  /// Marks [fieldName] as touched (`true` by default, or as specified by [touched]).
  void markTouched(String fieldName, [bool touched = true]) {
    _touched[fieldName] = touched;
  }

  /// Marks all currently tracked fields as touched (`true`).
  void markAllTouched() {
    for (final key in _touched.keys.toList()) {
      _touched[key] = true;
    }
  }

  /// Resets all currently tracked fields to untouched (`false`).
  void reset() {
    for (final key in _touched.keys.toList()) {
      _touched[key] = false;
    }
  }

  /// Removes a single field from touched tracking.
  void remove(String fieldName) {
    _touched.remove(fieldName);
  }

  /// Removes multiple fields from touched tracking.
  void removeFields(Iterable<String> fieldNames) {
    for (final fieldName in fieldNames) {
      _touched.remove(fieldName);
    }
  }

  /// Returns whether [fieldName] is marked as touched.
  /// Returns `false` if the field is not tracked or not touched.
  bool isTouched(String fieldName) => _touched[fieldName] ?? false;
}
