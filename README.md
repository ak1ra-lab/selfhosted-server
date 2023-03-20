
# selfhosted-server

## Quick start

参考 [playbook.example.yml](./playbook.example.yml) 使用 roles 目录下的 Ansible Roles.

## Ansible roles

| roles | description |
| ----- | ----------- |
| [common](roles/common/) | 一些服务器的初始化操作, 常用软件包安装, TCP BBR 设置, `/etc/sysctl.conf` 参数设置等  |
| [certbot](roles/certbot/) | 安装 certbot, 并通过 dns plugin 生成 wildcard cert |
| [docker](roles/docker/) | 安装 docker 及容器化相关工具, docker daemon 配置 |
| [nginx](roles/nginx/) | 可以选择使用多个来源安装 Nginx, nginx_org 或 xtom_com |
| [nginx_config](roles/nginx_config/) | 用于 Nginx 配置文件初始化和 server 配置文件生成 |
| [rsstt](roles/rsstt/) | 通过 Python pip 安装 [RSS-to-Telegram-Bot](https://github.com/Rongronggg9/RSS-to-Telegram-Bot) 并为其配置 telegraph_token |
| [v2ray](roles/v2ray/) | 通过 GitHub release 安装 [v2ray](https://github.com/v2fly/v2ray-core/releases) |
| [v2ray_config](roles/v2ray_config/) | 提供几种常用的 v2ray 配置文件模板, 如 Trojan-TCP, VMess-WSS 等, 具体参考 roles [README.md](roles/v2ray_config/README.md) |

## Scripts

* [init-role.sh](./init-role.sh), 用于开发新的 ansible role 时快速创建对应目录结构
* [init-user.sh](./init-user.sh), 用于处理没有 cloud-init 加持的服务器最基本的初始化, 普通用户创建, 添加 SSH keys

## License

MIT License
