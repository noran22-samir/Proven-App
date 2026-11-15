# Contributing Guide

Thank you for your interest in contributing to this project. We appreciate all contributions that help improve the application and maintain code quality.

## Getting Started

1. Fork the repository.
2. Clone your fork locally.

```bash
git clone https://github.com/your-username/project-name.git
```

3. Navigate to the project directory.

```bash
cd project-name
```

4. Install dependencies.

```bash
flutter pub get
```

5. Run the application.

```bash
flutter run
```

---

## Branch Strategy

Please do not commit directly to the `main` branch.

Create a new branch for each feature, bug fix, or improvement.

Examples:

```bash
git checkout -b feature/login-screen
git checkout -b feature/profile-page
git checkout -b fix/navigation-bug
```

---

## Coding Standards

- Follow Flutter and Dart best practices.
- Use meaningful class, variable, and function names.
- Keep widgets reusable whenever possible.
- Organize files according to the project structure.
- Remove unused code and imports before submitting.

---

## Commit Message Convention

Use clear commit messages:

Examples:

```text
feat: add login screen UI
fix: resolve navigation issue
refactor: improve folder structure
docs: update README
```

---

## Pull Request Process

Before creating a Pull Request:

- Ensure the project builds successfully.
- Test your changes.
- Resolve merge conflicts if any.
- Update documentation if necessary.

When opening a Pull Request:

- Provide a clear description.
- Explain the purpose of the changes.
- Attach screenshots for UI updates.
- Reference related issues if applicable.

---

## Project Structure

```text
lib/
├── core/
├── features/
├── widgets/
├── services/
└── main.dart
```

Please maintain the existing structure and avoid unnecessary file reorganization.

---

## Reporting Issues

If you find a bug or have a suggestion:

1. Check existing Issues first.
2. Create a new Issue.
3. Provide detailed information and reproduction steps.

---

## Code Review

All contributions will be reviewed before merging into the main branch.

Constructive feedback is part of the development process and helps maintain project quality.

Thank you for contributing and helping improve this project.
