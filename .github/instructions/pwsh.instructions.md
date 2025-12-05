---
applyTo: "**/*.ps1"
---

## PowerShell Script Guidelines

### Code Structure & Style

- Use `PascalCase` for functions, `camelCase` for variables
- Structure logic into functions with a clear `Main` entrypoint
- Begin scripts with `Set-StrictMode -Version Latest`
- Prefer .NET methods over manual string/array manipulation when they simplify implementation
- Add `#Requires` statements or comments for version-specific .NET methods

### Parameter Handling & Scope

- Use `param()` blocks with `[Parameter()]` attributes for validation
- Avoid global variables; prefer function parameters and local scope
- Avoid using the `-Force` option for stateful operations
- Implement `SupportsShouldProcess` with `-WhatIf` for destructive operations

### Error Handling & Output

- Use `try/catch/finally` blocks for comprehensive error handling
- Prefer `Write-Output` for standard output and `Write-Error` for errors
- Handle terminating and non-terminating errors appropriately

### Best Practices

- Validate all inputs and parameters
- Include comment-based help for functions
- Ensure scripts are testable and maintainable
- Follow PowerShell common practices and conventions
- Note minimum PowerShell version requirements when using specific .NET methods
