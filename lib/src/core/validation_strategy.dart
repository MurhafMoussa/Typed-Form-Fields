/// Enum representing the available form validation strategies
enum ValidationStrategy {
  /// Validation occurs only upon form submission
  onSubmitThenRealTime,

  /// All fields are validated whenever any field is updated
  allFieldsRealTime,

  /// Only the field currently being edited is validated
  realTimeOnly,

  /// Validation is disabled
  disabled,

  /// Validation is only done on form submission
  onSubmitOnly;

  bool get isSubmissionSpecific =>
      this == onSubmitOnly || this == onSubmitThenRealTime;

  /// Get initial validation state based on strategy
  bool get initialValidationState {
    switch (this) {
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
      case ValidationStrategy.disabled:
        return true;

      case ValidationStrategy.realTimeOnly:
      case ValidationStrategy.allFieldsRealTime:
        return false;
    }
  }

  /// Determine if validation should occur for field updates
  bool shouldValidateOnFieldUpdate() {
    switch (this) {
      case ValidationStrategy.disabled:
        return false;
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
      case ValidationStrategy.realTimeOnly:
      case ValidationStrategy.allFieldsRealTime:
        return true; // All strategies except disabled should validate on field update
    }
  }

  /// Determine if validation should occur for form submission
  bool shouldValidateOnSubmission() {
    switch (this) {
      case ValidationStrategy.disabled:
        return false;
      case ValidationStrategy.onSubmitOnly:
      case ValidationStrategy.onSubmitThenRealTime:
      case ValidationStrategy.realTimeOnly:
      case ValidationStrategy.allFieldsRealTime:
        return true;
    }
  }

  /// Check if strategy should switch after validation failure
  bool shouldSwitchAfterValidationFailure() {
    return this == ValidationStrategy.onSubmitThenRealTime;
  }

  /// Get the strategy to switch to after validation failure
  ValidationStrategy? getStrategyAfterValidationFailure() {
    if (shouldSwitchAfterValidationFailure()) {
      return ValidationStrategy.realTimeOnly;
    }
    return null;
  }

  /// Check if empty values indicate validation errors for this strategy
  bool hasValidationErrorsFromEmptyValues(Map<String, Object?> currentValues) {
    if (this != ValidationStrategy.onSubmitThenRealTime) {
      return false;
    }

    return currentValues.values
        .any((value) => value == null || value.toString().isEmpty);
  }
}
