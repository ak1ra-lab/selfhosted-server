# [ak1ra-lab/selfhosted-server](https://github.com/ak1ra-lab/selfhosted-server)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ak1ra-lab/selfhosted-server)

## Requirements

- Ansible >= 2.20

## Ansible Installation

The recommended way to install Ansible is [`uv tool`](https://docs.astral.sh/uv/getting-started/installation/),

```shell
# Installing Ansible
uv tool install ansible-dev-tools --with ansible \
  --with-executables-from ansible-builder,ansible-core,ansible-creator,ansible-dev-environment,ansible-lint,ansible-navigator,ansible-sign,molecule

# Upgrading Ansible
uv tool upgrade ansible-dev-tools
```

### Development (editable install)

To run playbooks directly from a git checkout without building and installing the collection, create a local symlink so Ansible can resolve the `ak1ra_lab.selfhosted_server`
namespace from the repository root:

```shell
mkdir -p ./.ansible/collections/ansible_collections/ak1ra_lab
ln -s ../../../.. ./.ansible/collections/ansible_collections/ak1ra_lab/selfhosted_server
```

The `ansible.cfg` in this repository already includes `./.ansible/collections` at the front of `collections_path`, so no further configuration is needed. The `collections/` directory is gitignored.
