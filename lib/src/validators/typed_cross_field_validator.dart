import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/typed_form_controller.dart';
import 'validator.dart';
import 'validator_localizations.dart';

/// A validator that validates a field based on the values of other fields.
///
/// This is useful for validations like:
/// - Password confirmation matching
/// - Date range validation (start date < end date)
/// - Conditional required fields
/// - Business rule validation across multiple fields
@immutable
class TypedCrossFieldValidator<T> extends Validator<T> {
  const TypedCrossFieldValidator({
    required this.dependentFields,
    required this.validator,
  });

  /// List of field names that this validator depends on.
  final List<String> dependentFields;

  /// The validation function that takes the current value, all field values, and context.
  final String? Function(
    T? value,
    Map<String, dynamic> fieldValues,
    BuildContext context,
  ) validator;

  @override
  String? validate(T? value, BuildContext context) {
    // We need to get the field values from somewhere.
    // For now, we'll use a provider pattern or context extension.
    final fieldValues = _getFieldValuesFromContext(context);
    return validator(value, fieldValues, context);
  }

  /// Gets field values from the widget context.
  /// This extracts field values from the CoreFormCubit in the widget tree.
  Map<String, dynamic> _getFieldValuesFromContext(BuildContext context) {
    try {
      // Always use the cubit returned by context.read<CoreFormCubit>()
      return context.read<TypedFormController>().state.values;
    } catch (e) {
      // If no CoreFormCubit is found in the widget tree, return empty map
      return <String, dynamic>{};
    }
  }
}

/// Common cross-field validators with built-in localization support.
class TypedCrossFieldValidators {
  TypedCrossFieldValidators._(); // Private constructor to prevent instantiation

  /// Creates a validator that ensures two fields have matching values.
  ///
  /// Commonly used for password confirmation fields.
  ///
  /// [matchFieldName] is the name of the field to match against.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<T> matches<T>(
    String matchFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<T>(
      dependentFields: [matchFieldName],
      validator: (value, fieldValues, context) {
        final matchValue = fieldValues[matchFieldName];

        if (value != matchValue) {
          return errorText ??
              ValidatorLocalizations.of(context).fieldsMismatchError;
        }

        return null;
      },
    );
  }

  /// Creates a validator that ensures the current field value is different from another field.
  ///
  /// [differentFromFieldName] is the name of the field to be different from.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<T> differentFrom<T>(
    String differentFromFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<T>(
      dependentFields: [differentFromFieldName],
      validator: (value, fieldValues, context) {
        final otherValue = fieldValues[differentFromFieldName];

        if (value == otherValue) {
          return errorText ??
              ValidatorLocalizations.of(context)
                  .fieldsDifferentError(differentFromFieldName);
        }

        return null;
      },
    );
  }

  /// Creates a validator that makes a field required only when another field has a specific value.
  ///
  /// [dependentFieldName] is the name of the field to check.
  /// [requiredWhenValue] is the value that makes this field required.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<T> requiredWhen<T>(
    String dependentFieldName,
    dynamic requiredWhenValue, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<T>(
      dependentFields: [dependentFieldName],
      validator: (value, fieldValues, context) {
        final dependentValue = fieldValues[dependentFieldName];

        if (dependentValue == requiredWhenValue) {
          if (value == null ||
              (value is String && value.isEmpty) ||
              (value is Iterable && value.isEmpty)) {
            return errorText ??
                ValidatorLocalizations.of(context).requiredWhenFieldValueError(
                    dependentFieldName, requiredWhenValue.toString());
          }
        }

        return null;
      },
    );
  }

  /// Creates a validator that makes a field required only when another field is not empty.
  ///
  /// [dependentFieldName] is the name of the field to check.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<T> requiredWhenNotEmpty<T>(
    String dependentFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<T>(
      dependentFields: [dependentFieldName],
      validator: (value, fieldValues, context) {
        final dependentValue = fieldValues[dependentFieldName];

        // Check if dependent field is not empty
        final isDependentNotEmpty = dependentValue != null &&
            (dependentValue is! String || dependentValue.isNotEmpty) &&
            (dependentValue is! Iterable || dependentValue.isNotEmpty);

        if (isDependentNotEmpty) {
          if (value == null ||
              (value is String && value.isEmpty) ||
              (value is Iterable && value.isEmpty)) {
            return errorText ??
                ValidatorLocalizations.of(context)
                    .requiredWhenFieldNotEmptyError(dependentFieldName);
          }
        }

        return null;
      },
    );
  }

  /// Creates a validator for date range validation.
  ///
  /// Ensures that the current date field is before the end date field.
  ///
  /// [endDateFieldName] is the name of the end date field.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<DateTime> dateBefore(
    String endDateFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<DateTime>(
      dependentFields: [endDateFieldName],
      validator: (value, fieldValues, context) {
        if (value == null) return null;

        final endDate = fieldValues[endDateFieldName] as DateTime?;
        if (endDate == null) return null;

        if (value.isAfter(endDate) || value.isAtSameMomentAs(endDate)) {
          return errorText ??
              ValidatorLocalizations.of(context).dateBeforeError;
        }

        return null;
      },
    );
  }

  /// Creates a validator for date range validation.
  ///
  /// Ensures that the current date field is after the start date field.
  ///
  /// [startDateFieldName] is the name of the start date field.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<DateTime> dateAfter(
    String startDateFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<DateTime>(
      dependentFields: [startDateFieldName],
      validator: (value, fieldValues, context) {
        if (value == null) return null;

        final startDate = fieldValues[startDateFieldName] as DateTime?;
        if (startDate == null) return null;

        if (value.isBefore(startDate) || value.isAtSameMomentAs(startDate)) {
          return errorText ?? ValidatorLocalizations.of(context).dateAfterError;
        }

        return null;
      },
    );
  }

  /// Creates a validator that ensures a numeric field is greater than another numeric field.
  ///
  /// [minFieldName] is the name of the field that provides the minimum value.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<num> greaterThan(
    String minFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<num>(
      dependentFields: [minFieldName],
      validator: (value, fieldValues, context) {
        if (value == null) return null;

        final minValue = fieldValues[minFieldName] as num?;
        if (minValue == null) return null;

        if (value <= minValue) {
          return errorText ??
              ValidatorLocalizations.of(context)
                  .greaterThanFieldError(minFieldName);
        }

        return null;
      },
    );
  }

  /// Creates a validator that ensures a numeric field is less than another numeric field.
  ///
  /// [maxFieldName] is the name of the field that provides the maximum value.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<num> lessThan(
    String maxFieldName, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<num>(
      dependentFields: [maxFieldName],
      validator: (value, fieldValues, context) {
        if (value == null) return null;

        final maxValue = fieldValues[maxFieldName] as num?;
        if (maxValue == null) return null;

        if (value >= maxValue) {
          return errorText ??
              ValidatorLocalizations.of(context)
                  .lessThanFieldError(maxFieldName);
        }

        return null;
      },
    );
  }

  /// Creates a validator that ensures the sum of multiple numeric fields meets a condition.
  ///
  /// [fieldNames] are the names of the fields to sum.
  /// [condition] is a function that validates the sum.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<num> sumCondition(
    List<String> fieldNames,
    bool Function(num sum) condition, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<num>(
      dependentFields: fieldNames,
      validator: (value, fieldValues, context) {
        if (value == null) return null;

        num sum = value;
        for (final fieldName in fieldNames) {
          final fieldValue = fieldValues[fieldName] as num?;
          if (fieldValue != null) {
            sum += fieldValue;
          }
        }

        if (!condition(sum)) {
          return errorText ??
              ValidatorLocalizations.of(context).sumConditionError;
        }

        return null;
      },
    );
  }

  /// Creates a validator that ensures at least one field in a group has a value.
  ///
  /// [fieldNames] are the names of the fields in the group.
  /// [errorText] overrides the localized error message if provided.
  static TypedCrossFieldValidator<T> atLeastOneRequired<T>(
    List<String> fieldNames, {
    String? errorText,
  }) {
    return TypedCrossFieldValidator<T>(
      dependentFields: fieldNames,
      validator: (value, fieldValues, context) {
        // Check if current field has value
        if (value != null &&
            (value is! String || value.isNotEmpty) &&
            (value is! Iterable || value.isNotEmpty)) {
          return null; // Current field has value, validation passes
        }

        // Check if any other field in the group has value
        for (final fieldName in fieldNames) {
          final fieldValue = fieldValues[fieldName];
          if (fieldValue != null &&
              (fieldValue is! String || fieldValue.isNotEmpty) &&
              (fieldValue is! Iterable || fieldValue.isNotEmpty)) {
            return null; // Another field has value, validation passes
          }
        }

        return errorText ??
            ValidatorLocalizations.of(context).atLeastOneRequiredError;
      },
    );
  }
}
