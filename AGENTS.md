# Project Overview

This is a Flutter application for managing magazine
subscribers, subscriptions, editions, and payments.

## Tech Stack

- Flutter and Dart
- SQLite for local data storage
- Drift for database management
- Riverpod for state management
- GoRouter for navigation

## Development Guidelines

- Follow Flutter and Dart best practices.
- Keep code simple, readable, and maintainable.
- Avoid unnecessary abstractions and dependencies.
- Follow the existing project structure and conventions.
- Implement features incrementally.

## Database

- Use Drift for SQLite operations.
- Design and implement the database incrementally.
- Use migrations for schema changes.
- Never delete existing user data during migrations.
- Enforce appropriate constraints and relationships.
- Use transactions for multi-step database operations.
- Keep database logic separate from UI components.

## Architecture

- Separate UI, business logic, and data access.
- Use Riverpod for state management.
- Use repositories for database operations.
- Keep business rules outside UI widgets.

## Testing

- Write tests alongside new features.
- Test database operations and business rules.
- Add regression tests when fixing bugs.
- Run `flutter analyze` and `flutter test`
  after making changes.
- Fix issues introduced by your changes.

## AI Agent Instructions

- Inspect relevant existing code before making changes.
- Do not assume business rules that are not documented.
- Ask for clarification on significant business decisions.
- Do not introduce unnecessary packages.
- Do not modify unrelated functionality.
- Prefer small, focused changes.
- Explain important architectural decisions.
- Do not commit changes unless explicitly requested.