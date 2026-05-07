# roles/go_build

Ansible role that builds a Go command on **localhost** from a git repository with
`git clone` and `go build`, keeping build work off remote hosts that may have
limited CPU.

All build tasks run with `delegate_to: localhost` and `run_once: true`. The role
uses an isolated local source checkout and build caches under `go_build_base_dir`.

After the build, the fact `go_build_binary_path` is set on every target host
pointing to the built binary on localhost.

## Requirements

`go` must be present in localhost `PATH`. The role fails immediately if it is not
found.

## Role Variables

| Variable             | Default       | Description                                              |
| -------------------- | ------------- | -------------------------------------------------------- |
| go_build_repo_url    | empty string  | **(required)** Git repository URL                        |
| go_build_output_name | empty string  | **(required)** Expected output binary filename           |
| go_build_repo_version| HEAD          | Git branch, tag, or commit to check out                 |
| go_build_package     | .             | Go package path passed to `go build`                     |
| go_build_static      | true          | When true, sets `CGO_ENABLED=0` for a static binary      |
| go_build_ldflags     | -s -w         | Extra linker flags passed through `-ldflags`             |
| go_build_goos        | linux         | Target `GOOS`                                            |
| go_build_goarch      | amd64         | Target `GOARCH`                                          |
| go_build_base_dir    | /tmp/go-build | Base directory for source checkout, output, and caches   |

## Output Fact

After the role runs every target host will have:

```yaml
go_build_binary_path: "{{ go_build_base_dir }}/bin/{{ go_build_output_name }}"
```

Use it in subsequent tasks to copy the binary to the remote host.
