# Typed Form Fields Glossary

Domain vocabulary for form state management, validation strategies, and field grouping.

## Terminology

**Field Group**:
A logical label assigned to a subset of form fields (e.g. `'step1'`, `'billing'`) allowing multi-step wizards or form sections to be validated, checked, and touched independently.
_Avoid_: Step index, Sub-form, Form Section

**Validation Strategy**:
The rule determining when automatic form validation occurs across field updates and form submissions (`onSubmitOnly`, `onSubmitThenRealTime`, `realTimeOnly`, `allFieldsRealTime`, `disabled`).
_Avoid_: Validation Type, Validation Mode

**Live State Inspector**:
A real-time diagnostic panel embedded in example showcase screens that visualizes active `TypedFormState`, field touched status, validation errors, and event logs.
_Avoid_: Debugger overlay, Form monitor bar

**Async Validator**:
An asynchronous validation rule or function assigned to a form field that returns a `Future<String?>` (or `FutureOr<String?>`) to validate asynchronous conditions like network availability checks.
_Avoid_: Remote Validator, Backend Checker

**Documentation Hub**:
The embedded documentation system within the Flutter showcase application that renders Markdown guides alongside interactive live form demos.
_Avoid_: Static Doc Site, Wiki, Documentation Portal
