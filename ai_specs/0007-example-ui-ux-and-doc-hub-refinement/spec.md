---
type: Spec
title: Example UI/UX Refinement and Extensive Documentation Hub
---

## Problem

The example application presents several UX flaws, visual styling bugs, and missing documentation depth:
1. **Sparse & Incomplete Documentation**: Documentation guides lack step-by-step implementation walkthroughs, copy-pasteable complete Dart code blocks, and comprehensive coverage of all package features described in the `README.md`. [L1]
2. **Legacy Route & Asset Mismatches**: Documentation navigation references an outdated `custom-widgets` section instead of runtime dynamic form management, and file naming conventions between routes and asset paths are inconsistent. [L1, L2]
3. **Multi-Step Form Theme Inversion**: Step progress cards in the Multi-Step Form (Field Grouping) Wizard use inverted background colors in light vs. dark mode due to missing explicit `primaryContainer` / `onPrimaryContainer` theme tokens and hardcoded badge contrast text. [L3]
4. **Premature Dynamic Form Validation**: Dynamic Form screen triggers validation errors immediately upon screen entry or field addition/removal because initial value registration in `TypedFieldWrapper` inadvertently flags untouched fields as touched. [L4]
5. **Obsolete Navigation Entry & Stale Test References**: The application shell includes an obsolete "Widget Gallery" tab and screen (`WidgetGalleryScreen`), even though prebuilt widgets were previously removed in favor of `TypedFieldWrapper<T>`. Existing test suites still depend on the deleted screen. [L5]

## Proposed Outcome

Deliver a polished, fully documented, and accurate example application with:
- 6 comprehensive English (`en`) documentation guides covering every feature in `README.md` with step-by-step guides, complete runnable code blocks with copy support, and embedded interactive live demos. [L1, L2]
- Updated Documentation Hub routing and assets that replace legacy `custom-widgets` with `dynamic-form-management` using standardized snake_case file paths (`assets/docs/en/*.md`). [L1, L2]
- Flawless dark/light mode rendering across all multi-step field group wizard steps and cards. [L3]
- Clean dynamic form behavior where newly added fields remain untouched (`touched = false`) and display validation errors only after user interaction or form submission. [L4]
- Cleaned-up navigation shell and purged test suite without deprecated Widget Gallery routes, screens, or test dependencies. [L5]

## User Stories

1. As a Flutter developer exploring `typed_form_fields`, I want extensive step-by-step English documentation guides with full code blocks and embedded live demos for every package feature so I can quickly learn and copy implementation code into my project. [L1]
2. As a developer navigating the Documentation Hub, I want clear route structure and sidebar sections covering dynamic form management without dead links or obsolete custom-widget guides. [L1, L2]
3. As a developer testing light and dark modes in the Multi-Step Form (Field Grouping) Wizard, I want step indicator cards and badges to maintain readable contrast without inverted card colors. [L3]
4. As a developer using the Dynamic Form screen, I want newly added or initial dynamic form fields to stay clear of error messages until I actually type in them or attempt form submission. [L4]
5. As an example app user, I want a clean navigation menu with only active, relevant showcase screens (Registration, Multi-Step, Dynamic Form, Docs). [L5]

## Requirements

### 1. Extensive Documentation Guides & Coverage [L1]
- Expand the Documentation Hub to 6 distinct English topic sections matching all features from `README.md`:
  1. `getting-started`: Installation, setup, `TypedFormProvider`, `TypedFieldWrapper`, submit button, and AI Agent Skill reference. (Demo: `registration`)
  2. `core-concepts`: Accessing values (`getValue`), inspecting form state (`isDirty`, `initialValues`, `touchedFields`, `isTouched`), BLoC performance optimization (`buildWhen`/`listenWhen`). (Demo: `registration`)
  3. `validation-strategies`: Standard validation strategies (`onSubmitOnly`, `onSubmitThenRealTime`, `realTimeOnly`, `allFieldsRealTime`, `disabled`), built-in `TypedCommonValidators`, cross-field validation (`TypedCrossFieldValidators`), and conditional validation (`TypedConditionalValidator`). (Demo: `registration`)
  4. `async-validation`: Asynchronous validation (`AsyncValidator<T>`), debouncing, loading indicator state (`isValidating`), submission flushing, reset behavior, and exception safety. (Demo: `registration`)
  5. `field-grouping`: Tagging fields with `group`, step validation (`validateGroup`, `isGroupValid`, `touchGroup`), and multi-step form wizard integration. (Demo: `multi-step`)
  6. `dynamic-form-management`: Runtime form modification APIs (`addField`, `removeField`, `updateFormField`, `updateFields`, `updateFieldValidators`, `updateError`, `updateErrors`, `resetForm`). (Demo: `dynamic-form`)
- Each guide must be formatted with 4 distinct parts:
  1. Overview & Prerequisites
  2. Step-by-Step Code Walkthrough
  3. Full Runnable Final Code Block with copy-to-clipboard button (`ShadcnCodeBlockBuilder`)
  4. Embedded Interactive Live Demo tag (`<live-demo id="..." />`)

### 2. Documentation Hub Routing & Asset Structure [L2]
- Create and maintain 6 English markdown files under `assets/docs/en/{topic}.md` using snake_case filenames:
  - `getting_started.md`
  - `core_concepts.md`
  - `validation_strategies.md`
  - `async_validation.md`
  - `field_grouping.md`
  - `dynamic_form_management.md`
- Remove legacy `assets/docs/en/custom_widgets.md` asset file and any non-English doc subdirectories (`assets/docs/es/`, `assets/docs/fr/`, `assets/docs/de/`, `assets/docs/ar/`).
- Update `AppRoutes` to replace `docsCustomWidgets` (`/docs/custom-widgets`) with `docsDynamicFormManagement` (`/docs/dynamic-form-management`).
- Update `DocSidebar.docGuideSections` and `DocViewerWidget._getTopicFileName()` to map `AppRoutes.docsDynamicFormManagement` to `dynamic_form_management.md`.

### 3. Multi-Step (Field Grouping) Theme & Contrast Fixes [L3]
- Update `AppTheme` light and dark theme definitions to include explicit `primaryContainer` and `onPrimaryContainer` color tokens in `ColorScheme.light` and `ColorScheme.dark`.
- Update `MultiStepFormScreen` step header cards to use theme-aware background colors (`colorScheme.primaryContainer` for current step, `colorScheme.surface` or `colorScheme.surfaceContainerHighest` for unselected steps).
- Ensure step badge text inside `CircleAvatar` uses high-contrast theme text color (`colorScheme.onPrimary` when active).

### 4. Dynamic Form Untouched State Preservation [L4]
- Modify `TypedFieldWrapper` in `lib/src/widgets/typed_field_wrapper.dart` so that registering or setting initial field values on field wrapper mount or frame callbacks does not mark the field as touched (`touched = false`).
- Ensure `addField` and dynamic field creation in `DynamicFormScreen` preserve `touchedFields[fieldName] = false`.
- Configure `DynamicFormScreen` validation strategy so that validation errors are hidden until `isTouched(fieldName) == true` or `validateForm()` / `submit` is invoked.

### 5. Widget Gallery Removal & Test Cleanup [L5]
- Delete `example/lib/src/screens/widget_gallery_screen.dart`.
- Remove `AppRoutes.widgetGallery` and its route definition from `app_routes.dart`.
- Remove `Widget Gallery` item from `primaryNavItems` in `app_routes.dart` and navigation handling in `app_shell.dart`.
- Delete `test/integration/widget_gallery_integration_test.dart`.
- Update `test/integration/example_app_integration_test.dart`, `example/test/docs/doc_viewer_test.dart`, and `EmbeddedLiveDemo` to purge all references to `WidgetGalleryScreen` and route `/widget-gallery`.
- Remove legacy route redirects pointing to `/widget-gallery` in `main.dart`.

## Technical Decisions

- **English-Only Markdown Asset Structure**: Maintain English documentation guides in `assets/docs/en/*.md` with snake_case filenames, configured under `example/pubspec.yaml`. [L2]
- **Route Renaming**: Map `/docs/dynamic-form-management` to `dynamic_form_management.md` across `AppRoutes`, `DocSidebar`, and `DocViewerWidget`. [L2]
- **Theme Color Tokens**: Use Shadcn Slate/Zinc semantic color tokens (`ShadcnColors.slate100` / `ShadcnColors.slate800`) for `primaryContainer` in `AppTheme`. [L3]
- **Core Package Scope Boundary**: Explicitly include modifying `lib/src/widgets/typed_field_wrapper.dart` to ensure `FormTouchedTracker.markTouched(fieldName, false)` is respected during initial wrapper mount and field registration. [L4]
- **Shell Navigation Cleanliness**: Keep 4 primary shell tabs: Registration, Multi-Step, Dynamic Form, and Docs. [L5]

## Testing Strategy

- **Widget & Unit Tests**:
  - Test `DocViewerWidget` loads and renders all 6 English markdown documentation guides (`getting_started.md`, `core_concepts.md`, `validation_strategies.md`, `async_validation.md`, `field_grouping.md`, `dynamic_form_management.md`).
  - Test `ShadcnCodeBlockBuilder` code block rendering, clipboard copy tap interaction, and feedback SnackBar.
  - Test `MultiStepFormScreen` step indicators render correctly with readable contrast in both light and dark theme modes.
  - Test `DynamicFormScreen` adds and removes fields with `touched == false` and does not display error text before user interaction.
  - Verify `app_routes.dart`, `app_shell.dart`, and integration test suites run without Widget Gallery references or compilation errors.
- **Verification Commands**:
  - `flutter analyze` (Zero warnings/errors)
  - `flutter test` (All widget & unit tests pass)

## Out of Scope

- Multi-language localization or translations for documentation markdown files.
- Modifying underlying form validation engine core logic in package `lib/src/core/` beyond `lib/src/widgets/typed_field_wrapper.dart` touched state initialization.
- Adding third-party external web search indexing services to the example shell.
