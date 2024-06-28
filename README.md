# `ak1ra_lab/selfhosted_server`

## Quick start

```
git clone git@github.com:ak1ra-lab/selfhosted-server.git
cd selfhosted-server && make install
```

执行 `make install` 会将 collection 安装到 `~/.ansible/collections` 目录, 在其他目录中使用本 collection 中的 roles 时注意使用 FQDN (fully qualified domain name), 即带上 `ak1ra_lab.selfhosted_server.` 前缀, 参考下方 Roles.

## `playbooks/Makefile`

我们在 `playbooks/Makefile` 中预置了一些常用的 ansible-playbook command snippet,
可以使用 `make docker` 执行 `playbooks/docker.yaml`, 也可以使用 `make certbot` 执行 `playbooks/certbot.yaml`, 如,

```
PLAYBOOK_HOST=remote_host make docker
PLAYBOOK_HOST=remote_host make certbot
```

请使用 `make help` 查看可用的 snippet, `playbooks/Makefile` 中的指令仅供参考, 实际使用时请自行调整参数.

## Roles

| roles                                                           | description                                                                                                               |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [ak1ra_lab.selfhosted_server.common](roles/common/)             | 一些服务器的初始化操作, 常用软件包安装, TCP BBR 设置, `/etc/sysctl.conf` 参数设置等                                       |
| [ak1ra_lab.selfhosted_server.certbot](roles/certbot/)           | 安装 certbot, 并通过 dns plugin 生成 wildcard cert                                                                        |
| [ak1ra_lab.selfhosted_server.docker](roles/docker/)             | 安装 docker 及容器化相关工具, docker daemon 配置                                                                          |
| [ak1ra_lab.selfhosted_server.nginx](roles/nginx/)               | 可以选择使用多个来源安装 Nginx, nginx_org 或 xtom_com                                                                     |
| [ak1ra_lab.selfhosted_server.nginx_config](roles/nginx_config/) | 用于 Nginx 配置文件初始化和 server 配置文件生成                                                                           |
| [ak1ra_lab.selfhosted_server.rsstt](roles/rsstt/)               | 通过 Python pip 安装 [RSS-to-Telegram-Bot](https://github.com/Rongronggg9/RSS-to-Telegram-Bot) 并为其配置 telegraph_token |
| [ak1ra_lab.selfhosted_server.v2ray](roles/v2ray/)               | 通过 GitHub release 安装 [v2ray](https://github.com/v2fly/v2ray-core/releases)                                            |
| [ak1ra_lab.selfhosted_server.v2ray_config](roles/v2ray_config/) | 提供几种常用的 v2ray 配置文件模板, 如 Trojan-TCP, VMess-WSS 等, 具体参考 roles [README.md](roles/v2ray_config/README.md)  |
| [ak1ra_lab.selfhosted_server.jenkins](roles/jenkins/)           | 配置 `https://pkg.jenkins.io/debian-stable` 为 apt repo 安装 Jenkins                                                      |
| [ak1ra_lab.selfhosted_server.gcloud](roles/gcloud/)             | 配置 `https://packages.cloud.google.com/apt` 为 apt repo 安装 `google-cloud-cli`                                          |

## Scripts

- [init-user.sh](./init-user.sh), 用于处理没有 cloud-init 加持的服务器最基本的初始化, 普通用户创建, 添加 SSH keys.

## License

MIT License
