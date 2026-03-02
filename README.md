# [ak1ra-lab/selfhosted-server](https://github.com/ak1ra-lab/selfhosted-server)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ak1ra-lab/selfhosted-server)

## Requirements

- Ansible >= 2.14

## Ansible Installation

推荐使用 [uv](https://docs.astral.sh/uv/getting-started/installation/) 安装 Ansible,

```shell
# Installing Ansible
uv tool install --with-executables-from ansible-core ansible

# Upgrading Ansible
uv tool upgrade ansible
```

### Development (editable install)

To run playbooks directly from a git checkout without building and installing the
collection, create a local symlink so Ansible can resolve the `ak1ra_lab.selfhosted_server`
namespace from the repository root:

```shell
mkdir -p collections/ansible_collections/ak1ra_lab
ln -s ../../.. collections/ansible_collections/ak1ra_lab/selfhosted_server
```

The `ansible.cfg` in this repository already includes `./collections` at the front
of `collections_path`, so no further configuration is needed. The `collections/`
directory is gitignored.
