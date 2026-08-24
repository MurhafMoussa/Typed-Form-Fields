# Contributing to typed_form_fields

First off, thank you for considering contributing to typed_form_fields! We welcome any help, from reporting bugs to submitting new features. Every contribution is valuable.

This document provides guidelines to help you through the contribution process.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

There are many ways to contribute, including:

- **Reporting Bugs:** If you find a bug, please create an issue in our tracker.
- **Suggesting Enhancements:** Have an idea for a new feature or an improvement? Let's discuss it in an issue.
- **Writing Documentation:** Good documentation is crucial. Help us improve the docs, README, or code comments.
- **Submitting Pull Requests:** If you're ready to contribute code, we'd love to review your work.

### Reporting Bugs

Before creating a bug report, please check the existing issues to see if someone has already reported it. When you create a new bug report, please include as many details as possible:

- A clear and descriptive title.
- A detailed description of the problem.
- Steps to reproduce the bug.
- The version of typed_form_fields you are using.
- The output of `flutter doctor -v`.
- Screenshots or GIFs if they help illustrate the issue.

### Suggesting Enhancements

If you have an idea for an enhancement, please create an issue first to discuss your idea. This allows us to align on the proposal before you put significant effort into coding it.

## Your First Code Contribution

Ready to contribute code? Here’s how to set up your environment and get started.

1. Fork the repository on GitHub.
2. Clone your fork to your local machine:
   ```sh
   git clone https://github.com/MurhafMoussa/typed_form_fields.git
   ```
3. Navigate to the project directory:
   ```sh
   cd typed_form_fields
   ```
4. Add the upstream repository to keep your fork in sync:
   ```sh
   git remote add upstream https://github.com/MurhafMoussa/typed_form_fields.git
   ```
5. Create a new feature branch from the development branch (see Branching Strategy below):
   ```sh
   git checkout development
   git pull upstream development
   git checkout -b feature/your-awesome-feature
   ```
6. Make your changes, write tests, and ensure all existing tests pass.
7. Commit your changes and push them to your fork.
8. Open a Pull Request to merge your feature branch into the development branch of the production repository.

## Branching Strategy

We follow a Simplified GitFlow model to keep the repository clean and ensure the stability of published versions.

### Core Branches

- **production:** This branch represents the latest stable, published version on pub.dev. All commits on production are tagged with a version number (e.g., v1.2.3). Never commit directly to this branch.
- **development:** This is the primary development branch. It contains the code for the next upcoming release. All new features are merged into this branch.

### Temporary Branches

- **feature/<feature-name>:** For developing new features.
  - Branched from: development
  - Merged into: development
  - Example: feature/add-autocomplete-field
- **hotfix/<fix-name>:** For fixing critical bugs in a published version.
  - Branched from: production
  - Merged into: both production and development
  - Example: hotfix/fix-date-picker-crash

## Pull Request Process

- Ensure your code adheres to the Effective Dart style guide.
- Make sure all tests pass and, if you've added new functionality, include new tests.
- Update the README.md or other documentation if your changes affect them.
- Update the CHANGELOG.md file with a concise description of your change under the "Unreleased" section.
- Your PR should be targeted to merge into the development branch (unless it's a hotfix).
- Link your PR to any relevant issues.
- Provide a clear description of the changes in your PR.
- Once your PR is submitted, a project productiontainer will review it. We may ask for changes or improvements before merging.

## Issue and Pull Request Templates

To help guide you through the contribution process, we provide templates for:

- [Pull Requests](.github/PULL_REQUEST_TEMPLATE.md): Includes a checklist and prompts to ensure your PR meets our standards.
- [Bug Reports](.github/ISSUE_TEMPLATE/bug_report.md): Helps you provide all necessary information for reporting bugs.
- [Feature Requests](.github/ISSUE_TEMPLATE/feature_request.md): Guides you to submit detailed and actionable feature proposals.

Please use these templates when opening issues or pull requests to help us review and address your contributions efficiently.

## Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
Please follow this style for all commits. Example:

```
feat: add support for conditional validators
fix: correct typo in error message
chore: update dependencies
```

If your commit message does not follow the Conventional Commits format, it will be rejected by the commit-msg hook.

## Contact

If you have any questions or need help getting started, feel free to reach out:

- **GitHub**: [@MurhafMoussa](https://github.com/MurhafMoussa)
- **LinkedIn**: [murhaf-n-moussa](https://www.linkedin.com/in/murhaf-n-moussa/)
- **YouTube**: [@QualityAddict](https://www.youtube.com/@QualityAddict)

---

Thank you again for your interest in making typed_form_fields better!
