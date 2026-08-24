---
type: Work Item
title: Embedded Documentation Hub, Markdown Tag Parser, and Search Manifest
parent: ../spec.md
---

## What to build
Add `flutter_markdown` and `shadcn_ui` (or `shadcn_flutter`) dependencies to `example/pubspec.yaml`, configure asset bundling for `example/assets/docs/<locale>/` (`en`, `es`, `fr`, `de`, `ar`), write Markdown guides (`getting_started.md`, `core_concepts.md`, `validation_strategies.md`, `async_validation.md`, `field_grouping.md`, `custom_widgets.md`), and build `example/lib/src/docs/` components (`DocViewerWidget`, custom `<live-demo id="..." />` tag parser, `TableOfContentsWidget` for H2/H3 anchor scrolling, Shadcn-styled code block copy button, and top bar `DocSearchOverlay` powered by a pre-indexed search manifest).

## Required context
- `example/pubspec.yaml`
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [ ] Dependencies (`flutter_markdown`, `shadcn_ui` / `shadcn_flutter`) added to `example/pubspec.yaml` and asset folders (`assets/docs/en/`, `es/`, `fr/`, `de/`, `ar/`) declared.
- [ ] Markdown guide files authored for all 6 core documentation topics in `example/assets/docs/en/` with English fallback logic.
- [ ] `DocViewerWidget` renders Markdown guides with Shadcn code syntax highlighting and copy-to-clipboard buttons on code blocks.
- [ ] Custom tag parser embeds live interactive Flutter form components inline via `<live-demo id="..." />`.
- [ ] Sticky sidebar, right-hand Table of Contents (TOC) with smooth anchor scrolling, and client-side pre-indexed `DocSearchOverlay` implemented.

## Covers
- User Stories: 4
- Requirements: 1, 5
- Technical Decisions: 1, 3
- Testing Strategy: 2
- Interview Ledger: L6, L7, L8, L9

## Blocked by
- 01-example-app-architecture-theme-shell-and-navigation.md
- 03-rebuild-interactive-showcase-screens.md
