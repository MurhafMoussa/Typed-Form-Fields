---
type: Work Item
title: Documentation Hub Routing, Asset Expansion & Test Coverage
parent: ../spec.md
---

## What to build
Expand and refine the Documentation Hub into 6 comprehensive English guides (`assets/docs/en/*.md`) covering all `README.md` features with 4 parts (Overview, Walkthrough, Copyable Final Code, Live Demo tag). Replace legacy `/docs/custom-widgets` route with `/docs/dynamic-form-management` (`AppRoutes.docsDynamicFormManagement`), mapping to `assets/docs/en/dynamic_form_management.md`. Remove `custom_widgets.md` asset. Update `DocSidebar` and `DocViewerWidget` topic filename resolution. Map `<live-demo>` tags to embedded form screens (`registration`, `multi-step`, `dynamic-form`). Update `doc_viewer_test.dart` with asset bundle loading checks for all 6 guides and widget tests for `ShadcnCodeBlockBuilder` clipboard copy tap interaction.

## Required context
- `assets/docs/en/getting_started.md`
- `assets/docs/en/core_concepts.md`
- `assets/docs/en/validation_strategies.md`
- `assets/docs/en/async_validation.md`
- `assets/docs/en/field_grouping.md`
- `assets/docs/en/dynamic_form_management.md`
- `example/lib/src/shell/app_routes.dart`
- `example/lib/src/docs/doc_sidebar.dart`
- `example/lib/src/docs/doc_viewer_widget.dart`
- `example/lib/src/docs/embedded_live_demo.dart`
- `example/test/docs/doc_viewer_test.dart`

## Acceptance criteria
- [x] 6 English markdown guides exist under `assets/docs/en/` (`getting_started.md`, `core_concepts.md`, `validation_strategies.md`, `async_validation.md`, `field_grouping.md`, `dynamic_form_management.md`), each containing overview, walkthrough, copyable code block, and `<live-demo>` tag.
- [x] `AppRoutes.docsDynamicFormManagement` (`/docs/dynamic-form-management`) replaces `docsCustomWidgets` and correctly loads `dynamic_form_management.md`.
- [x] `DocSidebar` displays "Dynamic Form Management" and navigates to `/docs/dynamic-form-management`.
- [x] Legacy `custom_widgets.md` asset is deleted.
- [x] `doc_viewer_test.dart` includes tests verifying all 6 English doc assets load via `rootBundle` and tests `ShadcnCodeBlockBuilder` code copy button tap.

## Covers
- User Stories: 1, 2
- Requirements: 1, 2
- Interview Ledger: L1, L2

## Blocked by
- ai_specs/0007-example-ui-ux-and-doc-hub-refinement/work-items/03-widget-gallery-removal-and-shell-cleanup.md
