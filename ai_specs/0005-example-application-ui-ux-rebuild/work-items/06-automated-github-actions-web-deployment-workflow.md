---
type: Work Item
title: Automated GitHub Actions Web Deployment Workflow
parent: ../spec.md
---

## What to build
Create `.github/workflows/deploy-example.yml` configured to build `flutter build web --release --base-href "/Typed-Form-Fields/"` in `example/` and deploy to the `gh-pages` branch using `peaceiris/actions-gh-pages@v3` on pushes to `main` or `production`.

## Required context
- `ai_specs/0005-example-application-ui-ux-rebuild/spec.md`

## Acceptance criteria
- [ ] Workflow file `.github/workflows/deploy-example.yml` created.
- [ ] Triggers automatically on push to `main` or `production` branches.
- [ ] Configured with `permissions: contents: write`.
- [ ] Runs Flutter web release build with base href `/Typed-Form-Fields/` and publishes artifact to `gh-pages` branch.

## Covers
- User Stories: 6
- Requirements: 7
- Technical Decisions: 5
- Testing Strategy: 3
- Interview Ledger: L2

## Blocked by
None - ready to start
