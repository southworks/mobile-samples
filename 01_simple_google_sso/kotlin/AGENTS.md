# AGENTS.md

## Project context

This is an Android application written in Kotlin.

Follow modern Android development best practices and keep the implementation simple, maintainable, and production-oriented.

## General rules

- Do not update, add, remove, or replace any project dependency without asking for explicit approval first.
- Do not change Gradle, Android Gradle Plugin, Kotlin, Compose, or library versions unless explicitly requested.
- Do not perform broad refactors unless they are necessary for the requested task.
- Prefer small, focused changes.
- Preserve the existing architecture and coding style unless there is a clear reason to improve it.
- When uncertain, explain the trade-off before changing the code.

## Kotlin guidelines

- Use idiomatic Kotlin.
- Prefer immutability with `val` over `var`.
- Use null-safety properly; avoid `!!` unless there is no reasonable alternative.
- Prefer sealed classes/interfaces for finite UI states.
- Prefer data classes for immutable state models.
- Keep functions small and readable.
- Avoid overengineering.

## Android guidelines

- Follow Android lifecycle best practices.
- Avoid memory leaks, especially with Context, Activity, Fragment, and View references.
- Do not block the main thread.
- Use coroutines appropriately for asynchronous work.
- Respect runtime permission flows.
- Handle configuration changes safely.
- Keep UI logic separate from business logic.

## Architecture

- Prefer MVVM when architecture decisions are needed.
- Keep ViewModels free of Android UI references.
- Keep business logic outside Activities, Fragments, and Composables.
- Prefer repository abstractions for data access.
- Keep networking, persistence, domain logic, and UI concerns separated.
- Add tests when the project already has a testing pattern.

## Jetpack Compose guidelines

If the project uses Jetpack Compose:

- Keep Composables small and focused.
- Prefer stateless Composables when possible.
- Hoist state to the appropriate owner.
- Avoid business logic inside Composables.
- Use stable UI state models.
- Avoid unnecessary recompositions.

## XML View guidelines

If the project uses XML Views:

- Keep Activities and Fragments thin.
- Avoid putting business logic in UI controllers.
- Use ViewBinding if already configured.
- Do not introduce DataBinding unless explicitly requested.

## Testing

- Prefer unit tests for business logic.
- Prefer UI tests only when necessary.
- Follow the existing test structure.
- Do not add new testing libraries without approval.

## Dependency policy

Before changing any dependency, ask first.

This includes:

- adding a new library
- removing an existing library
- updating a version
- changing Gradle plugins
- changing Kotlin version
- changing Android Gradle Plugin version
- changing Compose compiler or Compose BOM
- changing SDK versions unless explicitly requested

## Output expectations

When making changes:

- Explain what changed.
- Mention files modified.
- Mention any risks or assumptions.
- Mention if a dependency change would be useful, but do not apply it without approval.
