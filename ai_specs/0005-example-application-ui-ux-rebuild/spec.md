---
type: Spec
title: Example Application UI/UX Rebuild, Documentation Hub & Web Deployment
---

## Problem

The current example application in `example/lib` uses a basic static card list layout with standalone form screens that lack real-time state visibility, interactive strategy switching, dark mode support, structured package documentation beyond a basic `README.md`, and an automated web deployment pipeline. Developers evaluating `Typed-Form-Fields` cannot observe how `TypedFormState`, touched status, or field grouping behave dynamically under different validation strategies without writing custom print statements or debug logs, nor can they access comprehensive guide-level documentation with embedded interactive demos in one place.

## Proposed Outcome

Rebuild the example application from scratch into a modern, responsive showcase application and embedded Documentation Hub styled with the Shadcn UI design system (clean neutral Slate/Zinc palette, crisp subtle borders, high-contrast dark/light mode toggle, Shadcn-styled buttons, inputs, tabs, badges, cards, and code blocks). The new design features a responsive dashboard shell (`NavigationRail` / `NavigationBar`), a dual-pane interactive playground combining a Live Form Preview with a Live State Inspector panel on every showcase screen, an embedded Documentation Hub rendering localized Markdown guides with inline live form demos and page Table of Contents, dark/light theme switching, multi-language localization (EN, ES, FR, DE, AR), and an automated GitHub Actions deployment workflow for free hosting on GitHub Pages.

## User Stories

1. As a developer evaluating the library, I want a responsive dashboard shell with direct navigation to various form scenarios so that I can explore all library capabilities seamlessly. [L1]
2. As a developer testing validation strategies, I want an interactive Live State Inspector alongside every form preview so that I can observe `TypedFormState`, touched flags, error messages, and event logs update in real time. [L1, L3]
3. As a developer, I want to dynamically toggle the active `ValidationStrategy` on live form screens so that I can visually verify how validation timing changes behavior on input, blur, or submit. [L3]
4. As a developer learning `Typed-Form-Fields`, I want an embedded Documentation Hub with structured Markdown guides, inline interactive form demos, page outlines (TOC), and copyable code snippets so that I can learn and test concepts in context without leaving the web app. [L6, L7, L8, L9]
5. As an AI coding assistant or agent, I want an official `typed-form-fields` skill file so that I can accurately generate, refactor, and integrate form management code according to package best practices. [L10]
6. As a package maintainer, I want an automated GitHub Actions workflow deploying the web build of the example app to GitHub Pages on pushes to `main`/`production` so that a live web demo and documentation site is always available. [L2]
7. As a QA/test suite, I want all example integration tests updated to target the new showcase UI widgets and doc hub routes so that CI test coverage remains 100% green. [L4]

## Requirements

1. **Dashboard Shell & Layout:**
   - Implement a responsive navigation shell with `NavigationRail` / `Drawer` for desktop/tablet viewports and `NavigationBar` for mobile viewports styled using the Shadcn UI design system. [L1]
   - Support light, dark, and system theme modes with Shadcn UI design tokens (neutral Slate/Zinc color palettes, 1px subtle borders, crisp elevations, and smooth page transitions). [L1]
   - Provide a top app bar containing a theme mode toggle, locale switcher dropdown (EN, ES, FR, DE, AR), client-side quick search button, and GitHub repository link. [L1, L8]

2. **Dual-Pane Interactive Playground:**
   - Every showcase screen must feature a split layout (side-by-side on desktop, stacked tabs/collapsible on mobile) dividing the screen into a **Live Form Preview** and a **Live State Inspector**. [L1]

3. **Live State Inspector & Diagnostic Tools:**
   - Display a formatted real-time JSON tree of `TypedFormState`: current field values, error messages, touched statuses, `isDirty`, `isValid`, `validatingFields`, and `isValidating`. [L3, L5]
   - Provide an interactive `ValidationStrategy` selector allowing live switching between `realTimeOnly`, `onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, and `disabled`. [L3]
   - Provide quick diagnostic action buttons:
     - **Reset Form**: Clears values and resets touched/dirty states. [L3]
     - **Validate Form / Group**: Executes controller validation and displays result notifications. [L3]
     - **Mark All Touched**: Marks every registered field touched to reveal error states. [L3]
   - Include a scrollable live event log feed recording form state transitions, validation triggers, and async validation status changes. [L3, L5]

4. **Showcase Screens Scope:**
   - `registration_form_screen.dart`: Registration & validation showcase featuring cross-field password matching, simulated async username/email availability check with loading indicators, terms agreement, and BLoC integration toggle. [L4, L5]
   - `widget_gallery_screen.dart`: Widget & field gallery featuring all pre-built typed input widgets and custom `FieldWrapper` demonstrations. [L4]
   - `multi_step_form_screen.dart`: Multi-step wizard demonstrating step-based `fieldGroup` partial validation. [L4]
   - `dynamic_form_screen.dart`: Dynamic form array demonstrating adding, removing, and reordering fields at runtime. [L4]

5. **Embedded Documentation Hub:**
   - Store official guides as Markdown (`.md`) files in `example/assets/docs/<locale>/` (`getting_started.md`, `core_concepts.md`, `validation_strategies.md`, `async_validation.md`, `field_grouping.md`, `custom_widgets.md`) with fallback to `en/` if a localized file is missing. [L6, L7, L9]
   - Render Markdown guides using `flutter_markdown` with Shadcn-styled code block syntax highlighting and a one-click "Copy Code" button on all code snippets. [L7, L9]
   - Support custom tag parsing (e.g. `<live-demo id="..." />`) to dynamically embed interactive, live Flutter form components directly within rendered doc guide streams. Live demos must inherit active global Shadcn UI theme and locale settings. [L6, L7, L9]
   - Display a sticky doc sidebar listing all documentation sections and an auto-generated right-hand Table of Contents (TOC) highlighting `H2`/`H3` headers with smooth anchor scrolling on desktop. [L8]
   - Provide a client-side search overlay in the top bar backed by an in-memory pre-indexed search manifest of guide titles, section headings, and showcase screens for instant navigation. [L8]

6. **Official AI Agent Skill:**
   - Provide an official AI agent skill at `.agents/skills/typed-form-fields/SKILL.md` containing LLM-optimized usage patterns, API cheat-sheets, validation strategy guidance, state management integration examples (BLoC, Provider), and custom widget wrapping workflows using `FieldWrapper`. [L10]

7. **GitHub Actions Web Deployment:**
   - Create `.github/workflows/deploy-example.yml` configured to build `flutter build web --release --base-href "/Typed-Form-Fields/"` and deploy the output artifact to the `gh-pages` branch using `peaceiris/actions-gh-pages@v3` with `contents: write` permissions on pushes to `main` or `production`. [L2]

## Technical Decisions

1. **Modular Architecture (`example/lib/src`):**
   - Structure code cleanly into:
     - `example/lib/src/theme/` (Shadcn UI custom theme tokens, Slate/Zinc light/dark color schemes, custom component themes for buttons, cards, inputs, tabs, and badges, and `ValueNotifier` state for theme mode and locale selection) [L1]
     - `example/lib/src/shell/` (AppShell, responsive drawer/navigation rail, top app bar with pre-indexed search overlay manifest and RTL text/layout direction support for Arabic) [L1, L8]
     - `example/lib/src/widgets/` (Shared `InspectorPanel`, `EventLogWidget`, `JsonViewer`, `ShowcaseCard`)
     - `example/lib/src/screens/` (4 consolidated modular showcase screens) [L4]
     - `example/lib/src/docs/` (`DocViewerWidget`, `MarkdownTagParser`, `TableOfContentsWidget`, `DocSearchOverlay`, `EmbeddedLiveDemo`) [L6, L7, L8]

2. **Routing & Web Compatibility:**
   - Define canonical named hash route constants (`/registration`, `/widget-gallery`, `/multi-step`, `/dynamic-form`, `/docs/getting-started`, `/docs/core-concepts`, `/docs/validation-strategies`, `/docs/async-validation`, `/docs/field-grouping`, `/docs/custom-widgets`) in `MaterialApp` for static hosting compatibility on GitHub Pages without server rewrite requirements. [L2, L8]

3. **Dependencies & Asset Bundling:**
   - Add `flutter_markdown` and `shadcn_ui` (or `shadcn_flutter`) dependencies to `example/pubspec.yaml` and declare all locale asset subdirectories explicitly (`assets/docs/en/`, `assets/docs/es/`, `assets/docs/fr/`, `assets/docs/de/`, `assets/docs/ar/`) under `flutter.assets` to prevent missing asset runtime errors. [L7, L9]

4. **Official AI Agent Skill:**
   - Author `.agents/skills/typed-form-fields/SKILL.md` covering controller lifecycle, state reactivity, validation strategies, async validation pipeline, field grouping, and custom widget wrapping. [L10]

5. **CI Deployment Trigger:**
   - GitHub Actions workflow `.github/workflows/deploy-example.yml` triggered on push to `main` and `production` branches using `peaceiris/actions-gh-pages@v3` with `permissions: contents: write`. [L2]

## Testing Strategy

1. **Integration Tests Update:**
   - Consolidate and update `test/integration/example_app_integration_test.dart` and the 4 consolidated screen integration test suites (`registration_form_integration_test.dart`, `widget_gallery_integration_test.dart`, `multi_step_form_integration_test.dart`, `dynamic_form_integration_test.dart`) to match the new UI widget keys (`Key('nav_registration')`, `Key('nav_docs')`, `Key('inspector_panel')`, `Key('strategy_dropdown')`, etc.) and verify RTL layout rendering for Arabic. Obsolete test files (`login_form_integration_test.dart`, `bloc_form_integration_test.dart`, `validation_strategies_integration_test.dart`, `widget_showcase_integration_test.dart`) will be removed or merged into these 4 suites. [L4]
2. **Doc Hub Widget Tests:**
   - Add widget tests in `example/test/docs/doc_viewer_test.dart` verifying Markdown rendering, live demo embedding tag resolution, locale asset fallback, and Table of Contents link generation. [L6, L7, L8, L9]
3. **Web Build Verification:**
   - Run `flutter build web --release` in `example/` directory during CI verification to ensure zero build errors for web targets. [L2]
4. **Unit & Widget Verification:**
   - Ensure all existing unit tests in `test/` continue to pass without regression. [L4]

## Out of Scope

- Backend database or real server authentication (login and registration use simulated delay/mock handlers).
- Native desktop executable installers (focus is on web and mobile Flutter responsive layouts).
- External static documentation frameworks (MkDocs, Docusaurus, Hugo) or separate documentation hosting pipelines. [L6]
