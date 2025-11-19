---
applyTo: "{inventory,playbooks,roles}/**/*.{yml,yaml}"
---

## Ansible Development Guidelines

### Code Style & Formatting

- Use YAML with 2-space indentation consistently
- Write clear, descriptive task names
- Use fully-qualified module names
- Follow Ansible-Lint rules and best practices

### Playbook Structure

- Include required attributes: `name`, `hosts`, `gather_facts`, `become`
- Prefer `import_tasks` and `import_playbook` over includes when appropriate
- Use `block/rescue/always` for comprehensive error handling
- Ensure playbooks are idempotent and predictable

### Role Architecture

- Follow Ansible Galaxy directory structure
- Use `defaults/` for default variables, `vars/` for static variables
- Restart services only through handlers to maintain idempotency
- Organize tasks logically and maintain clear dependencies

### Module Usage & Practices

- Prefer official Ansible modules over shell/command
- When using shell/command, include `creates`/`removes` and proper `changed_when`/`failed_when`
- Use appropriate file modules: `template:`, `copy:`, `file:`
- Avoid misuse of `lineinfile`; prefer structured alternatives

### Configuration & Security

- No hard-coded paths or hosts; use `group_vars`/`host_vars`/`vars`
- Store secrets in Ansible Vault only
- Use YAML format for inventory files
- Validate with `ansible-lint`, `yamllint`, and syntax checks
