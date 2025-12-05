---
applyTo: "**/*.sh"
---

## Shell Script Guidelines

### Portability & Compatibility

- Prefer POSIX-compliant syntax when bash-specific features aren't required
- Use bash features when they significantly simplify implementation
- Document any non-standard dependencies clearly

### Code Quality & Style

- Quote all variable expansions to prevent word splitting and globbing
- Always use `[[ ... ]]` for conditional tests in bash; `case` for pattern matching
- Group related logic into well-named functions
- Use descriptive variable names and avoid magic numbers
- Maintain idempotency where possible

### Error Handling & Robustness

- Enable strict mode: `set -euo pipefail` or appropriate restrictive options
- Explicitly check command exit codes
- Implement comprehensive error handling and logging
- Log meaningful messages for actions and errors

### Tooling & Maintenance

- Use `getopt` (not `getopts`) for command-line argument parsing
- Validate scripts with `shellcheck` and address all warnings
- Format code consistently using `shfmt`
- Ensure scripts pass all linting and validation checks
