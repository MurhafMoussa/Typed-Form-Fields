---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: How should the Documentation Hub guides be structured and content-formatted?

Recommended Answer:
- Structure navigation into 6 comprehensive topic sections covering every feature from `README.md`:
  1. Getting Started & Form Setup
  2. Core Concepts, Field State & Inspection
  3. Validation Strategies & Built-in Validators
  4. Async Validation Pipeline
  5. Field Grouping & Multi-Step Wizards
  6. Dynamic Forms & Runtime Management APIs
- Standardize each guide layout into 4 parts:
  1. Overview & Prerequisites
  2. Step-by-Step Code Walkthrough
  3. Full Runnable Final Code Block
  4. Interactive Live Demo (`<live-demo id="..." />`)

Answer: yes great answer

Decision: Expand Documentation Hub into 6 comprehensive guides covering all README features with code blocks, full copyable final code, and interactive live demos.

### L2

Status: current

Question: How should doc localization across supported languages be handled?

Recommended Answer:
- Keep documentation guides in English (`en`) only under `assets/docs/en/{topic}.md`.
- Focus on comprehensive English documentation for all 6 sections without multi-language Markdown assets or doc translation overhead for now.

Answer: i think we will remove localization entierly and leave it in english only for now, no need for localizations in the docs

Decision: Scope Documentation Hub guides exclusively to English (`assets/docs/en/*.md`) across all 6 sections.

### L3

Status: current

Question: How should theme mode color inversion in Multi-Step Form Wizard step cards be fixed?

Recommended Answer:
- Update `AppTheme` to explicitly define Shadcn-compliant `primaryContainer` and `onPrimaryContainer` color tokens in `ColorScheme.light` and `ColorScheme.dark`.
- Update `MultiStepFormScreen` step header cards, progress indicators, and step badge text to use theme-aware semantic color tokens (`onPrimary` for active step avatar text, `onSurface` for step titles, subtle surface fills for step card backgrounds).

Answer: that's correct

Decision: Resolve step card theme color inversion by adding explicit `primaryContainer`/`onPrimaryContainer` tokens in `AppTheme` and refactoring `MultiStepFormScreen` step indicators to use theme-aware contrast colors.

### L4

Status: current

Question: Why does the Dynamic Form screen trigger validation errors immediately on entry or field addition/removal, and how should it be fixed?

Recommended Answer:
- Ensure that adding a field dynamically initializes its state with `touched = false` and does not automatically trigger visible error messages.
- Adjust `TypedFieldWrapper` and `DynamicFormScreen` so setting an initial field definition value or frame setup does not prematurely flag the field as touched.
- Configure `DynamicFormScreen` validation strategy so errors display only after field interaction or form submission.

Answer: Yes. Ensure that adding a field dynamically initializes its state with touched = false and does not automatically trigger visible error messages until the user interacts with the field or submits the form. Also, adjust TypedFieldWrapper and DynamicFormScreen so that setting an initial field definition value during registration/addition does not prematurely flag the field as touched.

Decision: Preserve untouched status (`touched = false`) when adding fields dynamically or registering initial values in `TypedFieldWrapper`, ensuring validation messages render only after user field edit or form submission.

### L5

Status: current

Question: Should the deprecated Widget Gallery screen be removed?

Recommended Answer:
- Completely remove `WidgetGalleryScreen` and all related routes/navigation references to Widget Gallery from `app_routes.dart` and `app_shell.dart`.

Answer: Proceed with recommended answer.

Decision: Remove `WidgetGalleryScreen`, route `/widget-gallery`, and its shell navigation item.
