---
type: Work Item
title: Widget Gallery Removal & Nav Shell Cleanup
parent: ../spec.md
---

## What to build
Remove obsolete Widget Gallery code, routes, and test dependencies across the application shell and test suites. Delete `example/lib/src/screens/widget_gallery_screen.dart` and `test/integration/widget_gallery_integration_test.dart`. Remove `AppRoutes.widgetGallery` and its nav item from `app_routes.dart`, `app_shell.dart`, and `main.dart`. Update `test/integration/example_app_integration_test.dart`, `example/test/docs/doc_viewer_test.dart`, and `EmbeddedLiveDemo` to purge all Widget Gallery references.

## Required context
- `example/lib/src/screens/widget_gallery_screen.dart`
- `example/lib/src/shell/app_routes.dart`
- `example/lib/src/shell/app_shell.dart`
- `example/lib/main.dart`
- `example/lib/src/docs/embedded_live_demo.dart`
- `test/integration/widget_gallery_integration_test.dart`
- `test/integration/example_app_integration_test.dart`
- `example/test/docs/doc_viewer_test.dart`

## Acceptance criteria
- [x] `widget_gallery_screen.dart` and `widget_gallery_integration_test.dart` are deleted.
- [x] `AppRoutes.widgetGallery` and `/widget-gallery` route/nav items are removed from `app_routes.dart`, `app_shell.dart`, and `main.dart`.
- [x] `EmbeddedLiveDemo`, `example_app_integration_test.dart`, and `doc_viewer_test.dart` compile and run cleanly without references to `WidgetGalleryScreen` or `nav_widget_gallery`.
- [x] `flutter analyze` passes with zero warnings or errors.

## Covers
- User Stories: 5
- Requirements: 5
- Interview Ledger: L5

## Blocked by
None - ready to start
