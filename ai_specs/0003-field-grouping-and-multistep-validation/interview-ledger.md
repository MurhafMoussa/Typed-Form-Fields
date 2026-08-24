---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: How should field grouping be specified on form definitions to identify fields belonging to a specific step or section?

Recommended Answer:
- Add an optional `String? group` parameter to `FormFieldDefinition<T>` (e.g. `group: 'step1'`).

Answer: yes

Decision: Add `group: String?` metadata parameter to `FormFieldDefinition<T>`.

Reason: Using string group tags supports non-numeric section identifiers (e.g. `'personal_info'`, `'billing'`, `'step1'`), accordions, tabs, and multi-step forms without forcing rigid integer step indices.

### L2

Status: current

Question: How should `validateGroup(groupName)` and `validateFields(fieldNames)` handle touched state and error emissions when invoked for a step/subset?

Recommended Answer:
- **Touched State:** All fields in the target group/list are marked as touched (`touched = true`), ensuring any invalid untouched fields immediately display their error messages in the UI.
- **Error Merging:** Validates only the specified fields, updating/clearing errors for those target fields while preserving existing errors on unvalidated fields.
- **Callbacks:** Accepts optional `VoidCallback? onValidationPass` and `VoidCallback? onValidationFail`. Calls `onValidationPass()` if no errors exist for any field in the target group/list, otherwise calls `onValidationFail()`.

Answer: yes

Decision: `validateGroup` and `validateFields` mark target fields as touched (`touched = true`), validate the target fields, merge error updates into form state, and invoke validation callbacks (`onValidationPass` or `onValidationFail`).

Reason: Marking target fields as touched on step navigation attempts prevents invalid fields from silently blocking progression without showing visual error feedback to the user.

### L3

Status: current

Question: How should `isGroupValid('step1')` and `areFieldsValid(['fullName', 'email'])` evaluate validity?

Recommended Answer:
- **Pure Evaluation:** Performs a passive validation check on current values against validators for the specified group/fields without changing `touched` state, without triggering debouncing, and without emitting new form state errors.
- **Return Value:** Returns `true` if all fields in the group/list pass validation (i.e. produce no error), and `false` if any field in the group fails validation or is missing.

Answer: yes

Decision: `isGroupValid` and `areFieldsValid` passively evaluate target field validity without changing touched state, without debouncing, and without emitting state changes.

Reason: Passive validity checks allow "Next" buttons or step indicators to dynamically enable/disable in real time as the user types, without prematurely marking untouched fields as errored.

### L4

Status: current

Question: What should happen when `validateGroup(groupName)` or `validateFields(fieldNames)` is called with a group name or field name that does not exist in the form?

Recommended Answer:
- **`validateFields` for missing field names:** Throws `FormFieldError.fieldNotFound` exception, consistent with `getValue` and `updateField` behavior when an invalid field name is passed.
- **`validateGroup` for empty/unknown group name:** If no fields match the specified `group` name, `validateGroup` returns without throwing, passes validation (`onValidationPass()`), and considers the group valid (`isGroupValid() == true`).

Answer: yes

Decision: `validateFields` throws `FormFieldError.fieldNotFound` for missing field names, while `validateGroup` treats unknown or empty group names as valid with zero errors.

Reason: Explicitly requesting validation on a specific missing field name is a developer error (typo), while validating an empty/optional group is a valid dynamic form scenario.

### L5

Status: current

Question: How should `ValidationStrategy` (such as `onSubmitThenRealTime` or `onSubmitOnly`) interact when `validateGroup` or `validateFields` is invoked?

Recommended Answer:
- **`onSubmitThenRealTime`:** If `validateGroup` or `validateFields` fails, the strategy automatically switches to `realTimeOnly` (just like `validateForm` does), so that as the user types in the current step/group, errors are updated in real-time.
- **`onSubmitOnly`:** Maintains `onSubmitOnly` behavior without automatically switching strategies on validation failure.
- **`realTimeOnly` / `allFieldsRealTime` / `disabled`:** Operates according to strategy.

Answer: yes

Decision: Group and field set validation respects `ValidationStrategy` behavior and triggers automatic switching to `realTimeOnly` when using `onSubmitThenRealTime` on validation failure.

Reason: Matching `validateForm`'s strategy switching logic ensures that `onSubmitThenRealTime` provides the same user-friendly transition to real-time feedback when navigating steps.
