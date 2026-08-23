# Validation Strategies

`Typed-Form-Fields` supports 5 distinct validation timing strategies out of the box.

## Available Strategies

### Real-Time Only (`realTimeOnly`)
Validates field inputs immediately on every user keystroke or value change.

### On Submit Only (`onSubmitOnly`)
Defers error display until `controller.validate()` or form submission is explicitly triggered.

### On Submit Then Real-Time (`onSubmitThenRealTime`)
*Default mode.* Silent until the user attempts submission once, after which field errors update dynamically on input.

### All Fields Real-Time (`allFieldsRealTime`)
Validates every registered field in the form whenever any single field value changes.

### Disabled (`disabled`)
Suppresses all validation triggers and error state updates.

## Live Demo

Test strategy switching interactively below:

<live-demo id="registration" />
