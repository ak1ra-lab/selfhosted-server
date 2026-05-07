# roles/go_install

Ansible role that installs a Go command on **localhost** with `go install`, keeping
build work off of remote hosts that may have limited CPU.

All install tasks run with `delegate_to: localhost` and `run_once: true`. The role
uses an isolated `GOBIN`, `GOPATH`, `GOMODCACHE`, and `GOCACHE` under
`go_install_base_dir`, so it does not depend on or pollute the caller's local Go
workspace.

After the install, the fact `go_install_binary_path` is set on every target host
pointing to the installed binary on localhost.

## Requirements

`go` must be present in localhost `PATH`. The role fails immediately if it is not
found.

## Role Variables

| Variable               | Default         | Description                                                           |
| ---------------------- | --------------- | --------------------------------------------------------------------- |
| go_install_package     | empty string    | **(required)** Go command package path passed to `go install`         |
| go_install_output_name | empty string    | **(required)** Expected binary filename in `GOBIN`                    |
| go_install_version     | latest          | Go module version query appended as `@version`                        |
| go_install_static      | true            | When true, sets `CGO_ENABLED=0` for a static binary                   |
| go_install_ldflags     | -s -w           | Extra linker flags passed through `-ldflags`                          |
| go_install_goos        | linux           | Target `GOOS`                                                         |
| go_install_goarch      | amd64           | Target `GOARCH`                                                       |
| go_install_base_dir    | /tmp/go-install | Base directory on localhost for `GOBIN`, caches, and install metadata |

## Output Fact

After the role runs every target host will have:

```yaml
go_install_binary_path: "{{ go_install_gobin }}/{{ go_install_output_name }}"
```

Use it in subsequent tasks to copy the binary to the remote host.

## Example Playbook

```yaml
---
# ansible-playbook playbooks/go_install/yamlfmt_playbook.yaml
- name: install yamlfmt on localhost
  hosts: "{{ playbook_hosts | default('localhost') }}"
  become: false

  tasks:
    - name: install yamlfmt via go_install
      ansible.builtin.import_role:
        name: go_install
      vars:
        go_install_package: "github.com/google/yamlfmt/cmd/yamlfmt"
        go_install_version: "latest"
        go_install_output_name: "yamlfmt"
```
