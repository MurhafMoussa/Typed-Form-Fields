---
type: Work Item
title: Doc Hub Unit/Widget Tests & Integration Tests Refactoring
parent: ../spec.md
---

## What to build
Add doc hub widget tests in `example/test/docs/doc_viewer_test.dart` verifying Markdown rendering, live demo embedding, and TOC generation. Consolidate and update `test/integration/` test suites (`example_app_integration_test.dart`, `registration_form_integration_test.dart`, `widget_gallery_integration_test.dart`, `multi_step_form_integration_test.dart`, `dynamic_form_integration_test.dart`) for new Shadcn UI widget keys and RTL layouts, removing obsolete test files. Verify `flutter build web --release` builds cleanly.

## Required context
- `test/integration/`
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [ ] Widget tests added in `example/test/docs/doc_viewer_test.dart` for Markdown rendering, live demo embedding, locale fallback, and TOC link generation.
- [ ] All 4 showcase integration test suites updated in `test/integration/` with new widget keys (`Key('nav_registration')`, `Key('nav_docs')`, `Key('inspector_panel')`, `Key('strategy_dropdown')`, etc.) and verified for RTL layout rendering.
- [ ] Obsolete integration test files removed/merged cleanly.
- [ ] `flutter build web --release` succeeds without errors.
- [ ] All package unit and widget tests pass 100%.

## Covers
- User Stories: 7
- Testing Strategy: 1, 2, 3, 4
- Interview Ledger: L4

## Blocked by
- 01-example-app-architecture-theme-shell-and-navigation.md
- 02-live-state-inspector-diagnostics-panel-and-widgets.md
- 03-rebuild-interactive-showcase-screens.md
- 04-embedded-documentation-hub-and-markdown-tag-parser.md
