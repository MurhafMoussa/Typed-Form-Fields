---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: What is the primary goal and target architecture for refactoring TypedFormController?

Recommended Answer:
- Refactoring Strategy: Keep TypedFormController as the canonical Cubit and public API facade, but decompose internal logic into focused mixins or private helpers.
- Public API Contract: Preserve 100% backward compatibility for all public methods (updateField, updateFields, validateForm, addField, removeField, resetForm, etc.) and TypedFormState.
- Negative Requirement: Do not re-introduce fine-grained micro-services or split state management across multiple public BLoCs/Cubits.
- Reason: Maintains clean developer-facing ergonomics and backward compatibility while improving maintainability within lib/src/core/.

Answer: Refactoring Strategy: Keep TypedFormController as the canonical Cubit and public API facade, but decompose internal logic into focused mixins or private helpers (e.g., FieldRegistry for field definitions and FormLifecycleHandler for reset/touch logic).
Public API Contract: Preserve 100% backward compatibility for all public methods (updateField, updateFields, validateForm, addField, removeField, resetForm, etc.) and TypedFormState.
Negative Requirement: Do not re-introduce fine-grained micro-services or split state management across multiple public BLoCs/Cubits.
Reason: Maintains clean developer-facing ergonomics and backward compatibility while improving maintainability within lib/src/core/.

Decision: Keep TypedFormController as the canonical Cubit and public API facade, maintaining 100% backward compatibility while decomposing internal responsibilities.

### L2

Status: current

Question: How should TypedFormController decompose its responsibilities internally to reduce class size while maintaining testability and zero public API breaks?

Recommended Answer:
- Decomposition Pattern: Extract 2 private internal helper classes in lib/src/core/: FormFieldRegistry and FormTouchedTracker.
- Controller Responsibilities: TypedFormController owns Cubit<TypedFormState> state emissions, delegating field storage to FormFieldRegistry and touch tracking to FormTouchedTracker, while coordinating state updates with FormValidator.
- Package Exports: Keep internal helpers unexported in lib/typed_form_fields.dart so they remain package-private.
- Negative Requirement: Do not alter TypedFormState, public method signatures, or constructor parameters on TypedFormController.

Answer: great answer proceed

Decision: Extract internal helper classes FormFieldRegistry and FormTouchedTracker in lib/src/core/ without changing TypedFormState or public controller signatures.

Reason: Separates field storage/validation lookup and touched tracking from Cubit state orchestration without public breaking changes.

### L3

Status: current

Question: How should the refactored controller and its new internal helper components be verified?

Recommended Answer:
- Test Strategy: Retain test/src/core/typed_form_controller_test.dart as the primary public contract regression suite, and add dedicated unit tests for FormFieldRegistry (test/src/core/form_field_registry_test.dart) and FormTouchedTracker (test/src/core/form_touched_tracker_test.dart).
- Verification Commands: flutter analyze and flutter test.
- State Transition Expectations: Verify that initial state initialization, dynamic field mutations, strategy switches, and resets preserve exact state transition behavior.

Answer: great answer proceed

Decision: Maintain public regression tests in typed_form_controller_test.dart and add isolated unit tests for FormFieldRegistry and FormTouchedTracker.

Verification: flutter analyze && flutter test

### L4

Status: current

Question: How should error handling and field exception behaviors be enforced in FormFieldRegistry?

Recommended Answer:
- Registry Delegation: FormFieldRegistry owns field registration, existence checking, type retrieval, and throwing typed exceptions (FormFieldError.fieldNotFound, FormFieldError.fieldAlreadyExists).
- Call-site Behavior: TypedFormController methods call registry.checkFieldExists(fieldName) or registry.registerField(field) which encapsulates validation and error throwing.
- Negative Requirement: TypedFormController should not duplicate field-existence loops or manual field checks.

Answer: great answer proceed

Decision: FormFieldRegistry encapsulates field registration, existence lookups, type checks, and throwing typed FormFieldError exceptions.

### L5

Status: current

Question: What exact methods and interface contract should FormTouchedTracker expose to encapsulate form touched state?

Recommended Answer:
- API Surface: expose initialize, markTouched, markAllTouched, reset, remove, isTouched, and touchedMap.
- Negative Requirement: TypedFormController should not directly manipulate raw Map<String, bool> instances for touched fields.

Answer: great answer proceed

Decision: FormTouchedTracker encapsulates touched field state with explicit initialize, markTouched, markAllTouched, reset, remove, isTouched, and touchedMap methods.

### L6

Status: current

Question: Should FormFieldRegistry and FormTouchedTracker be exposed in the package library exports (lib/typed_form_fields.dart) or remain internal to lib/src/core/?

Recommended Answer:
- Visibility: Keep FormFieldRegistry and FormTouchedTracker strictly package-private internal files in lib/src/core/. Do NOT export them in lib/typed_form_fields.dart.
- Public API Boundary: TypedFormController remains the sole public Cubit entry point for developers using typed_form_fields.

Answer: great answer proceed

Decision: Keep FormFieldRegistry and FormTouchedTracker package-private in lib/src/core/ without exporting them in lib/typed_form_fields.dart.
