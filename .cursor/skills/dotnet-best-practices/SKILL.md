---
name: dotnet-best-practices
description: >-
  Apply .NET/C# best practices to code in context. Use when editing or reviewing
  C# (.cs), .csproj files, or when the user asks to apply .NET/C# standards.
disable-model-invocation: true
---

# .NET/C# Best Practices

Ensure .NET/C# code in the current context (open files, @-mentioned paths, or the user's selection) meets solid .NET practices for this solution. Prefer conventions already present in the sample over inventing a new architecture.

## Documentation & Structure

- Add XML docs on public APIs when the project already uses them
- Include `<param>` and `<returns>` where they add clarity
- Follow the project's existing namespace and folder structure

## Design & DI

- Prefer primary constructors when the project already uses them
- Prefer interface segregation (`I`-prefix) for testable boundaries
- Use constructor injection; validate required dependencies when that pattern is established
- Register services with appropriate lifetimes (Singleton, Scoped, Transient)
- Use `Microsoft.Extensions.DependencyInjection` patterns consistent with the sample

## Async / Await

- Use `async`/`await` for I/O and long-running work
- Return `Task` or `Task<T>`; never block with `.Result` / `.Wait()`
- Use `ConfigureAwait(false)` in library code when appropriate
- Handle async exceptions explicitly at meaningful boundaries

## Configuration, Logging & Errors

- Prefer strongly typed options with validation attributes over loose string lookups
- Bind settings via `IConfiguration` / `IOptions<T>` when the sample uses them
- Use structured logging with `Microsoft.Extensions.Logging`
- Throw specific exceptions with descriptive messages; catch only expected failures

## Testing

- Follow AAA (Arrange, Act, Assert)
- Mock via interfaces; cover success and failure paths
- Match the test stack already in the project (xUnit, NUnit, MSTest, etc.)

## Performance & Security

- Validate and sanitize inputs
- Use parameterized queries / safe data-access patterns
- Never hard-code or commit secrets; avoid logging credentials
- Prefer modern .NET APIs already aligned with the project's TFM

## Code Quality

- Apply SOLID where it improves clarity, not ceremony
- Avoid duplication; keep methods focused
- Implement disposal (`IDisposable` / `IAsyncDisposable`) correctly

## Optional patterns (only if the sample already uses them)

- Command handlers, factories, ResourceManager/`.resx`, Semantic Kernel — do **not** introduce these unless the project already depends on them
