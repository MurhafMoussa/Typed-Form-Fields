---
type: Work Item
title: Multi-Step Form Wizard Theme Contrast & Color Tokens Fix
parent: ../spec.md
---

## What to build
Update `AppTheme` light and dark theme definitions to include explicit `primaryContainer` and `onPrimaryContainer` color tokens in `ColorScheme.light` and `ColorScheme.dark`. Refactor `MultiStepFormScreen` step header cards, progress indicators, and step badge text to use theme-aware semantic color tokens (`colorScheme.primaryContainer` for current step background, `colorScheme.surface` or `colorScheme.surfaceContainerHighest` for unselected steps, `colorScheme.onPrimary` for active step avatar text, `colorScheme.onSurface` for step titles) to eliminate color inversion in light/dark mode.

## Required context
- `example/lib/src/theme/app_theme.dart`
- `example/lib/src/theme/shadcn_colors.dart`
- `example/lib/src/screens/multi_step_form_screen.dart`
- `example/test/shell_and_theme_test.dart`

## Acceptance criteria
- [x] `AppTheme.lightTheme` and `AppTheme.darkTheme` define explicit `primaryContainer` and `onPrimaryContainer` tokens using Shadcn Slate/Zinc color tokens.
- [x] `MultiStepFormScreen` step header cards and badges render high-contrast text and theme-aware card fills in both light and dark mode.
- [x] `example/test/shell_and_theme_test.dart` and widget tests verify step indicator contrast rendering without color inversion.

## Covers
- User Stories: 3
- Requirements: 3
- Interview Ledger: L3

## Blocked by
None - ready to start
