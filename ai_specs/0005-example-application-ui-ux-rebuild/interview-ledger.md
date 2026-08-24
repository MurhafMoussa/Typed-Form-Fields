---
type: Interview Ledger
parent: spec.md
---

## Records

### L1

Status: current

Question: What structural layout and visual theme architecture should replace the current example application's UI/UX?

Recommended Answer:
- Layout Shell: A responsive dashboard shell featuring a collapsible NavigationRail / Drawer on larger screens and a NavigationBar on mobile.
- Dual-Pane Interactive Playground: Each showcase screen uses a split-view layout featuring:
  - Live Form Preview: Clean, modern Shadcn UI interactive form.
  - Live Diagnostics Inspector: Real-time state inspector panel displaying TypedFormState, touched field tracking, error maps, and active validation strategy indicators.
- Visual Design & Themes: Modern Shadcn UI design system theme (clean Slate/Zinc neutral palettes, subtle 1px borders, crisp elevations) with light/dark/system mode toggle, surface cards, smooth page transitions, and quick language switching (EN, ES, FR, DE, AR).
- Navigation: Unified dashboard navigation supporting direct deep-linking / named routes for each example section (/registration, /widget-gallery, /multi-step, /dynamic-form).

Answer: yes this would be great

Decision: Replace the isolated static form screens with a responsive Shadcn UI dashboard shell and a dual-pane interactive playground (Live Form Preview + Live Diagnostics Inspector) with light/dark theme toggle and multi-language support.

Reason: Gives developers real-time visual feedback on form state, touched tracking, and strategy switches while providing a polished web-ready showcase styled with Shadcn UI aesthetics.

### L2

Status: current

Question: How should the new example application be structured and configured for free web hosting (e.g. GitHub Pages or Vercel/Netlify)?

Recommended Answer:
- Web Build & Routing Configuration: Standard Flutter Web build output targeting build/web with hash-based routing.
- GitHub Actions Web Deployment Workflow: Automated GitHub Actions deployment workflow (.github/workflows/deploy-example.yml) that builds flutter build web --release --base-href "/Typed-Form-Fields/" on push to main/production and deploys to gh-pages.
- Web Performance & UX Optimizations: CanvasKit/Wasm rendering auto-selection, responsive touch/mouse layout, share link copy.

Answer: i think your recommended answer is good enough

Decision: Configure the example app for static web deployment on GitHub Pages via automated GitHub Actions workflow (.github/workflows/deploy-example.yml).

Reason: Provides zero-cost, automated deployment directly from the repository whenever code updates occur.

### L3

Status: current

Question: What interactive tools and diagnostic capabilities should be included in the Live State Inspector panel on each showcase screen?

Recommended Answer:
- Form State Monitor: Real-time JSON viewer displaying current values, errors, touched status, isDirty, and isValid.
- Validation Strategy Switcher: Live dropdown allowing users to dynamically switch the ValidationStrategy (realTimeOnly, onSubmitOnly, onSubmitThenRealTime, allFieldsRealTime, disabled) and observe instant behavior changes.
- Form Actions & Diagnostics Bar: Reset Form, Validate All / Validate Group, Mark All Touched, Event Log feed listing recent form events.

Answer: yes this would be great

Decision: Embed a Live State Inspector panel on every showcase screen with real-time JSON state inspection, dynamic validation strategy switcher, quick diagnostic actions (reset, validate, touch-all), and live event log.

Reason: Enables developers to observe state mutations and validation dynamics without adding debug code themselves.

### L4

Status: current

Question: How should the example application's internal file structure and screen architecture be organized?

Recommended Answer:
- Directory Structure: Clean architecture under example/lib/src/ (theme/, shell/, widgets/, screens/).
- Screens: registration_form_screen.dart, widget_gallery_screen.dart, multi_step_form_screen.dart, dynamic_form_screen.dart.
- Integration Tests Compatibility: Update existing example integration tests (test/integration/example_app_integration_test.dart and screen integration tests) to match the new UI widget keys and interactions.

Answer: sounds good to me

Decision: Modularize the example app into clean layers (theme, shell, widgets, screens) and update all corresponding integration tests to ensure 100% test suite passing status.

Reason: Maintains codebase health, reusability of inspector components, and prevents test regressions.

### L5

Status: current

Question: How should we reorder specs 0004 and 0005, and how should Async Validation be integrated into the Example Application UI/UX Rebuild spec?

Recommended Answer:
- Directory & File Renames:
  - Rename `ai_specs/0005-async-validation-support` to `ai_specs/0004-async-validation-support`.
  - Rename `ai_specs/0004-example-application-ui-ux-rebuild` to `ai_specs/0005-example-application-ui-ux-rebuild`.
- Scope Updates for Example Application Rebuild Spec:
  - Update Live State Inspector requirements to display `validatingFields` (`Set<String>`) and `isValidating` (`bool`) alongside active form state.
  - Enhance `registration_form_screen.dart` to include an async validation section (simulated username/email availability check with loading indicators and configurable debounce delay).
  - Retain the 4 modular showcase screens (`registration_form_screen.dart`, `widget_gallery_screen.dart`, `multi_step_form_screen.dart`, `dynamic_form_screen.dart`) rather than adding a separate 5th screen.
- Implementation Sequence:
  - Spec 0004 (*Async Validation Support*) will be implemented and tested first.
  - Spec 0005 (*Example Application UI/UX Rebuild*) will be implemented second, utilizing the finished async validation API and state primitives.

Answer: yes this looks great

Decision: Reorder specs so Spec 0004 is Native Async Validation Support and Spec 0005 is Example Application UI/UX Rebuild & Web Deployment. In Spec 0005, update Live State Inspector to display `validatingFields` and `isValidating`, and incorporate async validation into `registration_form_screen.dart` with loading indicators and configurable debounce controls.

Reason: Building core async validation capabilities prior to rebuilding the showcase UI ensures the Live State Inspector and registration showcase natively support async validation tracking without requiring retroactive refactoring.

### L6

Status: current

Question: How should the official documentation be structured and integrated relative to the example application?

Recommended Answer:
- **Unified Shell Architecture**: Integrate official documentation directly inside the Flutter Web application (`example/`) alongside the interactive form showcases, accessible via a primary navigation section in the `AppShell`.
- **Documentation Sections**:
  1. **Getting Started & Quickstart**: Installation, setup, basic usage.
  2. **Core Concepts**: `TypedFormController`, `TypedFormState`, `TypedFormProvider`, state reactivity.
  3. **Validation Strategies**: In-depth guide for `realTimeOnly`, `onSubmitOnly`, `onSubmitThenRealTime`, `allFieldsRealTime`, and `disabled`.
  4. **Async & Cross-Field Validation**: Rules, debouncing, loading states, error handling.
  5. **Field Grouping & Multi-Step Forms**: Step-based forms, `fieldGroup` partial validation.
  6. **API Reference & Custom Widgets**: Integrating custom inputs using `FieldWrapper`.
- **Live Embedded Demos**: Embed live, interactive form components directly inside relevant documentation guide pages.
- **Coexistence**: Retain standalone Interactive Showcase screens (`/registration`, `/widget-gallery`, `/multi-step`, `/dynamic-form`) while linking to them from doc sections. Package `README.md` serves as a concise summary pointing to the GitHub Pages doc site.
- **Negative Requirement**: Do not introduce external doc site frameworks (such as MkDocs, Docusaurus, or Hugo).

Answer: yes this would be great

Decision: Integrate the official documentation as an embedded Documentation Hub within the Flutter showcase application (`example/`), combining comprehensive Markdown guides with live embedded form demos.

Reason: Maintains a single toolchain and Flutter web deployment while allowing live, interactive form widgets to be rendered directly inline with documentation text.

### L7

Status: current

Question: How should the documentation source content be stored, maintained, and rendered within the Flutter showcase web application?

Recommended Answer:
- **Storage Location**: Store documentation sections as Markdown (`.md`) files inside `example/assets/docs/` (e.g., `getting_started.md`, `core_concepts.md`, `validation_strategies.md`, `async_validation.md`, `field_grouping.md`, `custom_widgets.md`).
- **Markdown Rendering**: Depend on `flutter_markdown` in `example/pubspec.yaml` to render Markdown documents with code syntax highlighting and responsive typography matching Material 3 theme modes.
- **Interactive Code & Live Demos**: Use a custom element builder / tag parser (e.g. `<live-demo id="validation-strategy" />` or code block annotations) to automatically embed interactive Flutter form widgets directly inline within the rendered doc stream.
- **Asset Bundling**: Declare `assets/docs/` under the `flutter.assets` key in `example/pubspec.yaml`.
- **Negative Requirement**: Do not hardcode documentation prose or guides as raw Dart string literals inside Flutter widget files.

Answer: this is great answer too

Decision: Store documentation guides as standalone `.md` files in `example/assets/docs/` rendered at runtime using `flutter_markdown` with custom tag parsing for embedded live form demos.

Reason: Decouples content writing from Dart UI code and keeps documentation readable and easy to maintain in git.

### L8

Status: current

Question: How should navigation, route URLs, and page-level Table of Contents (TOC) work within the Documentation Hub?

Recommended Answer:
- **Route URLs**: Define canonical hash routes for each documentation section (e.g., `/#/docs/getting-started`, `/#/docs/core-concepts`, `/#/docs/validation-strategies`, `/#/docs/async-validation`, `/#/docs/field-grouping`, `/#/docs/custom-widgets`).
- **Doc Sidebar Navigation**: Include a sticky side-navigation panel showing all documentation sections, with active section highlighting and collapse capability.
- **In-Page Table of Contents (TOC)**: Automatically generate a right-hand sticky section outline (desktop viewports) for `H2` and `H3` headers with smooth click-to-scroll to section anchors.
- **Client-Side Quick Search**: Include a client-side search overlay in the top App Bar that indexes documentation page titles, headers, and showcase screens for instant jumping.
- **Negative Requirement**: Do not rely on server-side URL rewrite rules or SSR routing.

Answer: ok great answer too

Decision: Implement canonical hash routing (`/#/docs/...`), a sticky doc sidebar, auto-generated right-hand Table of Contents (TOC) for headers, and a client-side quick search overlay.

Reason: Guarantees deep-linking compatibility on static GitHub Pages hosting and simplifies navigation across long guides.

### L9

Status: current

Question: How should multi-language localization (i18n) and code snippet interactions be handled within the Documentation Hub?

Recommended Answer:
- **Doc Directory Localization Structure**: Store Markdown files in language subdirectories under `example/assets/docs/<locale>/` (e.g., `example/assets/docs/en/getting_started.md`, `example/assets/docs/es/getting_started.md`). Fall back to `en/` if a page translation is missing for the active application locale (`EN`, `ES`, `FR`, `DE`, `AR`).
- **Code Snippet Interactivity**: Render code blocks with a one-click "Copy Code" action button, language syntax labels (e.g., `dart`, `yaml`), and theme-aware syntax highlighting that responds to the app's dark/light mode toggle.
- **Live Demo Sync**: Embedded live form widgets inherit the app's current global locale and theme mode automatically.
- **Negative Requirement**: Do not duplicate Flutter demo widget code across localized docs; only the Markdown text files are translated.

Answer: great answer proceed

Decision: Organize documentation assets by locale (`example/assets/docs/<locale>/`) with fallback to `en/`, enhance code snippets with copy buttons and syntax highlighting, and sync live embedded demos with the app's active locale and theme.

Reason: Delivers an internationalized documentation experience without duplicating Flutter demo code.

### L10

Status: current

Question: Should an official AI agent skill be created for the package?

Recommended Answer:
- Create `.agents/skills/typed-form-fields/SKILL.md` containing LLM-optimized usage patterns, API cheat-sheets, validation strategy guidance, and custom widget wrapping workflows.

Answer: i was thinking also about creating skills for the package so the ai agent knows how to implement it

Decision: Include an official AI agent skill file (`.agents/skills/typed-form-fields/SKILL.md`) providing AI agents and coding assistants with clear instructions on how to use and implement `Typed-Form-Fields`.

Reason: Ensures AI agents generate accurate, idiomatic code when integrating `Typed-Form-Fields` into user projects.
