---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: How should we structure the refactoring of TypedFormController to reduce its size below 1000 LOC while ensuring zero breaking changes for existing consumers?

Recommended Answer:
- Extract repeated validation strategy dispatch logic into an internal helper class (`FormValidationOrchestrator` in `lib/src/core/form_validation_orchestrator.dart`) and separate `TypedFormState` into a standalone file, while keeping `TypedFormController` as a thin `Cubit<TypedFormState>` public facade.
- 100% backward compatibility for all public methods (`getValue`, `updateField`, `validateForm`, `resetForm`, `addField`, etc.), constructor signatures, and public widget integrations.

Answer: yes

Decision: Extract validation strategy dispatch logic into package-private `FormValidationOrchestrator` and separate `TypedFormState` into a standalone file.

Reason: Eliminating duplicated strategy branching reduces `TypedFormController` size significantly while preserving 100% backward compatibility for all public methods, constructors, and widget integrations.

### L2

Status: current

Question: Should FormValidationOrchestrator also encapsulate group and subset validation routines (validateGroup, validateFields, isGroupValid, areFieldsValid, touchGroup), and what target line count should TypedFormController aim for?

Recommended Answer:
- Consolidate all validation strategy routines and group/subset validation methods inside `FormValidationOrchestrator`.
- `TypedFormController` acts purely as a lightweight facade routing calls to the internal orchestrator, registry, touched tracker, and validator, bringing `TypedFormController` down to ~350–400 LOC.
- Package privacy: `FormValidationOrchestrator` is placed in `lib/src/core/form_validation_orchestrator.dart` and is NOT exported in `lib/typed_form_fields.dart`.

Answer: yes proceed

Decision: Consolidate validation routines and group/subset methods inside package-private `FormValidationOrchestrator`, reducing `TypedFormController` to ~350–400 LOC.

Reason: Encapsulating validation dispatch, strategy transitions, and group/subset evaluation in `FormValidationOrchestrator` achieves clean single-responsibility separation and lowers `TypedFormController` line count below 400 LOC.
