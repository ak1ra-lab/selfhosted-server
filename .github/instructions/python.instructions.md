---
applyTo: "**/*.py"
---

## Python Script Guidelines

### Code Quality & Style

- Follow PEP 8 style guidelines consistently
- Use type hints for all variables, parameters, and return types
- Write Google-style docstrings for all public modules, classes, and functions

### Structure & Organization

- Use `main()` function with `if __name__ == "__main__"` guard for CLI entry points
- Group related functionality into modules and classes
- Prefer composition over inheritance where appropriate

### Error Handling & Safety

- Handle errors with specific exception types; avoid bare `except` clauses
- Use context managers for resource handling (files, connections, etc.)
- Validate inputs and handle edge cases explicitly

### Tooling & Modern Practices

- Use `argparse` with `argcomplete` for command-line interfaces
- Use `logging` module for all output (avoid f-strings in logging calls)
- Prefer `pathlib` over `os.path` for file system operations
- Include unit tests (pytest) and static type checks (mypy)

### Development Standards

- Ensure code is testable and maintainable
- Document complex algorithms and business logic
- Keep functions focused and single-purpose
