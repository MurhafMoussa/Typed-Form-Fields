# Typed Form Fields Glossary

Domain vocabulary for form state management, validation strategies, and field grouping.

## Terminology

**Field Group**:
A logical label assigned to a subset of form fields (e.g. `'step1'`, `'billing'`) allowing multi-step wizards or form sections to be validated, checked, and touched independently.
_Avoid_: Step index, Sub-form, Form Section

**Validation Strategy**:
The rule determining when automatic form validation occurs across field updates and form submissions (`onSubmitOnly`, `onSubmitThenRealTime`, `realTimeOnly`, `allFieldsRealTime`, `disabled`).
_Avoid_: Validation Type, Validation Mode
