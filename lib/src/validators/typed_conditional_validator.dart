import 'package:flutter/material.dart';

import 'validator.dart';

/// A validator that applies validation rules conditionally based on predicates.
///
/// This allows for complex validation logic that depends on:
/// - Field values
/// - Application state
/// - User roles or permissions
/// - External conditions
@immutable
class TypedConditionalValidator<T> extends Validator<T> {
  const TypedConditionalValidator({
    required this.condition,
    required this.validator,
    this.elseValidator,
  });

  /// The condition that determines whether to apply the validator.
  final bool Function(T? value, BuildContext context) condition;

  /// The validator to apply when the condition is true.
  final Validator<T> validator;

  /// Optional validator to apply when the condition is false.
  final Validator<T>? elseValidator;

  @override
  String? validate(T? value, BuildContext context) {
    if (condition(value, context)) {
      return validator.validate(value, context);
    } else if (elseValidator != null) {
      return elseValidator!.validate(value, context);
    }
    return null;
  }
}

/// A validator that applies different validation rules based on multiple conditions.
///
/// Similar to a switch statement for validation logic.
@immutable
class SwitchValidator<T> extends Validator<T> {
  const SwitchValidator({
    required this.validationCases,
    this.defaultValidator,
  });

  /// List of condition-validator pairs.
  final List<ConditionalCase<T>> validationCases;

  /// Optional default validator when no conditions match.
  final Validator<T>? defaultValidator;

  @override
  String? validate(T? value, BuildContext context) {
    for (final validationCase in validationCases) {
      if (validationCase.condition(value, context)) {
        return validationCase.validator.validate(value, context);
      }
    }

    if (defaultValidator != null) {
      return defaultValidator!.validate(value, context);
    }

    return null;
  }
}

/// A case for the SwitchValidator.
@immutable
class ConditionalCase<T> {
  const ConditionalCase({
    required this.condition,
    required this.validator,
  });

  /// The condition for this case.
  final bool Function(T? value, BuildContext context) condition;

  /// The validator to apply when the condition is true.
  final Validator<T> validator;
}

/// A validator that chains multiple validators with conditional logic.
///
/// Allows for complex validation flows where the next validator
/// depends on the result of the previous one.
@immutable
class ChainValidator<T> extends Validator<T> {
  const ChainValidator({
    required this.validators,
    this.stopOnFirstError = true,
  });

  /// List of conditional validators to chain.
  final List<TypedConditionalValidator<T>> validators;

  /// Whether to stop validation on the first error.
  final bool stopOnFirstError;

  @override
  String? validate(T? value, BuildContext context) {
    final errors = <String>[];

    for (final validator in validators) {
      final error = validator.validate(value, context);
      if (error != null) {
        if (stopOnFirstError) {
          return error;
        }
        errors.add(error);
      }
    }

    if (errors.isNotEmpty) {
      return errors.join('; ');
    }

    return null;
  }
}

/// Common conditional validators with built-in logic.
class TypedConditionalValidators {
  TypedConditionalValidators._(); // Private constructor to prevent instantiation

  /// Creates a validator that only applies when the value is not empty.
  ///
  /// Useful for optional fields that should be validated only when provided.
  static TypedConditionalValidator<T> whenNotEmpty<T>(
    Validator<T> validator,
  ) {
    return TypedConditionalValidator<T>(
      condition: (value, context) {
        if (value == null) return false;
        if (value is String) return value.isNotEmpty;
        if (value is Iterable) return value.isNotEmpty;
        return true;
      },
      validator: validator,
    );
  }

  /// Creates a validator that only applies when the value is empty.
  ///
  /// Useful for providing hints or warnings for empty fields.
  static TypedConditionalValidator<T> whenEmpty<T>(
    Validator<T> validator,
  ) {
    return TypedConditionalValidator<T>(
      condition: (value, context) {
        if (value == null) return true;
        if (value is String) return value.isEmpty;
        if (value is Iterable) return value.isEmpty;
        return false;
      },
      validator: validator,
    );
  }

  /// Creates a validator that applies different rules based on string length.
  ///
  /// [shortValidator] applies when length <= [threshold].
  /// [longValidator] applies when length > [threshold].
  static TypedConditionalValidator<String> byLength(
    int threshold,
    Validator<String> shortValidator,
    Validator<String> longValidator,
  ) {
    return TypedConditionalValidator<String>(
      condition: (value, context) => (value?.length ?? 0) <= threshold,
      validator: shortValidator,
      elseValidator: longValidator,
    );
  }

  /// Creates a validator that applies different rules based on numeric value.
  ///
  /// [smallValidator] applies when value <= [threshold].
  /// [largeValidator] applies when value > [threshold].
  static TypedConditionalValidator<num> byValue(
    num threshold,
    Validator<num> smallValidator,
    Validator<num> largeValidator,
  ) {
    return TypedConditionalValidator<num>(
      condition: (value, context) => (value ?? 0) <= threshold,
      validator: smallValidator,
      elseValidator: largeValidator,
    );
  }

  /// Creates a validator that applies different rules based on a pattern match.
  ///
  /// [pattern] is the regular expression to match against.
  /// [matchValidator] applies when the pattern matches.
  /// [noMatchValidator] applies when the pattern doesn't match.
  static TypedConditionalValidator<String> byPattern(
    RegExp pattern,
    Validator<String> matchValidator,
    Validator<String> noMatchValidator,
  ) {
    return TypedConditionalValidator<String>(
      condition: (value, context) => value != null && pattern.hasMatch(value),
      validator: matchValidator,
      elseValidator: noMatchValidator,
    );
  }

  /// Creates a validator that applies rules based on a custom predicate function.
  ///
  /// [predicate] determines which validator to use.
  /// [trueValidator] applies when predicate returns true.
  /// [falseValidator] applies when predicate returns false.
  static TypedConditionalValidator<T> custom<T>(
    bool Function(T? value, BuildContext context) predicate,
    Validator<T> trueValidator,
    Validator<T> falseValidator,
  ) {
    return TypedConditionalValidator<T>(
      condition: predicate,
      validator: trueValidator,
      elseValidator: falseValidator,
    );
  }

  /// Creates a validator that applies progressive validation rules.
  ///
  /// As the user types more, stricter validation rules are applied.
  /// Useful for providing helpful feedback without being too restrictive initially.
  static ChainValidator<String> progressive({
    Validator<String>? basicValidator,
    Validator<String>? intermediateValidator,
    Validator<String>? advancedValidator,
    int intermediateThreshold = 3,
    int advancedThreshold = 8,
  }) {
    final validators = <TypedConditionalValidator<String>>[];

    if (basicValidator != null) {
      validators.add(TypedConditionalValidator<String>(
        condition: (value, context) => (value?.length ?? 0) >= 1,
        validator: basicValidator,
      ));
    }

    if (intermediateValidator != null) {
      validators.add(TypedConditionalValidator<String>(
        condition: (value, context) =>
            (value?.length ?? 0) >= intermediateThreshold,
        validator: intermediateValidator,
      ));
    }

    if (advancedValidator != null) {
      validators.add(TypedConditionalValidator<String>(
        condition: (value, context) =>
            (value?.length ?? 0) >= advancedThreshold,
        validator: advancedValidator,
      ));
    }

    return ChainValidator<String>(
      validators: validators,
      stopOnFirstError: true,
    );
  }
}
