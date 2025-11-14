# [ak1ra-lab/selfhosted-server](https://github.com/ak1ra-lab/selfhosted-server)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ak1ra-lab/selfhosted-server)

## Quick start

首先[使用 pipx 安装 Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pipx),

```shell
# Installing Ansible
pipx install --include-deps ansible

# Upgrading Ansible
pipx upgrade --include-injected ansible
```

之后使用 Ansible playbook install.yml 完成后续设置,

```shell
git clone https://github.com/ak1ra-lab/selfhosted-server.git
cd selfhosted-server

make install
```

## How to setup argcomplete for ansible?

为正确安装和配置 argcomplete, 我们可能需要安装两份 argcomplete,

- 其一从 distro repo 安装 python3-argcomplete
- 其二由 pipx inject 进入 ansible venv

```shell
# 其实 python3-argcomplete 已经作为 pipx 的依赖被全局安装在系统中
sudo apt install python3-argcomplete

# 创建系统全局 bash-completion 配置 /etc/bash_completion.d/python-argcomplete, 此步骤只需要执行一次
sudo activate-global-python-argcomplete

# 由 pipx inject 进入 ansible venv
# ansible 本身需要在执行 `parser.parse_args()` 之前先执行 `argcomplete.autocomplete(parser)`
# 也即 ansible 也需要 `import argcomplete`
# 注意无需携带 `--include-deps` 选项, 否则会与系统 PATH 中的 python3-argcomplete 发生"冲突"
pipx inject ansible argcomplete
```

## Scripts

- [init-user.sh](./init-user.sh), 用于处理没有 cloud-init 加持的服务器最基本的初始化, 普通用户创建, 添加 SSH keys.

## License

MIT License
