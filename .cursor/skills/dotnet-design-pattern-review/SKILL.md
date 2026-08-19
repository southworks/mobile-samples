---
name: dotnet-design-pattern-review
description: >-
  Review C#/.NET code for design patterns, SOLID, and architecture. Use when the
  user asks for a .NET design-pattern review or architecture feedback on C# code.
  Do not edit code; report findings only.
disable-model-invocation: true
---

# .NET/C# Design Pattern Review

Review the C#/.NET code in the current context (open files, @-mentioned paths, or the user's selection). **Do not change code** — provide a review with specific, actionable recommendations.

Align feedback with patterns the project already uses. Suggest new patterns only when they clearly improve the sample without over-engineering.

## Patterns to Evaluate (when relevant)

- **Dependency Injection**: constructor injection, interface abstractions, correct lifetimes
- **Factory**: justified for complex creation; avoid factories for trivial `new`
- **Repository / data access**: async interfaces, clear ownership of connections/units of work
- **Provider / adapter**: external services behind clear contracts and configuration
- **Command / handler**: only if the project already uses a command pipeline
- **Strategy / Template Method**: where behavior variation is real and duplicated

## Review Checklist

- **Design patterns**: Which patterns are present? Correctly applied? Missing something beneficial?
- **Architecture**: Clear separation of concerns? Consistent with project layout?
- **.NET practices**: async/`Task`, disposal, structured logging, strongly typed config?
- **SOLID**: SRP, OCP, LSP, ISP, DIP violations that matter in practice?
- **Performance**: blocking calls, missing disposal, unnecessary sync-over-async?
- **Testability**: dependencies abstracted and mockable?
- **Security**: input validation, secret handling, safe data access, safe exception messages?
- **Clarity**: names reflect domain intent; methods/classes sized appropriately?

## Output Format

Structure the review as:

1. **Summary** — overall assessment in 2–3 sentences
2. **Findings** — ordered by severity (critical → suggestion → nice-to-have)
3. **Recommendations** — concrete next steps tied to specific types/files when possible

Do not implement fixes unless the user explicitly asks after the review.
